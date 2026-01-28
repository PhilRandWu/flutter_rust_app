use crate::AppState;
use crate::common::error::AppError;
use crate::modules::auth::dto::{LogoutRequest, LogoutResponse, TokenRequest};
use crate::modules::users::dto::CreateUser;
use axum::{Json, extract::State, http::StatusCode, response::IntoResponse};
use serde::Serialize;
use tracing::{info, error, warn};
use validator::Validate;

#[derive(Serialize)]
pub struct HealthCheckResponse {
    pub message: &'static str,
}

pub async fn signup_handler(
    State(state): State<AppState>,
    Json(payload): Json<CreateUser>,
) -> Result<impl IntoResponse, AppError> {
    payload.validate()?;
    info!("Auth Handler::signup: username: {:?}", payload.username);
    
    match state.create_user(payload).await {
        Ok(user) => {
            info!("Auth Handler::signup: user created successfully with id: {:?}", user.user_info.id);
            Ok((StatusCode::CREATED, Json(user)))
        }
        Err(e) => {
            error!("Auth Handler::signup: failed to create user: {:?}", e);
            Err(e)
        }
    }
}

pub async fn signing_handler(
    State(state): State<AppState>,
    Json(payload): Json<TokenRequest>,
) -> Result<impl IntoResponse, AppError> {
    payload.validate()?;
    info!("Auth Handler::signing: username: {:?}", payload.username);
    
    match state.get_token(&payload.username, &payload.password).await {
        Ok(token) => {
            info!("Auth Handler::signing: login successful for user: {:?}", payload.username);
            Ok((StatusCode::OK, Json(token)))
        }
        Err(e) => {
            warn!("Auth Handler::signing: login failed for user: {:?}, error: {:?}", payload.username, e);
            Err(e)
        }
    }
}

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
