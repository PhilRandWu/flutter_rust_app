use crate::AppState;
use crate::common::error::AppError;
use crate::modules::auth::dto::{LogoutRequest, LogoutResponse, TokenRequest};
use crate::modules::users::dto::CreateUser;
use axum::{Json, extract::State, http::StatusCode, response::IntoResponse};
use serde::Serialize;
use tracing::{error, info, warn};
use validator::Validate;

/// Health check response structure
#[derive(Serialize)]
pub struct HealthCheckResponse {
    /// Response message
    pub message: &'static str,
}

/// User signup handler
/// 
/// ## HTTP Method
/// POST
/// 
/// ## Path
/// /auth/signup
/// 
/// ## Request Body
/// ```json
/// {
///   "username": "string",
///   "password": "string",
///   "email": "string | null",
///   "avatar": "string | null"
/// }
/// ```
/// 
/// ## Response
/// - **201 Created** - User created successfully
///   ```json
///   {
///     "user_info": {
///       "id": "uuid",
///       "username": "string",
///       "email": "string | null",
///       "avatar": "string | null",
///       "created_at": "datetime",
///       "updated_at": "datetime"
///     }
///   }
///   ```
/// - **400 Bad Request** - Invalid input
/// - **409 Conflict** - User already exists
/// - **500 Internal Server Error** - Server error
pub async fn signup_handler(
    State(state): State<AppState>,
    Json(payload): Json<CreateUser>,
) -> Result<impl IntoResponse, AppError> {
    payload.validate()?;
    info!("Auth Handler::signup: username: {:?}", payload.username);

    match state.create_user(payload).await {
        Ok(user) => {
            info!(
                "Auth Handler::signup: user created successfully with id: {:?}",
                user.user_info.id
            );
            Ok((StatusCode::CREATED, Json(user)))
        }
        Err(e) => {
            error!("Auth Handler::signup: failed to create user: {:?}", e);
            Err(e)
        }
    }
}

/// User login handler
/// 
/// ## HTTP Method
/// POST
/// 
/// ## Path
/// /auth/login
/// 
/// ## Request Body
/// ```json
/// {
///   "username": "string",
///   "password": "string"
/// }
/// ```
/// 
/// ## Response
/// - **200 OK** - Login successful
///   ```json
///   {
///     "access_token": "string",
///     "refresh_token": "string",
///     "expires_in": 86400
///   }
///   ```
/// - **400 Bad Request** - Invalid input
/// - **401 Unauthorized** - Invalid credentials
/// - **500 Internal Server Error** - Server error
pub async fn login_handler(
    State(state): State<AppState>,
    Json(payload): Json<TokenRequest>,
) -> Result<impl IntoResponse, AppError> {
    payload.validate()?;
    info!("Auth Handler::signing: username: {:?}", payload.username);

    match state.get_token(&payload.username, &payload.password).await {
        Ok(token) => {
            info!(
                "Auth Handler::signing: login successful for user: {:?}",
                payload.username
            );
            Ok((StatusCode::OK, Json(token)))
        }
        Err(e) => {
            warn!(
                "Auth Handler::signing: login failed for user: {:?}, error: {:?}",
                payload.username, e
            );
            Err(e)
        }
    }
}

/// User logout handler
/// 
/// ## HTTP Method
/// POST
/// 
/// ## Path
/// /auth/logout
/// 
/// ## Request Body
/// ```json
/// {
///   "refresh_token": "string"
/// }
/// ```
/// 
/// ## Response
/// - **200 OK** - Logout successful
///   ```json
///   {
///     "message": "Logout successful"
///   }
///   ```
/// - **400 Bad Request** - Invalid input
/// - **401 Unauthorized** - Invalid refresh token
/// - **500 Internal Server Error** - Server error
pub async fn logout_handler(
    State(state): State<AppState>,
    Json(payload): Json<LogoutRequest>,
) -> Result<impl IntoResponse, AppError> {
    payload.validate()?;
    info!("Auth Handler::logout: processing logout request");

    match state.logout(&payload.refresh_token).await {
        Ok(_) => {
            info!("Auth Handler::logout: logout successful");
            Ok((StatusCode::OK, Json(LogoutResponse::new())))
        }
        Err(e) => {
            warn!("Auth Handler::logout: logout failed: {:?}", e);
            Err(e)
        }
    }
}
