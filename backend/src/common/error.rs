use axum::{
    Json,
    http::StatusCode,
    response::{IntoResponse, Response},
};
use serde::{Deserialize, Serialize};
use std::env;
use thiserror::Error;
use validator::ValidationErrors;

#[derive(Debug, Error)]
pub enum AppError {
    #[error("not found: {0}")]
    NotFound(String),

    #[error("unauthorized: {0}")]
    Unauthorized(String),

    #[error("forbidden: {0}")]
    Forbidden(String),

    #[error("bad request: {0}")]
    BadRequest(String),

    #[error("internal server error")]
    InternalServerError,

    #[error("database error: {0}")]
    DatabaseError(String),

    #[error("validation error: {0}")]
    ValidationError(String),

    #[error("password hash error: {0}")]
    PasswordHashError(#[from] argon2::password_hash::Error),

    #[error("password error: {0}")]
    PasswordError(String),

    #[error("sql error: {0}")]
    SqlxError(#[from] sqlx::Error),

    #[error("jwt error: {0}")]
    JwtError(#[from] jwt_simple::Error),

    #[error("io error: {0}")]
    IOError(#[from] std::io::Error),

    #[error("user existed: {0}")]
    UserExisted(String),

    #[error("cache error: {0}")]
    CacheError(String),
}

impl From<ValidationErrors> for AppError {
    fn from(errors: ValidationErrors) -> Self {
        let errors = errors
            .field_errors()
            .iter()
            .flat_map(|(_, errors)| {
                errors.iter().map(|error| {
                    if let Some(message) = &error.message {
                        message.clone().into_owned()
                    } else {
                        "Invalid value".to_string()
                    }
                })
            })
            .collect::<Vec<String>>()
            .join(", ");
        AppError::ValidationError(errors)
    }
}
#[derive(Debug, Deserialize, Serialize)]
pub struct ErrorOutput {
    pub error: String,
}

impl IntoResponse for AppError {
    fn into_response(self) -> Response {
        let is_production = env::var("RUST_ENV").unwrap_or_default() == "production";
        
        let (status, client_msg) = match &self {
            // Client errors (4xx)
            Self::NotFound(_) => (StatusCode::NOT_FOUND, self.to_string()),
            Self::Unauthorized(_) => (StatusCode::UNAUTHORIZED, self.to_string()),
            Self::Forbidden(_) => (StatusCode::FORBIDDEN, self.to_string()),
            Self::BadRequest(_) => (StatusCode::BAD_REQUEST, self.to_string()),
            Self::ValidationError(_) => (StatusCode::UNPROCESSABLE_ENTITY, self.to_string()),
            Self::PasswordError(_) => (StatusCode::UNAUTHORIZED, "Invalid credentials".to_string()),
            Self::UserExisted(_) => (StatusCode::CONFLICT, self.to_string()),
            Self::JwtError(_) => (StatusCode::UNAUTHORIZED, "Invalid or expired token".to_string()),
            
            // Server errors (5xx) - hide details in production
            Self::InternalServerError => (
                StatusCode::INTERNAL_SERVER_ERROR,
                "Internal server error".to_string(),
            ),
            Self::DatabaseError(msg) => (
                StatusCode::INTERNAL_SERVER_ERROR,
                if is_production {
                    "Database error occurred".to_string()
                } else {
                    format!("database error: {}", msg)
                },
            ),
            Self::SqlxError(e) => (
                StatusCode::INTERNAL_SERVER_ERROR,
                if is_production {
                    "Database error occurred".to_string()
                } else {
                    format!("sql error: {}", e)
                },
            ),
            Self::PasswordHashError(e) => (
                StatusCode::INTERNAL_SERVER_ERROR,
                if is_production {
                    "Authentication error".to_string()
                } else {
                    format!("password hash error: {}", e)
                },
            ),
            Self::IOError(e) => (
                StatusCode::INTERNAL_SERVER_ERROR,
                if is_production {
                    "Server error occurred".to_string()
                } else {
                    format!("io error: {}", e)
                },
            ),
            Self::CacheError(msg) => (
                StatusCode::INTERNAL_SERVER_ERROR,
                if is_production {
                    "Cache error occurred".to_string()
                } else {
                    format!("cache error: {}", msg)
                },
            ),
        };

        // Log the actual error for debugging
        tracing::error!("Error occurred: {:?}", self);

        (status, Json(ErrorOutput::new(client_msg))).into_response()
    }
}

impl ErrorOutput {
    pub fn new(error: impl Into<String>) -> Self {
        Self {
            error: error.into(),
        }
    }
}
