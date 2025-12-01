use crate::AppState;
use crate::common::error::AppError;
use axum::extract::State;
use axum::http::StatusCode;
use axum::response::IntoResponse;
use axum::routing::get;
use axum::{Extension, Json, Router};
use serde_json::json;

pub fn users_router(state: AppState) -> Router {
    Router::new()
        // 基础接口
        // .route("/health", get(health_check_handler))
        // .route("/auth/register", post(register_handler))
        // .route("/auth/login", post(login_handler))
        // // 2FA 相关接口
        // .route("/auth/otp/generate", post(generate_otp_handler))
        // .route("/auth/otp/verify", post(verify_otp_handler))
        // .route("/auth/otp/validate", post(validate_otp_handler))
        // .route("/auth/otp/disable", post(disable_otp_handler))
        .with_state(state)
}
