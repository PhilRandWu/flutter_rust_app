use axum::extract::State;
use crate::AppState;
use axum::Router;
use axum::routing::get;

pub fn users_router(state: AppState) -> Router {
    Router::new()
        .route("/", get(get_users_handler))
        .with_state(state)
}

async fn get_users_handler(State(_state): State<AppState>) -> &'static str {
    "get users: [user1, user2, user3]"
}
