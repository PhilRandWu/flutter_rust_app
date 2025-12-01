use argon2::{Argon2, PasswordHash, PasswordHasher, PasswordVerifier};
use argon2::password_hash::rand_core::OsRng;
use argon2::password_hash::SaltString;
use crate::common::config::AppConfig;
use crate::common::error::AppError;
use crate::modules::users::dto::User;
use std::fs::read_to_string;
use jwt_simple::claims;
use jwt_simple::prelude::{Claims, Duration, Ed25519KeyPair, EdDSAKeyPairLike};

pub fn hash_password(password: &str) -> Result<String, AppError> {
    let salt = SaltString::generate(&mut OsRng);
    let argon2 = Argon2::default();
    let hashed_password = argon2.hash_password(
        password.as_bytes(),
        &salt
    )?.to_string();
    Ok(hashed_password)
}

pub fn verify_password(password: &str, hashed_password: &str) -> Result<bool, AppError> {
    let argon2 = Argon2::default();
    let parsed_hash = PasswordHash::new(hashed_password)?;
    let is_valid = argon2.verify_password(password.as_bytes(), &parsed_hash)
        .is_ok();
    Ok(is_valid)
}

pub async fn sign(user: User) -> Result<String, AppError> {
    let config = AppConfig::from_file("app.yaml");
    let secret_key_pem = read_to_string(config.clone().auth.secret_key)?;
    let key_pair = Ed25519KeyPair::from_pem(&secret_key_pem)?;

    let user = user.into();
    let claims = Claims::with_custom_claims::<User>(user, Duration::from_secs(config.clone().auth.jwt_duration));

    let claims = claims
        .with_issuer(config.clone().auth.jwt_iss)
        .with_audience(config.clone().auth.jwt_aud);

    let token = key_pair.sign(claims)?;
    Ok(token)
}