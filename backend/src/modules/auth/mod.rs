use axum::{Router, routing::{get, post}};
use crate::AppState;
use crate::modules::auth::handler::{signin_handler, signup_handler};

pub mod handler;
pub mod service;
mod dto;
mod tests;
pub mod middleware;

pub fn auth_router(state: AppState) -> Router {
    Router::new()
        .route("/signup", post(signup_handler))
        .route("/signin", post(signin_handler))
        .with_state(state)
}
