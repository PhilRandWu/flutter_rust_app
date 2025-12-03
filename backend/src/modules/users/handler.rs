use crate::AppState;
use axum::Router;

pub fn users_router(state: AppState) -> Router {
    Router::new()
        .with_state(state)
}
