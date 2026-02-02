use crate::AppState;
use crate::common::error::AppError;
use crate::modules::users::dto::{PaginationParams, UpdateUserOptions, User};
use axum::{
    Extension, Json,
    extract::{Path, Query, State},
    http::StatusCode,
    response::IntoResponse,
};
use tracing::{error, info, warn};
use uuid::Uuid;
use validator::Validate;

/// Get current user profile
/// 
/// ## HTTP Method
/// GET
/// 
/// ## Path
/// /users/me
/// 
/// ## Authentication
/// Requires valid JWT access token in Authorization header
/// 
/// ## Response
/// - **200 OK** - User profile retrieved successfully
///   ```json
///   {
///     "user_info": {
///       "id": "uuid",
///       "username": "string",
///       "email": "string | null",
///       "avatar": "string | null",
///       "created_at": "datetime",
///       "updated_at": "datetime"
///     }
///   }
///   ```
/// - **401 Unauthorized** - Invalid or missing token
/// - **500 Internal Server Error** - Server error
pub async fn get_me_handler(
    Extension(claims): Extension<User>,
) -> Result<impl IntoResponse, AppError> {
    info!("Users Handler::get me: user_id: {:?}", claims.user_info.id);
    Ok((StatusCode::OK, Json(claims)))
}

/// Get paginated list of users
/// 
/// ## HTTP Method
/// GET
/// 
/// ## Path
/// /users
/// 
/// ## Query Parameters
/// - `limit`: Number of users per page (1-100, default: 10)
/// - `offset`: Number of users to skip (default: 0)
/// 
/// ## Authentication
/// Requires valid JWT access token in Authorization header
/// 
/// ## Response
/// - **200 OK** - Users retrieved successfully
///   ```json
///   {
///     "users": [
///       {
///         "user_info": {
///           "id": "uuid",
///           "username": "string",
///           "email": "string | null",
///           "avatar": "string | null",
///           "created_at": "datetime",
///           "updated_at": "datetime"
///         }
///       }
///     ],
///     "total_count": 100
///   }
///   ```
/// - **400 Bad Request** - Invalid pagination parameters
/// - **401 Unauthorized** - Invalid or missing token
/// - **500 Internal Server Error** - Server error
pub async fn get_users_handler(
    Extension(claims): Extension<User>,
    State(state): State<AppState>,
    Query(params): Query<PaginationParams>,
) -> Result<impl IntoResponse, AppError> {
    params.validate()?;
    info!(
        "Users Handler::get users: requested by user_id: {:?}",
        claims.user_info.id
    );
    let PaginationParams { limit, offset } = params;

    match state.get_users(limit, offset).await {
        Ok(paginated_users) => {
            info!(
                "Users Handler::get users: successfully retrieved {} users",
                paginated_users.users.len()
            );
            Ok((StatusCode::OK, Json(paginated_users)))
        }
        Err(e) => {
            error!(
                "Users Handler::get users: failed to retrieve users: {:?}",
                e
            );
            Err(e)
        }
    }
}

/// Update current user profile
/// 
/// ## HTTP Method
/// PATCH
/// 
/// ## Path
/// /users/me
/// 
/// ## Authentication
/// Requires valid JWT access token in Authorization header
/// 
/// ## Request Body
/// ```json
/// {
///   "username": "string | null",
///   "password": "string | null",
///   "email": "string | null",
///   "avatar": "string | null"
/// }
/// ```
/// 
/// ## Response
/// - **200 OK** - Profile updated successfully
///   ```json
///   {
///     "user_info": {
///       "id": "uuid",
///       "username": "string",
///       "email": "string | null",
///       "avatar": "string | null",
///       "created_at": "datetime",
///       "updated_at": "datetime"
///     }
///   }
///   ```
/// - **400 Bad Request** - Invalid input
/// - **401 Unauthorized** - Invalid or missing token
/// - **409 Conflict** - Username already taken
/// - **500 Internal Server Error** - Server error
pub async fn update_me_handler(
    Extension(claims): Extension<User>,
    State(state): State<AppState>,
    Json(input): Json<UpdateUserOptions>,
) -> Result<impl IntoResponse, AppError> {
    // 验证输入
    input.validate()?;

    let user_id = claims
        .user_info
        .id
        .ok_or_else(|| AppError::BadRequest("User ID not found".to_string()))?;

    info!("Users Handler::update me: user_id: {:?}", user_id);
    info!("Users Handler::update me: input: {:?}", input);

    // 更新用户资料
    match state.update_user(user_id, input).await {
        Ok(updated_user) => {
            info!(
                "Users Handler::update me: successfully updated user: {:?}",
                user_id
            );
            Ok((StatusCode::OK, Json(updated_user)))
        }
        Err(e) => {
            error!(
                "Users Handler::update me: failed to update user {:?}: {:?}",
                user_id, e
            );
            Err(e)
        }
    }
}

/// Get user by ID
/// 
/// ## HTTP Method
/// GET
/// 
/// ## Path
/// /users/{id}
/// 
/// ## Path Parameters
/// - `id`: User UUID
/// 
/// ## Authentication
/// Requires valid JWT access token in Authorization header
/// 
/// ## Response
/// - **200 OK** - User retrieved successfully
///   ```json
///   {
///     "user_info": {
///       "id": "uuid",
///       "username": "string",
///       "email": "string | null",
///       "avatar": "string | null",
///       "created_at": "datetime",
///       "updated_at": "datetime"
///     }
///   }
///   ```
/// - **400 Bad Request** - Invalid UUID format
/// - **401 Unauthorized** - Invalid or missing token
/// - **404 Not Found** - User not found
/// - **500 Internal Server Error** - Server error
pub async fn get_user_handler(
    Extension(claims): Extension<User>,
    State(state): State<AppState>,
    Path(user_id): Path<Uuid>,
) -> Result<impl IntoResponse, AppError> {
    info!(
        "Users Handler::get user: user_id: {:?}, requested by: {:?}",
        user_id, claims.user_info.id
    );

    match state.get_user_by_id(user_id).await {
        Ok(user) => {
            info!(
                "Users Handler::get user: successfully retrieved user: {:?}",
                user_id
            );
            Ok((StatusCode::OK, Json(user)))
        }
        Err(e) => {
            warn!(
                "Users Handler::get user: failed to retrieve user {:?}: {:?}",
                user_id, e
            );
            Err(e)
        }
    }
}

/// Update user by ID
/// 
/// ## HTTP Method
/// PATCH
/// 
/// ## Path
/// /users/{id}
/// 
/// ## Path Parameters
/// - `id`: User UUID
/// 
/// ## Authentication
/// Requires valid JWT access token in Authorization header
/// 
/// ## Request Body
/// ```json
/// {
///   "username": "string | null",
///   "password": "string | null",
///   "email": "string | null",
///   "avatar": "string | null"
/// }
/// ```
/// 
/// ## Response
/// - **200 OK** - User updated successfully
///   ```json
///   {
///     "user_info": {
///       "id": "uuid",
///       "username": "string",
///       "email": "string | null",
///       "avatar": "string | null",
///       "created_at": "datetime",
///       "updated_at": "datetime"
///     }
///   }
///   ```
/// - **400 Bad Request** - Invalid input or UUID format
/// - **401 Unauthorized** - Invalid or missing token
/// - **403 Forbidden** - Not authorized to update this user
/// - **404 Not Found** - User not found
/// - **409 Conflict** - Username already taken
/// - **500 Internal Server Error** - Server error
pub async fn update_user_handler(
    Extension(claims): Extension<User>,
    State(state): State<AppState>,
    Path(user_id): Path<Uuid>,
    Json(input): Json<UpdateUserOptions>,
) -> Result<impl IntoResponse, AppError> {
    // 验证输入
    input.validate()?;

    // 检查权限：只允许用户修改自己的资料
    if claims.user_info.id != Some(user_id) {
        return Err(AppError::Forbidden(
            "You can only update your own profile".parse().unwrap(),
        ));
    }

    info!(
        "Users Handler::update user: user_id: {:?}, requested by: {:?}",
        user_id, claims.user_info.id
    );
    info!("Users Handler::update user: input: {:?}", input);

    // 更新用户资料
    match state.update_user(user_id, input).await {
        Ok(updated_user) => {
            info!(
                "Users Handler::update user: successfully updated user: {:?}",
                user_id
            );
            Ok((StatusCode::OK, Json(updated_user)))
        }
        Err(e) => {
            error!(
                "Users Handler::update user: failed to update user {:?}: {:?}",
                user_id, e
            );
            Err(e)
        }
    }
}

/// Delete user by ID
/// 
/// ## HTTP Method
/// DELETE
/// 
/// ## Path
/// /users/{id}
/// 
/// ## Path Parameters
/// - `id`: User UUID
/// 
/// ## Authentication
/// Requires valid JWT access token in Authorization header
/// 
/// ## Response
/// - **200 OK** - User deleted successfully
/// - **400 Bad Request** - Invalid UUID format
/// - **401 Unauthorized** - Invalid or missing token
/// - **404 Not Found** - User not found
/// - **500 Internal Server Error** - Server error
pub async fn delete_user_handler(
    Extension(claims): Extension<User>,
    State(state): State<AppState>,
    Path(user_id): Path<Uuid>,
) -> Result<impl IntoResponse, AppError> {
    info!(
        "Users Handler::delete user: user_id: {:?}, requested by: {:?}",
        user_id, claims.user_info.id
    );

    match state.delete_user(user_id).await {
        Ok(_) => {
            info!(
                "Users Handler::delete user: successfully deleted user: {:?}",
                user_id
            );
            Ok(StatusCode::OK)
        }
        Err(e) => {
            error!(
                "Users Handler::delete user: failed to delete user {:?}: {:?}",
                user_id, e
            );
            Err(e)
        }
    }
}
