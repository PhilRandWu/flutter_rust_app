use crate::AppState;
use crate::common::auth::hash_password;
use crate::common::error::AppError;
use crate::modules::users::dto::UserToken;
use crate::modules::users::{
    dto::{CreateUser, User},
    entity::UserInfo,
};
use chrono::Utc;

impl AppState {
    pub async fn create_user(&self, input: CreateUser) -> Result<User, AppError> {
        match self.is_user_exists_by_username(&input.username).await? {
            true => {
                return Err(AppError::UserExisted(format!(
                    "User {} already exists",
                    input.username
                )));
            }
            false => (),
        }

        let hashed_password = hash_password(&input.password)?;

        let mut transaction = self
            .pool
            .begin()
            .await
            .map_err(|err| AppError::DatabaseError(err.to_string()))?;

        let user_info = sqlx::query_as::<_, UserInfo>(
            r#"
      INSERT INTO users (username, password, created_at, updated_at)
      VALUES ($1, $2, $3, $4)
      RETURNING id, username, password, otp_enabled, otp_verified, otp_base32, otp_auth_url, created_at, updated_at
      "#,
        )
        .bind(&input.username)
        .bind(hashed_password)
        .bind(Utc::now())
        .bind(Utc::now())
        .fetch_one(&mut *transaction)
        .await
        .map_err(|err| AppError::DatabaseError(err.to_string()))?;

        transaction
            .commit()
            .await
            .map_err(|err| AppError::DatabaseError(err.to_string()))?;

        let user = User::new(user_info);
        Ok(user)
    }

    pub async fn is_user_exists_by_username(&self, username: &str) -> Result<bool, AppError> {
        let result = sqlx::query_scalar(
            r#"
            SELECT EXISTS (
               SELECT 1 FROM users WHERE username = $1
            )
            "#,
        )
        .bind(username)
        .fetch_one(&self.pool)
        .await
        .map_err(|err| AppError::DatabaseError(err.to_string()))?;
        Ok(result)
    }

    pub async fn verify_user_by_username(&self, username: &str) -> Result<User, AppError> {
        let user_info: UserInfo = sqlx::query_as(
            r#"
SELECT id, username, password, otp_enabled, otp_verified, otp_base32, otp_auth_url, created_at, updated_at
FROM users WHERE username = $1
"#,
        )
        .bind(&username)
        .fetch_one(&self.pool)
        .await
        .map_err(|_err| AppError::NotFound(format!("User {} not found", username)))?;

        let user = self.get_user_obj_by_user_info(user_info).await?;
        Ok(user)
    }

    pub async fn get_user_obj_by_user_info(&self, user_info: UserInfo) -> Result<User, AppError> {
        let user = User::new(user_info);
        Ok(user)
    }

    pub async fn get_user_by_username(&self, username: &str) -> Result<User, AppError> {
        let user_info: UserInfo = sqlx::query_as(
            r#"
      SELECT id, username, created_at, updated_at
      FROM users
      WHERE username = $1
      "#,
        )
        .bind(username)
        .fetch_one(&self.pool)
        .await
        .map_err(|_| AppError::NotFound(format!("User: {} not found", username)))?;

        let user = self.get_user_obj_by_user_info(user_info).await?;
        Ok(user)
    }

    pub async fn save_user_token(&self, user_token: UserToken) -> Result<(), AppError> {
        sqlx::query(
            r#"
        INSERT INTO user_tokens (id, user_id, token_id, expires_at)
        VALUES ($1, $2, $3, $4)
        "#,
        )
        .bind(&user_token.id)
        .bind(&user_token.user_id)
        .bind(&user_token.token_id)
        .bind(&user_token.expires_at)
        .execute(&self.pool)
        .await
        .map_err(|err| AppError::DatabaseError(format!("Failed to save user token: {}", err)))?;

        Ok(())
    }
}
