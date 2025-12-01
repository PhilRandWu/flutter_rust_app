use crate::AppState;
use anyhow::Result;
use crate::common::auth::{sign, verify_password};
use crate::common::error::AppError;
use crate::modules::auth::dto::TokenResponse;
use crate::modules::users::dto::User;

impl AppState {
    pub async fn get_token(&self, username: &str, password: &str) -> Result<TokenResponse> {
        let user = self.verify_user(username, password).await?;
        let token = sign(user).await?;
        Ok(TokenResponse::new(&token))
    }
    
    pub async fn verify_user(&self, username: &str, password: &str) -> Result<User, AppError> {
        let user = self.verify_user_by_username(username).await?;
        if verify_password(password, &user.user_info.password)? {  
            Ok(user)
        } else { 
            Err(AppError::PasswordError("Invalid username or password".to_string()))
        }
    }
}