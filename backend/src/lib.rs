use crate::{
    common::{config::AppConfig, error::AppError},
    modules::{
        auth::{auth_router, middleware::auth_middleware},
        health::health_router,
        users::users_router,
    },
};
use anyhow::Result;
use axum::{Router, middleware::from_fn_with_state};
use jwt_simple::prelude::{Ed25519KeyPair, Ed25519PublicKey};
use sqlx::PgPool;
use std::{fmt, fs, ops::Deref, sync::Arc};

pub mod common;
pub mod modules;

pub async fn get_router(state: AppState) -> Result<Router, AppError> {
    let api_router = Router::new()
        .nest("/users", users_router(state.clone()))
        .layer(from_fn_with_state(state.clone(), auth_middleware));

    let router = Router::new()
        .merge(health_router(state.clone()))
        .nest("/auth", auth_router(state.clone()))
        .merge(api_router);
    Ok(router)
}

#[derive(Clone)]
pub struct AppStateInner {
    pub config: AppConfig,
    pub pool: PgPool,
    pub key_pair: Ed25519KeyPair,
    pub public_key: Ed25519PublicKey,
}

impl fmt::Debug for AppStateInner {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("AppStateInner")
            .field("config", &self.config)
            .field("pool", &self.pool)
            .field("key_pair", &"[REDACTED]")
            .field("public_key", &self.public_key)
            .finish()
    }
}

#[derive(Clone, Debug)]
pub struct AppState {
    inner: Arc<AppStateInner>,
}

impl AppState {
    pub fn new(
        config: AppConfig,
        pool: PgPool,
        key_pair: Ed25519KeyPair,
        public_key: Ed25519PublicKey,
    ) -> Self {
        Self {
            inner: Arc::new(AppStateInner {
                config,
                pool,
                key_pair,
                public_key,
            }),
        }
    }

    pub async fn init_state() -> Result<AppState> {
        let config = AppConfig::from_file("app.yaml");
        let pool = PgPool::connect(&config.database.db_url).await?;

        let secret_key_pem = fs::read_to_string(&config.auth.secret_key)?;
        let key_pair = Ed25519KeyPair::from_pem(&secret_key_pem)?;

        let public_key_pem = fs::read_to_string(&config.auth.public_key)?;
        let public_key = Ed25519PublicKey::from_pem(&public_key_pem)?;

        let state = AppState::new(config, pool, key_pair, public_key);
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
    use jwt_simple::prelude::{Ed25519KeyPair, Ed25519PublicKey};
    use sqlx::Executor;
    use sqlx_db_tester::TestPg;
    use std::{fs, sync::Arc};

    impl AppState {
        pub async fn init_test_state() -> Result<(TestPg, AppState), AppError> {
            let config = AppConfig::from_file("app.yaml");
            let db_url = config.database.db_url.clone();
            let tdb = TestPg::new(db_url, std::path::Path::new("./migrations"));
            let pool = tdb.get_pool().await;

            let secret_key_pem = fs::read_to_string(&config.auth.secret_key)?;
            let key_pair = Ed25519KeyPair::from_pem(&secret_key_pem)?;

            let public_key_pem = fs::read_to_string(&config.auth.public_key)?;
            let public_key = Ed25519PublicKey::from_pem(&public_key_pem)?;

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
                inner: Arc::new(AppStateInner {
                    config,
                    pool,
                    key_pair,
                    public_key,
                }),
            };
            Ok((tdb, state))
        }
    }
}
