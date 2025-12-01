use serde::{Deserialize, Serialize};
use validator::Validate;
use crate::modules::users::entity::UserInfo;

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

#[derive(Clone, Debug, Deserialize, Serialize)]
pub struct User {
    pub user_info: UserInfo,
}

impl User {
    pub fn new(user_info: UserInfo) -> Self {
        Self {
            user_info,
        }
    }
}