use anyhow::Result;
use axum::http;
use axum::http::HeaderName;
use backend::{AppState, get_router};
use tokio::net::TcpListener;
use tower_http::cors::{AllowHeaders, AllowMethods, AllowOrigin, CorsLayer};
use tracing::info;
use tracing_appender::rolling;
use tracing_subscriber::layer::SubscriberExt;
use tracing_subscriber::util::SubscriberInitExt;
use tracing_subscriber::{EnvFilter, Layer, fmt};

#[tokio::main]
async fn main() -> Result<()> {
    let env_filter = EnvFilter::from_default_env().add_directive(tracing::Level::INFO.into());
    let stdout_log = fmt::layer()
        .with_writer(std::io::stderr)
        .with_filter(env_filter);

    let env_filter = EnvFilter::from_default_env().add_directive(tracing::Level::INFO.into());
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

    let cors_layer = CorsLayer::new()
        .allow_origin(AllowOrigin::exact("http://localhost:56996".parse()?))
        .allow_methods(AllowMethods::list([
            http::Method::GET,
            http::Method::POST,
            http::Method::PUT,
            http::Method::DELETE,
            http::Method::OPTIONS, 
            http::Method::PATCH,   
        ]))
        .allow_headers(AllowHeaders::list([
            HeaderName::from_static("content-type"),
            HeaderName::from_static("authorization"),
            HeaderName::from_static("x-requested-with"),
            HeaderName::from_static("accept"),
        ]))
        .allow_credentials(true);

    let app = app.layer(cors_layer);

    let addr = format!("0.0.0.0:{}", &state.config.server.port);
    let listener = TcpListener::bind(&addr).await?;
    axum::serve(listener, app.into_make_service()).await?;
    info!("Listening on: {}", addr);

    Ok(())
}
