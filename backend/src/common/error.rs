use thiserror::Error;

#[derive(Debug, Error)]
pub enum AppError {
  #[error("not found: {0}")]
  NotFound(String),

  #[error("unauthorized: {0}")]
  Unauthorized(String),

  #[error("forbidden: {0}")]
  Forbidden(String),

  #[error("bad request: {0}")]
  BadRequest(String),

  #[error("internal server error")]
  InternalServerError,

  #[error("database error: {0}")]
  DatabaseError(String),

  #[error("validation error: {0}")]
  ValidationError(String),
}