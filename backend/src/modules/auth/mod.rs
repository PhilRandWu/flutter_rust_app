use axum::{Router, routing::{post}};
use crate::AppState;
use crate::modules::auth::handlers::{signing_handler, signup_handler};

pub mod handlers;
pub mod services;
mod dto;
mod tests;
pub mod middleware;

pub fn auth_router(state: AppState) -> Router {
    Router::new()
        .route("/signup", post(signup_handler))
        .route("/signing", post(signing_handler))
        .with_state(state)
}
