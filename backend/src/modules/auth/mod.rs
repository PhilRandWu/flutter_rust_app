use axum::Router;
use axum::routing::{get, post};
use crate::AppState;
use crate::modules::auth::handler::{health_check_handler, signin_handler, signup_handler};

pub mod handler;
pub mod service;
mod dto;

pub fn auth_router(state: AppState) -> Router {
    Router::new()
        .route("/health", get(health_check_handler))
        .route("/signup", post(signup_handler))
        .route("/signin", post(signin_handler))
        .with_state(state)
}
