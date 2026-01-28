use serde::{Deserialize, Serialize};
use validator::Validate;

#[derive(Debug, Deserialize, Serialize, Validate)]
pub struct TokenRequest {
    #[validate(length(min = 3, max = 50))]
    pub username: String,
    #[validate(length(min = 6, max = 50))]
    pub password: String,
}

impl TokenRequest {
    pub fn new(username: &str, password: &str) -> Self {
        Self {
            username: username.to_string(),
            password: password.to_string(),
        }
    }
}

#[derive(Debug, Deserialize, Serialize)]
pub struct TokenResponse {
    pub access_token: String,
    pub refresh_token: String,
    pub token_type: Option<String>,
    pub expires_in: i64,
}

impl TokenResponse {
    pub fn new(access_token: &str, refresh_token: &str, expires_in: i64) -> Self {
        Self {
            access_token: access_token.to_string(),
            refresh_token: refresh_token.to_string(),
            token_type: Some("Bearer".to_string()),
            expires_in,
        }
    }
}

impl Default for TokenResponse {
    fn default() -> Self {
        Self {
            access_token: "".to_string(),
            refresh_token: "".to_string(),
            token_type: Some("Bearer".to_string()),
            expires_in: -1,
        }
    }
}

#[derive(Debug, Deserialize, Serialize, Validate)]
pub struct LogoutRequest {
    #[validate(length(min = 1))]
    pub refresh_token: String,
}

#[derive(Debug, Deserialize, Serialize)]
pub struct LogoutResponse {
    pub message: String,
}

impl LogoutResponse {
    pub fn new() -> Self {
        Self {
            message: "Logged out successfully".to_string(),
        }
    }
}
