use crate::{AppState, common::error::AppError, modules::users::dto::User};
use argon2::{
    Argon2, PasswordHash, PasswordHasher, PasswordVerifier,
    password_hash::{SaltString, rand_core::OsRng},
};
use jwt_simple::claims::JWTClaims;
use jwt_simple::prelude::*;
use serde::{Deserialize, Serialize};
use uuid::Uuid;

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

// TokenClaims 结构定义
#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct TokenClaims {
    pub token_type: String,
}

pub async fn generate_tokens(
    state: &AppState,
    user: User,
) -> Result<
    (
        String,
        String,
        JWTClaims<TokenClaims>,
        JWTClaims<TokenClaims>,
    ),
    AppError,
> {
    let jti = Uuid::new_v4().to_string();

    let access_claims = Claims::with_custom_claims(
        TokenClaims {
            token_type: "access".to_string(),
        },
        jwt_simple::prelude::Duration::from_secs(state.config.auth.jwt_duration),
    )
    .with_subject(user.user_info.id.unwrap().to_string()) // 修复为 user.user_info.id
    .with_jwt_id(jti.clone())
    .with_issuer(state.config.auth.jwt_iss.clone())
    .with_audience(state.config.auth.jwt_aud.clone());

    let refresh_claims = Claims::with_custom_claims(
        TokenClaims {
            token_type: "refresh".to_string(),
        },
        jwt_simple::prelude::Duration::from_secs(state.config.auth.refresh_token_duration),
    )
    .with_subject(user.user_info.id.unwrap().to_string())
    .with_jwt_id(jti)
    .with_issuer(state.config.auth.jwt_iss.clone())
    .with_audience(state.config.auth.jwt_aud.clone());

    let access_token = state.key_pair.sign(access_claims.clone())?;
    let refresh_token = state.key_pair.sign(refresh_claims.clone())?;

    Ok((access_token, refresh_token, access_claims, refresh_claims))
}

pub async fn verify_access_token(state: &AppState, token: &str) -> Result<User, AppError> {
    let options = VerificationOptions {
        allowed_issuers: Some(HashSet::from_strings(&[state.config.auth.jwt_iss.clone()])),
        allowed_audiences: Some(HashSet::from_strings(&[state.config.auth.jwt_aud.clone()])),
        ..Default::default()
    };

    let verify_claims = state
        .public_key
        .verify_token::<TokenClaims>(token, Some(options))
        .map_err(|e| AppError::Unauthorized(format!("Invalid token: {}", e)))?;

    if verify_claims.custom.token_type != "access" {
        return Err(AppError::Unauthorized("Invalid token type".to_string()));
    }

    let user_id = verify_claims.subject.ok_or(AppError::Unauthorized(
        "Invalid token: missing subject".to_string(),
    ))?;
    let user_id = Uuid::parse_str(&user_id)
        .map_err(|_| AppError::Unauthorized("Invalid token: invalid subject".to_string()))?;

    // Check if user has any valid refresh tokens
    // If no valid refresh tokens exist, access token is considered revoked
    let count: Option<i64> = sqlx::query_scalar(
        r#"SELECT COUNT(*) as count
           FROM user_tokens
           WHERE user_id = $1 AND token_type = 'refresh' AND expires_at > NOW()"#,
    )
    .bind(user_id)
    .fetch_one(&state.pool)
    .await
    .map_err(|e| AppError::DatabaseError(format!("query refresh tokens: {}", e)))?;

    if count.unwrap_or(0) == 0 {
        return Err(AppError::Unauthorized("Token has been revoked".to_string()));
    }

    let user = state
        .get_user_by_id(user_id)
        .await
        .map_err(|_| AppError::Unauthorized("User not found".to_string()))?;

    Ok(user)
}

pub async fn verify_refresh_token(
    state: &AppState,
    token: &str,
) -> Result<JWTClaims<TokenClaims>, AppError> {
    let options = VerificationOptions {
        allowed_issuers: Some(HashSet::from_strings(&[state.config.auth.jwt_iss.clone()])),
        allowed_audiences: Some(HashSet::from_strings(&[state.config.auth.jwt_aud.clone()])),
        ..Default::default()
    };

    let verify_claims = state
        .public_key
        .verify_token::<TokenClaims>(token, Some(options))
        .map_err(|e| AppError::Unauthorized(format!("Invalid token: {}", e)))?;

    if verify_claims.custom.token_type != "refresh" {
        return Err(AppError::Unauthorized(
            "Invalid refresh token type".to_string(),
        ));
    }
    Ok(verify_claims)
}