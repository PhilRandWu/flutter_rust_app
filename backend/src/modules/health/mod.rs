use crate::AppState;
use crate::modules::health::handlers::{health_check_handler, liveness_check, readiness_check};
use axum::{Router, routing::get};

pub mod handlers;

pub fn health_router(state: AppState) -> Router {
    Router::new()
        .route("/health", get(health_check_handler))
        .route("/health/live", get(liveness_check))
        .route("/health/ready", get(readiness_check))
        .with_state(state)
}
