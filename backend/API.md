# API Documentation

Base URL: `http://localhost:3009`

## Table of Contents

- [Authentication](#authentication)
- [Users](#users)
- [Health Check](#health-check)
- [Error Responses](#error-responses)

---

## Authentication

### Register User

Create a new user account.

**Endpoint:** `POST /auth/signup`

**Request Body:**
```json
{
  "username": "john_doe",
  "password": "SecurePassword123!",
  "email": "user@example.com",
  "avatar": "https://example.com/avatar.jpg"
}
```

**Validation Rules:**
- `username`: Required, 3-50 characters
- `password`: Required, minimum 8 characters
- `email`: Optional, valid email format
- `avatar`: Optional, valid URL format

**Success Response:** `201 Created`
```json
{
  "user_info": {
    "id": "uuid",
    "username": "john_doe",
    "email": "user@example.com",
    "avatar": "https://example.com/avatar.jpg",
    "created_at": "2024-12-25T10:30:00Z",
    "updated_at": "2024-12-25T10:30:00Z"
  }
}
```

**Error Responses:**
- `400 Bad Request` - Invalid input
- `409 Conflict` - User already exists
- `500 Internal Server Error` - Server error

**Curl Request:**
```bash
curl -X POST http://localhost:3009/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"username":"john_doe","password":"SecurePassword123!","email":"user@example.com","avatar":"https://example.com/avatar.jpg"}'
```

---

### Login

Authenticate user and receive access and refresh tokens.

**Endpoint:** `POST /auth/login`

**Request Body:**
```json
{
  "username": "john_doe",
  "password": "SecurePassword123!"
}
```

**Success Response:** `200 OK`
```json
{
  "access_token": "eyJhbGciOiJFZERTQSIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJFZERTQSIsInR5cCI6IkpXVCJ9...",
  "expires_in": 86400
}
```

**Response Fields:**
- `access_token`: JWT token for API authentication (24 hours validity)
- `refresh_token`: Token to obtain new access token (7 days validity)
- `expires_in`: Access token lifetime in seconds

**Error Responses:**
- `400 Bad Request` - Invalid input
- `401 Unauthorized` - Invalid credentials
- `500 Internal Server Error` - Server error

**Curl Request:**
```bash
curl -X POST http://localhost:3009/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"john_doe","password":"SecurePassword123!"}'
```

---

### Logout

Invalidate refresh token and logout user.

**Endpoint:** `POST /auth/logout`

**Request Body:**
```json
{
  "refresh_token": "eyJhbGciOiJFZERTQSIsInR5cCI6IkpXVCJ9..."
}
```

**Success Response:** `200 OK`
```json
{
  "message": "Logout successful"
}
```

**Error Responses:**
- `400 Bad Request` - Invalid input
- `401 Unauthorized` - Invalid refresh token
- `500 Internal Server Error` - Server error

**Curl Request:**
```bash
curl -X POST http://localhost:3009/auth/logout \
  -H "Content-Type: application/json" \
  -d '{"refresh_token":"eyJhbGciOiJFZERTQSIsInR5cCI6IkpXVCJ9..."}'
```

---

## Users

All user endpoints require authentication via JWT token in the Authorization header.

**Authentication Header:**
```
Authorization: Bearer <access_token>
```

### Get Current User Profile

Retrieve the profile of the authenticated user.

**Endpoint:** `GET /users/me`

**Success Response:** `200 OK`
```json
{
  "user_info": {
    "id": "uuid",
    "username": "john_doe",
    "email": "user@example.com",
    "avatar": "https://example.com/avatar.jpg",
    "created_at": "2024-12-25T10:30:00Z",
    "updated_at": "2024-12-25T10:30:00Z"
  }
}
```

**Error Responses:**
- `401 Unauthorized` - Invalid or missing token
- `500 Internal Server Error` - Server error

**Curl Request:**
```bash
curl -X GET http://localhost:3009/users/me \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

---

### Get All Users

Retrieve a paginated list of users.

**Endpoint:** `GET /users`

**Query Parameters:**
- `limit` (optional): Number of users per page (1-100, default: 10)
- `offset` (optional): Number of users to skip (default: 0)

**Example:** `GET /users?limit=20&offset=0`

**Success Response:** `200 OK`
```json
{
  "users": [
    {
      "user_info": {
        "id": "uuid",
        "username": "john_doe",
        "email": "user@example.com",
        "avatar": "https://example.com/avatar.jpg",
        "created_at": "2024-12-25T10:30:00Z",
        "updated_at": "2024-12-25T10:30:00Z"
      }
    },
    {
      "user_info": {
        "id": "uuid",
        "username": "jane_smith",
        "email": "jane@example.com",
        "avatar": null,
        "created_at": "2024-12-25T11:00:00Z",
        "updated_at": "2024-12-25T11:00:00Z"
      }
    }
  ],
  "total_count": 42
}
```

**Error Responses:**
- `400 Bad Request` - Invalid pagination parameters
- `401 Unauthorized` - Invalid or missing token
- `500 Internal Server Error` - Server error

**Curl Request:**
```bash
curl -X GET "http://localhost:3009/users?limit=20&offset=0" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

---

### Update Current User Profile

Update the profile of the authenticated user.

**Endpoint:** `PATCH /users/me`

**Request Body:**
```json
{
  "username": "new_username",
  "password": "new_secure_password",
  "email": "new_email@example.com",
  "avatar": "https://example.com/new_avatar.jpg"
}
```

**Validation Rules:**
- All fields are optional
- `username`: If provided, 3-50 characters
- `password`: If provided, minimum 8 characters
- `email`: If provided, valid email format
- `avatar`: If provided, valid URL format

**Success Response:** `200 OK`
```json
{
  "user_info": {
    "id": "uuid",
    "username": "new_username",
    "email": "new_email@example.com",
    "avatar": "https://example.com/new_avatar.jpg",
    "created_at": "2024-12-25T10:30:00Z",
    "updated_at": "2024-12-25T12:00:00Z"
  }
}
```

**Error Responses:**
- `400 Bad Request` - Invalid input
- `401 Unauthorized` - Invalid or missing token
- `409 Conflict` - Username already taken
- `500 Internal Server Error` - Server error

**Curl Request:**
```bash
curl -X PATCH http://localhost:3009/users/me \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{"username":"new_username","password":"new_secure_password","email":"new_email@example.com","avatar":"https://example.com/new_avatar.jpg"}'
```

---

### Get User by ID

Retrieve a specific user by their UUID.

**Endpoint:** `GET /users/{id}`

**Path Parameters:**
- `id`: User UUID

**Example:** `GET /users/123e4567-e89b-12d3-a456-426614174000`

**Success Response:** `200 OK`
```json
{
  "user_info": {
    "id": "uuid",
    "username": "john_doe",
    "email": "user@example.com",
    "avatar": "https://example.com/avatar.jpg",
    "created_at": "2024-12-25T10:30:00Z",
    "updated_at": "2024-12-25T10:30:00Z"
  }
}
```

**Error Responses:**
- `400 Bad Request` - Invalid UUID format
- `401 Unauthorized` - Invalid or missing token
- `404 Not Found` - User not found
- `500 Internal Server Error` - Server error

**Curl Request:**
```bash
curl -X GET http://localhost:3009/users/123e4567-e89b-12d3-a456-426614174000 \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

---

### Update User by ID

Update a specific user's profile. Users can only update their own profile.

**Endpoint:** `PATCH /users/{id}`

**Path Parameters:**
- `id`: User UUID

**Request Body:**
```json
{
  "username": "new_username",
  "password": "new_secure_password",
  "email": "new_email@example.com",
  "avatar": "https://example.com/new_avatar.jpg"
}
```

**Validation Rules:**
- All fields are optional
- `username`: If provided, 3-50 characters
- `password`: If provided, minimum 8 characters
- `email`: If provided, valid email format
- `avatar`: If provided, valid URL format

**Success Response:** `200 OK`
```json
{
  "user_info": {
    "id": "uuid",
    "username": "new_username",
    "email": "new_email@example.com",
    "avatar": "https://example.com/new_avatar.jpg",
    "created_at": "2024-12-25T10:30:00Z",
    "updated_at": "2024-12-25T12:00:00Z"
  }
}
```

**Error Responses:**
- `400 Bad Request` - Invalid input or UUID format
- `401 Unauthorized` - Invalid or missing token
- `403 Forbidden` - Not authorized to update this user
- `404 Not Found` - User not found
- `409 Conflict` - Username already taken
- `500 Internal Server Error` - Server error

**Curl Request:**
```bash
curl -X PATCH http://localhost:3009/users/123e4567-e89b-12d3-a456-426614174000 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{"username":"new_username","password":"new_secure_password","email":"new_email@example.com","avatar":"https://example.com/new_avatar.jpg"}'
```

---

### Delete User

Delete a user account.

**Endpoint:** `DELETE /users/{id}`

**Path Parameters:**
- `id`: User UUID

**Example:** `DELETE /users/123e4567-e89b-12d3-a456-426614174000`

**Success Response:** `200 OK`

**Error Responses:**
- `400 Bad Request` - Invalid UUID format
- `401 Unauthorized` - Invalid or missing token
- `404 Not Found` - User not found
- `500 Internal Server Error` - Server error

**Curl Request:**
```bash
curl -X DELETE http://localhost:3009/users/123e4567-e89b-12d3-a456-426614174000 \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

---

## Health Check

### General Health Check

Verify that the API server is running.

**Endpoint:** `GET /health`

**Success Response:** `200 OK`
```json
{
  "status": "ok"
}
```

**Note:** This endpoint does not require authentication.

**Curl Request:**
```bash
curl -X GET http://localhost:3009/health
```

---

### Liveness Check

Check if the server process is alive and responding.

**Endpoint:** `GET /health/live`

**Success Response:** `200 OK`
```json
{
  "status": "ok"
}
```

**Note:** This endpoint does not require authentication.

**Curl Request:**
```bash
curl -X GET http://localhost:3009/health/live
```

---

### Readiness Check

Check if the server is ready to accept requests, including database connectivity.

**Endpoint:** `GET /health/ready`

**Success Response:** `200 OK`
```json
{
  "status": "ok"
}
```

**Error Response:** `503 Service Unavailable` - Server not ready

**Note:** This endpoint does not require authentication.

**Curl Request:**
```bash
curl -X GET http://localhost:3009/health/ready
```

---

## Error Responses

All error responses follow this format:

```json
{
  "error": "Error message describing what went wrong"
}
```

### HTTP Status Codes

| Status Code | Description |
|-------------|-------------|
| `200 OK` | Request succeeded |
| `201 Created` | Resource created successfully |
| `400 Bad Request` | Invalid request format |
| `401 Unauthorized` | Authentication required |
| `403 Forbidden` | Invalid or expired token |
| `404 Not Found` | Resource not found |
| `422 Unprocessable Entity` | Validation error or business logic error |
| `500 Internal Server Error` | Server error |

### Common Error Examples

**Validation Error:**
```json
{
  "error": "validation error: username must be at least 3 characters"
}
```

**Authentication Error:**
```json
{
  "error": "verify token failed: TokenExpired"
}
```

**Not Found Error:**
```json
{
  "error": "not found: User 123 not found"
}
```

**Database Error:**
```json
{
  "error": "database error: connection failed"
}
```

---

## Authentication Flow

### Initial Authentication

1. Register a new user: `POST /auth/register`
2. Login to get tokens: `POST /auth/login`
3. Use `access_token` in Authorization header for subsequent requests

### Token Refresh

When the access token expires (after 24 hours):

1. Use the `refresh_token` to get a new access token: `POST /auth/refresh`
2. Update your stored tokens with the new values
3. Continue making authenticated requests

### Token Expiration

- **Access Token**: Valid for 24 hours (86400 seconds)
- **Refresh Token**: Valid for 7 days (604800 seconds)

When the refresh token expires, the user must login again.

---

## Rate Limiting

Currently, there is no rate limiting implemented. Consider adding rate limiting for production use.

---

## CORS

The API supports CORS for the configured origin (default: `http://localhost:51994`).

Allowed methods: `GET`, `POST`, `PUT`, `DELETE`, `OPTIONS`, `PATCH`

Allowed headers: `content-type`, `authorization`, `x-requested-with`, `accept`, `x-user-agent`

---

## Examples

### cURL Examples

**Register:**
```bash
curl -X POST http://localhost:3009/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"username":"john_doe","password":"SecurePassword123!","email":"user@example.com"}'
```

**Login:**
```bash
curl -X POST http://localhost:3009/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"john_doe","password":"SecurePassword123!"}'
```

**Get Users (with authentication):**
```bash
curl -X GET "http://localhost:3009/users?limit=10&offset=0" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

**Delete User:**
```bash
curl -X DELETE http://localhost:3009/users/123e4567-e89b-12d3-a456-426614174000 \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### JavaScript/Fetch Examples

**Login:**
```javascript
const response = await fetch('http://localhost:3009/auth/login', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    username: 'john_doe',
    password: 'SecurePass123!'
  })
});

const data = await response.json();
const accessToken = data.access_token;
```

**Authenticated Request:**
```javascript
const response = await fetch('http://localhost:3009/users', {
  method: 'GET',
  headers: {
    'Authorization': `Bearer ${accessToken}`,
  }
});

const users = await response.json();
```
