use crate::AppState;
use crate::common::error::AppError;
use crate::modules::users::dto::{PaginationParams, UpdateUserOptions, User};
use axum::{
    Extension, Json,
    extract::{Path, Query, State},
    http::StatusCode,
    response::IntoResponse,
};
use tracing::info;
use validator::Validate;

pub async fn get_users_handler(
    Extension(claims): Extension<User>,
    State(state): State<AppState>,
    Query(params): Query<PaginationParams>,
) -> Result<impl IntoResponse, AppError> {
    params.validate()?;
    info!("Users Handler::get users");
    info!(
        "Users Handler::get users: claims user_id: {:?}",
        claims.user_info.id
    );
    let PaginationParams { limit, offset } = params;
    let users = state.get_users(limit, offset).await?;
    Ok((StatusCode::OK, Json(users)))
}

pub async fn get_user_handler(
    Extension(claims): Extension<User>,
    State(state): State<AppState>,
    Path(user_id): Path<i32>,
) -> Result<impl IntoResponse, AppError> {
    info!("Users Handler::get user: user_id: {:?}", user_id);
    info!(
        "Users Handler::get user: claims user_id: {:?}",
        claims.user_info.id
    );
    let user = state.get_user_by_id(user_id).await?;
    Ok((StatusCode::OK, Json(user)))
}

pub async fn update_user_handler(
    Extension(claims): Extension<User>,
    State(state): State<AppState>,
    Path(user_id): Path<i32>,
    Json(input): Json<UpdateUserOptions>,
) -> Result<impl IntoResponse, AppError> {
    // TODO
    // input.validate()?;
    // info!("Users Handler::update user: user_id: {:?}", user_id);
    // info!("Users Handler::update user: input: {:?}", input);
    // let input = UpdateUser::new(input, is_who);
    //
    // let user = state.update_user(user_id, input).await?;
    // Ok((StatusCode::OK, Json(user)))
    Ok(())
}

pub async fn delete_user_handler(
    State(state): State<AppState>,
    Path(user_id): Path<i32>,
) -> Result<impl IntoResponse, AppError> {
    info!("Users Handler::delete user: {:?}", user_id);
    state.delete_user(user_id).await?;
    Ok(StatusCode::OK)
}
