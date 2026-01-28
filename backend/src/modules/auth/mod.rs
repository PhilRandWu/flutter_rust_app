use crate::AppState;
use crate::modules::auth::handlers::{logout_handler, signing_handler, signup_handler};
use axum::{Router, routing::post};

mod dto;
pub mod handlers;
pub mod middleware;
pub mod services;
mod tests;

pub fn auth_router(state: AppState) -> Router {
    Router::new()
        .route("/signup", post(signup_handler))
        .route("/signing", post(signing_handler))
        .route("/logout", post(logout_handler))
        .with_state(state)
}
