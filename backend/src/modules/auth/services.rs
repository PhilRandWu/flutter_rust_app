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

use uuid::Uuid;

impl AppState {
    pub async fn get_token(
        &self,
        username: &str,
        password: &str,
    ) -> Result<TokenResponse, AppError> {
        let user = self.verify_user(username, password).await?;
        let (access_token, refresh_token, access_claims, refresh_claims) =
            generate_tokens(self, user.clone()).await?;

        let refresh_jti = refresh_claims.jwt_id.ok_or(AppError::InternalServerError)?;
        let refresh_exp = refresh_claims
            .expires_at
            .ok_or(AppError::InternalServerError)?;
        let access_exp = access_claims
            .expires_at
            .ok_or(AppError::InternalServerError)?;

        let user_id = user.user_info.id.ok_or(AppError::InternalServerError)?;
        let user_token = UserToken::new(
            user_id,
            refresh_jti,
            "refresh".to_string(),
            DateTime::from_timestamp(refresh_exp.as_secs() as i64, 0)
                .ok_or_else(|| AppError::InternalServerError)?,
        );
        self.save_user_token(user_token).await?;
        Ok(TokenResponse::new(
            &access_token,
            &refresh_token,
            access_exp.as_secs() as i64,
        ))
    }

    pub async fn refresh_token(&self, refresh_token: &str) -> Result<TokenResponse, AppError> {
        let refresh_claims = verify_refresh_token(self, refresh_token).await?;

        let refresh_jti = refresh_claims
            .jwt_id
            .as_ref()
            .ok_or(AppError::Unauthorized("Missing JTI".into()))?;
        let refresh_sub = refresh_claims
            .subject
            .as_ref()
            .ok_or(AppError::Unauthorized("Missing Subject".into()))?;
        let user_id = Uuid::parse_str(refresh_sub)
            .map_err(|_| AppError::Unauthorized("Invalid Subject".into()))?;

        // 修复 SQL 查询 - 确保列名和表名正确
        let db_token: Option<UserToken> = sqlx::query_as(
            r#"SELECT id, user_id, token_id, token_type, expires_at, created_at
               FROM user_tokens
               WHERE token_id = $1 AND token_type = 'refresh' AND expires_at > NOW()"#,
        )
        .bind(refresh_jti)
        .fetch_optional(&self.pool)
        .await
        .map_err(|e| AppError::DatabaseError(format!("query refresh token: {}", e)))?;

        let _ = db_token
            .ok_or_else(|| AppError::Unauthorized("refresh token invalid/expired".into()))?;

        let user: User = sqlx::query_as(
            r#"
            SELECT
                id, username, password, email, avatar, is_deleted, created_at, updated_at
            FROM users
            WHERE id = $1 AND is_deleted = false
            "#,
        )
        .bind(user_id)
        .fetch_one(&self.pool)
        .await
        .map_err(|_| AppError::NotFound(format!("用户 ID {:?} 不存在", user_id)))?;

        let (new_access_token, new_refresh_token, new_claims, new_refresh_claims) =
            generate_tokens(self, user.clone()).await?;

        let new_refresh_jti = new_refresh_claims
            .jwt_id
            .ok_or(AppError::InternalServerError)?;
        let new_refresh_exp = new_refresh_claims
            .expires_at
            .ok_or(AppError::InternalServerError)?;
        let new_access_exp = new_claims.expires_at.ok_or(AppError::InternalServerError)?;

        sqlx::query("DELETE FROM user_tokens WHERE user_id = $1")
            .bind(user_id)
            .execute(&self.pool)
            .await
            .map_err(|e| AppError::DatabaseError(format!("delete old: {}", e)))?;

        let new_ut = UserToken::new(
            user_id,
            new_refresh_jti,
            "refresh".to_string(),
            DateTime::from_timestamp(new_refresh_exp.as_secs() as i64, 0)
                .ok_or_else(|| AppError::InternalServerError)?,
        );
        self.save_user_token(new_ut).await?;
        Ok(TokenResponse::new(
            &new_access_token,
            &new_refresh_token,
            new_access_exp.as_secs() as i64,
        ))
    }

    pub async fn logout(&self, refresh_token: &str) -> Result<(), AppError> {
        let refresh_claims = verify_refresh_token(self, refresh_token).await?;
        let refresh_jti = refresh_claims
            .jwt_id
            .ok_or(AppError::Unauthorized("Missing JTI".into()))?;

        let result = sqlx::query("DELETE FROM user_tokens WHERE token_id = $1")
            .bind(&refresh_jti)
            .execute(&self.pool)
            .await
            .map_err(|e| AppError::DatabaseError(format!("delete token: {}", e)))?;

        if result.rows_affected() == 0 {
            return Err(AppError::NotFound(
                "Token not found or already expired".to_string(),
            ));
        }
        Ok(())
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
