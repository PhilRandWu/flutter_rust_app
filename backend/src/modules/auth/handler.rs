use crate::AppState;
use crate::common::error::AppError;
use crate::modules::auth::dto::{TokenRequest, TokenResponse};
use crate::modules::users::dto::CreateUser;
use axum::Json;
use axum::extract::State;
use axum::http::StatusCode;
use axum::response::IntoResponse;
use serde::Serialize;
use tracing::info;
use validator::Validate;

#[derive(Serialize)]
pub struct HealthCheckResponse {
    pub message: &'static str,
}

pub async fn health_check_handler(
    State(_state): State<AppState>,
) -> Result<impl IntoResponse, AppError> {
    const MESSAGE: &str = "How to Implement Two-Factor Authentication (2FA) in Rust";

    Ok((
        StatusCode::OK,
        Json(HealthCheckResponse { message: MESSAGE }),
    ))
}

pub async fn signup_handler(
    State(state): State<AppState>,
    Json(payload): Json<CreateUser>,
) -> Result<impl IntoResponse, AppError> {
    payload.validate()?;
    info!("Auth Handler::create user: input: {:?}", payload);
    let user = state.create_user(payload).await?;
    Ok((StatusCode::CREATED, Json(user)))
}

pub async fn signin_handler(
    State(state): State<AppState>,
    Json(payload): Json<TokenRequest>,
) -> Result<impl IntoResponse, AppError> {
    payload.validate()?;
    info!("Auth Handler::get token: username: {:?}", payload.username);
    let token = state.get_token(&payload.username, &payload.password).await?;
    Ok((StatusCode::OK, Json(token)))
}
