use crate::common::config::AppConfig;
use crate::common::error::AppError;
use crate::modules::auth::auth_router;
use crate::modules::users::handler::users_router;
use anyhow::Result;
use axum::Router;
use sqlx::PgPool;
use std::ops::Deref;
use std::sync::Arc;

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

#[cfg(test)]
mod test_util {
    use crate::common::config::AppConfig;
    use crate::common::error::AppError;
    use crate::{AppState, AppStateInner};
    use sqlx::{Executor, PgPool};
    use sqlx_db_tester::TestPg;
    use std::sync::Arc;

    impl AppState {
        pub async fn init_test_state() -> Result<(TestPg, AppState), AppError> {
            let config = AppConfig::from_file("app.yaml");
            let db_url = config.database.db_url.clone();
            let tdb = TestPg::new(db_url, std::path::Path::new("./migrations"));
            let pool = tdb.get_pool().await;

            let sql = include_str!("../fixtures/test_data.sql").split(';');
            let mut ts = pool.begin().await.expect("begin transaction failed");
            for s in sql {
                if s.trim().is_empty() {
                    continue;
                }
                ts.execute(s).await.expect("execute failed");
            }
            ts.commit().await.expect("commit transaction failed");
            let state = Self {
                inner: Arc::new(AppStateInner { config, pool }),
            };
            Ok((tdb, state))
        }
    }
}
