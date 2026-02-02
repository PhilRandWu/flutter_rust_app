use crate::AppState;
use crate::common::error::AppError;
use axum::{Json, extract::State, http::StatusCode, response::IntoResponse};
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use std::sync::OnceLock;
use tokio::time::Instant;
use tracing::{error, info};

const APP_VERSION: &str = env!("CARGO_PKG_VERSION");
static APP_START_TIME: OnceLock<Instant> = OnceLock::new();

fn get_app_start_time() -> &'static Instant {
    APP_START_TIME.get_or_init(Instant::now)
}

#[derive(Debug, Serialize, Deserialize)]
pub struct HealthResponse {
    pub status: String,
    pub timestamp: DateTime<Utc>,
    pub uptime_seconds: u64,
    pub version: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct LivenessResponse {
    pub status: String,
    pub timestamp: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct DatabaseStatus {
    pub status: String,
    pub response_time_as: Option<u64>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct ReadinessResponse {
    pub status: String,
    pub timestamp: DateTime<Utc>,
    pub database: DatabaseStatus,
    pub uptime_seconds: u64,
}

/// General health check
/// 
/// ## HTTP Method
/// GET
/// 
/// ## Path
/// /health
/// 
/// ## Response
/// - **200 OK** - Server is healthy
///   ```json
///   {
///     "status": "healthy",
///     "timestamp": "datetime",
///     "uptime_seconds": 3600,
///     "version": "1.0.0"
///   }
///   ```
/// - **500 Internal Server Error** - Server error
pub async fn health_check_handler(State(_state): State<AppState>) -> impl IntoResponse {
    info!("Health check endpoint accessed");

    let response = HealthResponse {
        status: "healthy".to_string(),
        timestamp: Utc::now(),
        uptime_seconds: get_app_start_time().elapsed().as_secs(),
        version: APP_VERSION.to_string(),
    };

    (StatusCode::OK, Json(response))
}

/// Liveness check
/// 
/// ## HTTP Method
/// GET
/// 
/// ## Path
/// /health/live
/// 
/// ## Response
/// - **200 OK** - Server process is alive
///   ```json
///   {
///     "status": "alive",
///     "timestamp": "datetime"
///   }
///   ```
pub async fn liveness_check(State(_state): State<AppState>) -> impl IntoResponse {
    info!("Liveness check endpoint accessed");

    let response = LivenessResponse {
        status: "alive".to_string(),
        timestamp: Utc::now(),
    };

    (StatusCode::OK, Json(response))
}

/// Readiness check
/// 
/// ## HTTP Method
/// GET
/// 
/// ## Path
/// /health/ready
/// 
/// ## Response
/// - **200 OK** - Server is ready to accept requests
///   ```json
///   {
///     "status": "ready",
///     "timestamp": "datetime",
///     "database": {
///       "status": "healthy",
///       "response_time_as": 100
///     },
///     "uptime_seconds": 3600
///   }
///   ```
/// - **503 Service Unavailable** - Server is not ready
///   ```json
///   {
///     "status": "not_ready",
///     "timestamp": "datetime",
///     "database": {
///       "status": "unhealthy",
///       "response_time_as": 100
///     },
///     "uptime_seconds": 3600
///   }
///   ```
pub async fn readiness_check(State(state): State<AppState>) -> Result<impl IntoResponse, AppError> {
    info!("Readiness check endpoint accessed");
    let db_start = Instant::now();
    let db_status = match sqlx::query("SELECT 1").fetch_one(&state.pool).await {
        Ok(_) => DatabaseStatus {
            status: "healthy".to_string(),
            response_time_as: Some(db_start.elapsed().as_millis() as u64),
        },
        Err(e) => {
            error!("Database health check failed: {:?}", e);
            DatabaseStatus {
                status: "unhealthy".to_string(),
                response_time_as: Some(db_start.elapsed().as_millis() as u64),
            }
        }
    };

    let status = if db_status.status == "healthy" {
        "ready"
    } else {
        "not_ready"
    };

    let response = ReadinessResponse {
        status: status.to_string(),
        timestamp: Utc::now(),
        database: db_status,
        uptime_seconds: get_app_start_time().elapsed().as_secs(),
    };

    let status_code = if status == "ready" {
        StatusCode::OK
    } else {
        StatusCode::SERVICE_UNAVAILABLE
    };

    Ok((status_code, Json(response)))
}
