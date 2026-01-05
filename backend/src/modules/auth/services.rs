use crate::AppState;
use crate::common::{
    auth::{generate_tokens, verify_password, verify_refresh_token},
    error::AppError,
};
use crate::modules::{
    auth::dto::TokenResponse,
    users::dto::{User, UserToken},
};
use anyhow::Result;
use chrono::DateTime;

impl AppState {
    pub async fn get_token(
        &self,
        username: &str,
        password: &str,
    ) -> Result<TokenResponse, AppError> {
        let user = self.verify_user(username, password).await?;
        let (access_token, refresh_token, access_claims, refresh_claims) =
            generate_tokens(self, user.clone()).await?;

        let user_token = UserToken::new(
            user.user_info.id.unwrap(),
            refresh_claims.jti,
            DateTime::from_timestamp(refresh_claims.exp, 0)
                .ok_or_else(|| AppError::InternalServerError)?,
        );
        self.save_user_token(user_token).await?;
        Ok(TokenResponse::new(
            &access_token,
            &refresh_token,
            access_claims.exp,
        ))
    }

    pub async fn refresh_token(&self, refresh_token: &str) -> Result<TokenResponse, AppError> {
        let refresh_claims = verify_refresh_token(self, refresh_token).await?;
        let db_token: Option<UserToken> = sqlx::query_as(
            r#"SELECT id, user_id, token_id, expires_at
               FROM user_tokens
               WHERE token_id = $1 AND expires_at > NOW()"#,
        )
        .bind(&refresh_claims.jti)
        .fetch_optional(&self.pool)
        .await
        .map_err(|e| AppError::DatabaseError(format!("query refresh: {}", e)))?;

        let _ = db_token
            .ok_or_else(|| AppError::Unauthorized("refresh token invalid/expired".into()))?;

        let user: User = sqlx::query_as(
            r#"
            SELECT
                id, username, password, otp_enabled, otp_verified,
                otp_base32, otp_auth_url, created_at, updated_at
            FROM users
            WHERE id = $1
            "#,
        )
        .bind(&refresh_claims.sub)
        .fetch_one(&self.pool)
        .await
        .map_err(|_| AppError::NotFound(format!("用户 ID {:?} 不存在", refresh_claims.sub)))?;

        let (new_access_token, new_refresh_token, new_claims, new_refresh_claims) =
            generate_tokens(self, user.clone()).await?;

        sqlx::query("DELETE FROM user_tokens WHERE user_id = $1")
            .bind(&refresh_claims.sub)
            .fetch_one(&self.pool)
            .await
            .map_err(|e| AppError::DatabaseError(format!("delete old: {}", e)))?;

        let new_ut = UserToken::new(
            refresh_claims.sub,
            new_refresh_claims.jti,
            DateTime::from_timestamp(new_refresh_claims.exp, 0)
                .ok_or_else(|| AppError::InternalServerError)?,
        );
        self.save_user_token(new_ut).await?;
        Ok(TokenResponse::new(
            &new_access_token,
            &new_refresh_token,
            new_claims.exp,
        ))
    }

    pub async fn verify_user(&self, username: &str, password: &str) -> Result<User, AppError> {
        let user = self.verify_user_by_username(username).await?;
        if verify_password(password, &user.user_info.password)? {
            Ok(user)
        } else {
            Err(AppError::PasswordError(
                "Invalid username or password".to_string(),
            ))
        }
    }
}
