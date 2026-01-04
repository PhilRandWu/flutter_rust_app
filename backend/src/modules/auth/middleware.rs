use crate::AppState;
use crate::common::auth::verify_access_token;
use axum::{
    body::Body,
    extract::{FromRequestParts, State},
    http::{Request, StatusCode},
    middleware::Next,
    response::IntoResponse,
};
use axum_extra::{
    TypedHeader,
    headers::{Authorization, authorization::Bearer},
};
use tracing::warn;

pub async fn auth_middleware(
    State(state): State<AppState>,
    req: Request<Body>,
    next: Next,
) -> impl IntoResponse {
    let (mut parts, body) = req.into_parts();
    let req = match TypedHeader::<Authorization<Bearer>>::from_request_parts(&mut parts, &state)
        .await
    {
        Ok(TypedHeader(Authorization(Bearer))) => {
            let token = Bearer.token();
            match verify_access_token(&state, token).await {
                Ok(user) => {
                    let mut req = Request::from_parts(parts, body);
                    let user = match state.get_user_by_username(&user.user_info.username).await {
                        Ok(user) => user,
                        Err(e) => {
                            let msg = format!("user not exists or removed: {:?}", e);
                            warn!(msg);
                            return (StatusCode::FORBIDDEN, msg).into_response();
                        }
                    };
                    req.extensions_mut().insert(user);
                    req
                }
                Err(e) => {
                    let msg = format!("verify token failed: {:?}", e);
                    warn!(msg);
                    return (StatusCode::FORBIDDEN, msg).into_response();
                }
            }
        }
        Err(e) => {
            let msg = format!("verify token failed: {:?}", e);
            warn!(msg);
            return (StatusCode::FORBIDDEN, msg).into_response();
        }
    };
    next.run(req).await
}
