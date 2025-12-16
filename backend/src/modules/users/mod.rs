pub mod dto;
mod entity;
pub mod handlers;
mod services;

use crate::AppState;
use crate::modules::users::handlers::{
    delete_user_handler, get_user_handler, get_users_handler, update_user_handler,
};
use axum::{Router, routing::get};

pub fn users_router(state: AppState) -> Router {
    Router::new()
        .route("/", get(get_users_handler))
        .route(
            "/{id}",
            get(get_user_handler)
                .delete(delete_user_handler),
        )
        .with_state(state)
}
