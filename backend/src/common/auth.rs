use crate::{
    common::error::AppError,
    modules::users::dto::User,
    AppState,
};
use argon2::{
    password_hash::{rand_core::OsRng, SaltString},
    Argon2, PasswordHash, PasswordHasher, PasswordVerifier,
};
use chrono::{TimeDelta, Utc};
use jwt_simple::prelude::*;

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

pub async fn generate_tokens(
    state: &AppState,
    user: User,
) -> Result<(String, String, TokenClaims, TokenClaims), AppError> {
    let now = Utc::now();
    let access_duration = TimeDelta::seconds(state.config.auth.jwt_duration as i64);
    let refresh_duration = TimeDelta::seconds(state.config.auth.refresh_token_duration as i64);

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
        iss: state.config.auth.jwt_iss.clone(),
        aud: state.config.auth.jwt_aud.clone(),
        exp: access_exp.timestamp(),
        iat: now.timestamp(),
        token_type: "access".to_string(),
    };
    let refresh_claims = TokenClaims {
        sub: user.user_info.id.unwrap(),
        jti: jti.clone(),
        iss: state.config.auth.jwt_iss.clone(),
        aud: state.config.auth.jwt_aud.clone(),
        exp: refresh_exp.timestamp(),
        iat: now.timestamp(),
        token_type: "refresh".to_string(),
    };

    let jwt_access_claims = Claims::with_custom_claims(
        access_claims.clone(),
        Duration::from_secs(state.config.auth.jwt_duration),
    );

    let jwt_refresh_claims = Claims::with_custom_claims(
        refresh_claims.clone(),
        Duration::from_secs(state.config.auth.refresh_token_duration),
    );

    let access_token = state.key_pair.sign(jwt_access_claims)?;
    let refresh_token = state.key_pair.sign(jwt_refresh_claims)?;

    Ok((access_token, refresh_token, access_claims, refresh_claims))
}

pub async fn verify_access_token(state: &AppState, token: &str) -> Result<User, AppError> {
    let options = VerificationOptions {
        allowed_issuers: Some(HashSet::from_strings(&[
            state.config.auth.jwt_iss.clone()
        ])),
        allowed_audiences: Some(HashSet::from_strings(&[
            state.config.auth.jwt_aud.clone()
        ])),
        ..Default::default()
    };

    let verify_claims = state
        .public_key
        .verify_token::<User>(token, Some(options))?;
    Ok(verify_claims.custom)
}

pub async fn verify_refresh_token(state: &AppState, token: &str) -> Result<TokenClaims, AppError> {
    let options = VerificationOptions {
        allowed_issuers: Some(HashSet::from_strings(&[
            state.config.auth.jwt_iss.clone()
        ])),
        allowed_audiences: Some(HashSet::from_strings(&[
            state.config.auth.jwt_aud.clone()
        ])),
        ..Default::default()
    };

    let verify_claims = state
        .public_key
        .verify_token::<TokenClaims>(token, Some(options))?;

    if verify_claims.custom.token_type != "refresh" {
        return Err(AppError::Unauthorized(
            "Invalid refresh token type".to_string(),
        ));
    }
    Ok(verify_claims.custom)
}
