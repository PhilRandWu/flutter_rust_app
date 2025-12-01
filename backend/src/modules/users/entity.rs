use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::FromRow;
use uuid::Uuid;

#[derive(Clone, Debug, Deserialize, FromRow, Serialize)]
pub struct UserInfo {
    pub id: Option<Uuid>,
    pub username: String,
    #[sqlx(default)]
    #[serde(skip)]
    pub password: String,

    pub otp_enabled: Option<bool>,
    pub otp_verified: Option<bool>,
    pub otp_base32: Option<String>,
    pub otp_auth_url: Option<String>,

    pub created_at: Option<DateTime<Utc>>,
    pub updated_at: Option<DateTime<Utc>>,
}
