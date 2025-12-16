use crate::modules::users::entity::UserInfo;
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::FromRow;
use uuid::Uuid;
use validator::Validate;

#[derive(Debug, Deserialize, Serialize, Validate)]
pub struct CreateUser {
    #[validate(length(
        min = 3,
        max = 50,
        message = "username length must be between 3 and 50 characters"
    ))]
    pub username: String,
    #[validate(length(
        min = 6,
        max = 50,
        message = "password length must be between 8 and 50 characters"
    ))]
    pub password: String,
}

#[derive(Clone, Debug, Deserialize, Serialize, FromRow)]
pub struct User {
    pub user_info: UserInfo,
}

impl User {
    pub fn new(user_info: UserInfo) -> Self {
        Self { user_info }
    }
}

#[derive(Debug, Deserialize, Serialize, FromRow, Clone)]
pub struct UserToken {
    pub id: Uuid,
    pub user_id: Uuid,
    pub token_id: String, // 对应 JWT 的 jti
    pub expires_at: DateTime<Utc>,
}

impl UserToken {
    pub fn new(user_id: Uuid, token_id: String, expires_at: DateTime<Utc>) -> Self {
        Self {
            id: Uuid::new_v4(),
            user_id,
            token_id,
            expires_at,
        }
    }
}

#[derive(Debug, Deserialize, Serialize, Validate)]
pub struct PaginationParams {
    #[validate(range(min = 1, max = 100))]
    pub limit: i64,
    #[validate(range(min = 0))]
    pub offset: i64,
}

impl Default for PaginationParams {
    fn default() -> Self {
        Self {
            limit: 10,
            offset: 0,
        }
    }
}

#[derive(Clone, Debug, Deserialize, Serialize, Validate)]
pub struct UpdateUserOptions {
    #[validate(length(
        min = 3,
        max = 50,
        message = "username length must be between 3 and 50 characters"
    ))]
    pub username: Option<String>,
    #[validate(length(
        min = 6,
        max = 50,
        message = "password length must be between 8 and 50 characters"
    ))]
    pub password: Option<String>,
}

#[derive(Debug, Deserialize, Serialize)]
pub struct PaginatedUsers {
    pub users: Vec<User>,
    pub total_count: i64,
}
