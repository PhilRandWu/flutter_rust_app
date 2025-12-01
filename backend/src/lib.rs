use crate::common::config::AppConfig;
use crate::common::error::AppError;
use crate::modules::users::handler::users_router;
use anyhow::Result;
use axum::Router;
use sqlx::PgPool;
use std::ops::Deref;
use std::sync::Arc;
use crate::modules::auth::auth_router;

pub mod common;
pub mod modules;

pub async fn get_router(state: AppState) -> Result<Router, AppError> {
    let router = Router::new()
        .nest("/users", users_router(state.clone()))
        // .layer(from_fn_with_state(state.clone(), auth_middleware))
        .nest("/auth", auth_router(state.clone()));
    Ok(router)
}

#[derive(Clone, Debug)]
pub struct AppStateInner {
    pub config: AppConfig,
    pub pool: PgPool,
}

#[derive(Clone, Debug)]
pub struct AppState {
    inner: Arc<AppStateInner>,
}

impl AppState {
    pub fn new(config: AppConfig, pool: PgPool) -> Self {
        Self {
            inner: Arc::new(AppStateInner { config, pool }),
        }
    }

    pub async fn init_state() -> Result<AppState> {
        let config = AppConfig::from_file("app.yaml");
        let pool = PgPool::connect(&config.database.db_url).await?;
        let state = AppState::new(config, pool);
        Ok(state)
    }
}

impl Deref for AppState {
    type Target = AppStateInner;

    fn deref(&self) -> &Self::Target {
        &self.inner
    }
}
