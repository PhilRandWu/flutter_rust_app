use crate::common::{config::AppConfig, error::AppError};
use crate::modules::users::dto::User;
use argon2::{
    Argon2, PasswordHash, PasswordHasher, PasswordVerifier,
    password_hash::{SaltString, rand_core::OsRng},
};
use chrono::{TimeDelta, Utc};
use jwt_simple::prelude::*;
use std::fs::read_to_string;
use uuid::Uuid;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct TokenClaims {
    pub sub: Uuid,          // 用户ID
    pub jti: String,        // token唯一标识
    pub iss: String,        // 签发者
    pub aud: String,        // 受众
    pub exp: i64,           // 过期时间
    pub iat: i64,           // 签发时间
    pub token_type: String, // token类型（access/refresh）
}

pub fn hash_password(password: &str) -> Result<String, AppError> {
    let salt = SaltString::generate(&mut OsRng);
    let argon2 = Argon2::default();
    let hashed_password = argon2
        .hash_password(password.as_bytes(), &salt)?
        .to_string();
    Ok(hashed_password)
}

pub fn verify_password(password: &str, hashed_password: &str) -> Result<bool, AppError> {
    let argon2 = Argon2::default();
    let parsed_hash = PasswordHash::new(hashed_password)?;
    let is_valid = argon2
        .verify_password(password.as_bytes(), &parsed_hash)
        .is_ok();
    Ok(is_valid)
}

pub async fn generate_tokens(user: User) -> Result<(String, String, TokenClaims, TokenClaims), AppError> {
    let config = AppConfig::from_file("app.yaml");
    let secret_key_pem = read_to_string(config.clone().auth.secret_key)?;
    let key_pair = Ed25519KeyPair::from_pem(&secret_key_pem)?;

    let now = Utc::now();
    let access_duration = TimeDelta::seconds(config.auth.jwt_duration as i64);
    let refresh_duration = TimeDelta::seconds(config.auth.refresh_token_duration as i64);

    let access_exp = now
        .checked_add_signed(access_duration)
        .ok_or_else(|| AppError::InternalServerError)?;

    let refresh_exp = now
        .checked_add_signed(refresh_duration)
        .ok_or_else(|| AppError::InternalServerError)?;

    let jti = Uuid::new_v4().to_string();
    let access_claims = TokenClaims {
        sub: user.user_info.id.unwrap(),
        jti: jti.clone(),
        iss: config.auth.jwt_iss.clone(),
        aud: config.auth.jwt_aud.clone(),
        exp: access_exp.timestamp(),
        iat: now.timestamp(),
        token_type: "access".to_string(),
    };
    let refresh_claims = TokenClaims {
        sub: user.user_info.id.unwrap(),
        jti: jti.clone(),
        iss: config.auth.jwt_iss.clone(),
        aud: config.auth.jwt_aud.clone(),
        exp: refresh_exp.timestamp(),
        iat: now.timestamp(),
        token_type: "refresh".to_string(),
    };

    let jwt_access_claims = Claims::with_custom_claims(
        access_claims.clone(),
        Duration::from_secs(config.auth.jwt_duration),
    );

    let jwt_refresh_claims = Claims::with_custom_claims(
        refresh_claims.clone(),
        Duration::from_secs(config.auth.refresh_token_duration),
    );

    let access_token = key_pair.sign(jwt_access_claims)?;
    let refresh_token = key_pair.sign(jwt_refresh_claims)?;

    Ok((access_token, refresh_token, access_claims, refresh_claims))
}

pub async fn verify_access_token(token: &str) -> Result<User, AppError> {
    let config = AppConfig::from_file("app.yaml");
    let public_key_pem = read_to_string(config.clone().auth.public_key)?;
    let public_key = Ed25519PublicKey::from_pem(&public_key_pem)?;

    let options = VerificationOptions {
        allowed_issuers: Some(HashSet::from_strings(&[config.auth.jwt_iss.clone()])),
        allowed_audiences: Some(HashSet::from_strings(&[config.auth.jwt_aud.clone()])),
        ..Default::default()
    };

    let verify_claims = public_key.verify_token::<User>(token, Some(options))?;
    Ok(verify_claims.custom)
}

pub async fn verify_refresh_token(token: &str) -> Result<TokenClaims, AppError> {
    let config = AppConfig::from_file("app.yaml");
    let public_key_pem = read_to_string(config.clone().auth.public_key)?;
    let public_key = Ed25519PublicKey::from_pem(&public_key_pem)?;

    let options = VerificationOptions {
        allowed_issuers: Some(HashSet::from_strings(&[config.auth.jwt_iss.clone()])),
        allowed_audiences: Some(HashSet::from_strings(&[config.auth.jwt_aud.clone()])),
        ..Default::default()
    };

    let verify_claims = public_key.verify_token::<TokenClaims>(token, Some(options))?;

    if verify_claims.custom.token_type != "refresh" {
        return Err(AppError::Unauthorized(
            "Invalid refresh token type".to_string(),
        ));
    }
    Ok(verify_claims.custom)
}
