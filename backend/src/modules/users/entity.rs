use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::{FromRow, Type};
use uuid::Uuid;

#[derive(Clone, Debug, Deserialize, FromRow, Serialize, Type)]
pub struct UserInfo {
    pub id: Option<Uuid>,
    pub username: String,
    #[serde(skip)]
    pub password: String,
    pub email: String,
    pub avatar: Option<String>,
    pub is_deleted: bool,

    pub created_at: Option<DateTime<Utc>>,
    pub updated_at: Option<DateTime<Utc>>,
}

#[derive(Clone, Debug, Deserialize, FromRow, Serialize, Type)]
pub struct UserOtp {
    pub user_id: Uuid,
    pub otp_verified: bool,
    pub otp_base32: String,
    pub otp_auth_url: String,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Clone, Debug, Deserialize, FromRow, Serialize, Type)]
pub struct Role {
    pub id: i32,
    pub name: String,
    pub description: Option<String>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Clone, Debug, Deserialize, FromRow, Serialize, Type)]
pub struct UserRole {
    pub user_id: Uuid,
    pub role_id: i32,
    pub created_at: DateTime<Utc>,
}
