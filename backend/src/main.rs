use anyhow::Result;
use axum::http::{HeaderName, Method};
use backend::{AppState, get_router};
use std::str::FromStr;
use tokio::net::TcpListener;
use tower_http::cors::{AllowHeaders, AllowMethods, AllowOrigin, CorsLayer};
use tracing::info;
use tracing_appender::rolling;
use tracing_subscriber::{EnvFilter, Layer, fmt, layer::SubscriberExt, util::SubscriberInitExt};

#[tokio::main]
async fn main() -> Result<()> {
    let log_level = std::env::var("RUST_LOG").unwrap_or_else(|_| "info".to_string());
    let env_filter = EnvFilter::from_default_env().add_directive(log_level.parse()?);
    let stdout_log = fmt::layer()
        .with_writer(std::io::stderr)
        .with_filter(env_filter.clone());

    let file_appender = rolling::daily("logs", "app.log");
    let (non_blocking, _guard) = tracing_appender::non_blocking(file_appender);
    let file_log = fmt::layer()
        .with_writer(non_blocking)
        .with_filter(env_filter);

    tracing_subscriber::registry()
        .with(stdout_log)
        .with(file_log)
        .init();

    let state = AppState::init_state().await?;
    let app = get_router(state.clone()).await?;

    let allowed_methods = state
        .config
        .cors
        .allowed_methods
        .iter()
        .map(|s| Method::from_str(s))
        .collect::<Result<Vec<_>, _>>()?;

    let allowed_headers = state
        .config
        .cors
        .allowed_headers
        .iter()
        .map(|s| HeaderName::from_str(s))
        .collect::<Result<Vec<_>, _>>()?;

    let cors_layer = CorsLayer::new()
        .allow_origin(AllowOrigin::exact(state.config.cors.origin.parse()?))
        .allow_methods(AllowMethods::list(allowed_methods))
        .allow_headers(AllowHeaders::list(allowed_headers))
        .allow_credentials(true);

    let app = app.layer(cors_layer);

    let addr = format!("0.0.0.0:{}", &state.config.server.port);
    let listener = TcpListener::bind(&addr).await?;
    info!("Listening on: {}", addr);
    axum::serve(listener, app.into_make_service()).await?;

    Ok(())
}
