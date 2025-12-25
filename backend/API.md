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

**Endpoint:** `POST /auth/register`

**Request Body:**
```json
{
  "username": "john_doe",
  "password": "SecurePassword123!"
}
```

**Validation Rules:**
- `username`: Required, 3-50 characters
- `password`: Required, minimum 8 characters

**Success Response:** `201 Created`
```json
{
  "id": 1,
  "username": "john_doe",
  "created_at": "2024-12-25T10:30:00Z",
  "updated_at": "2024-12-25T10:30:00Z"
}
```

**Error Responses:**
- `422 Unprocessable Entity` - Validation failed or user already exists
- `500 Internal Server Error` - Database error

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
  "expires_at": 1735123800
}
```

**Response Fields:**
- `access_token`: JWT token for API authentication (24 hours validity)
- `refresh_token`: Token to obtain new access token (7 days validity)
- `expires_at`: Unix timestamp when access token expires

**Error Responses:**
- `422 Unprocessable Entity` - Invalid username or password
- `404 Not Found` - User not found

---

### Refresh Token

Obtain a new access token using a refresh token.

**Endpoint:** `POST /auth/refresh`

**Request Body:**
```json
{
  "refresh_token": "eyJhbGciOiJFZERTQSIsInR5cCI6IkpXVCJ9..."
}
```

**Success Response:** `200 OK`
```json
{
  "access_token": "eyJhbGciOiJFZERTQSIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJFZERTQSIsInR5cCI6IkpXVCJ9...",
  "expires_at": 1735123800
}
```

**Error Responses:**
- `401 Unauthorized` - Invalid or expired refresh token
- `404 Not Found` - User not found

**Note:** The old refresh token is invalidated and a new one is issued.

---

## Users

All user endpoints require authentication via JWT token in the Authorization header.

**Authentication Header:**
```
Authorization: Bearer <access_token>
```

### Get All Users

Retrieve a paginated list of users.

**Endpoint:** `GET /users`

**Query Parameters:**
- `limit` (optional): Number of users per page (default: 10, max: 100)
- `offset` (optional): Number of users to skip (default: 0)

**Example:** `GET /users?limit=20&offset=0`

**Success Response:** `200 OK`
```json
{
  "users": [
    {
      "id": 1,
      "username": "john_doe",
      "created_at": "2024-12-25T10:30:00Z",
      "updated_at": "2024-12-25T10:30:00Z"
    },
    {
      "id": 2,
      "username": "jane_smith",
      "created_at": "2024-12-25T11:00:00Z",
      "updated_at": "2024-12-25T11:00:00Z"
    }
  ],
  "total_count": 42
}
```

**Error Responses:**
- `403 Forbidden` - Missing or invalid authentication token
- `500 Internal Server Error` - Database error

---

### Get User by ID

Retrieve a specific user by their ID.

**Endpoint:** `GET /users/:id`

**Path Parameters:**
- `id`: User ID (integer)

**Example:** `GET /users/1`

**Success Response:** `200 OK`
```json
{
  "id": 1,
  "username": "john_doe",
  "created_at": "2024-12-25T10:30:00Z",
  "updated_at": "2024-12-25T10:30:00Z"
}
```

**Error Responses:**
- `403 Forbidden` - Missing or invalid authentication token
- `404 Not Found` - User not found
- `500 Internal Server Error` - Database error

---

### Delete User

Delete a user account.

**Endpoint:** `DELETE /users/:id`

**Path Parameters:**
- `id`: User ID (integer)

**Example:** `DELETE /users/1`

**Success Response:** `200 OK`
```json
{
  "message": "User deleted successfully"
}
```

**Error Responses:**
- `403 Forbidden` - Missing or invalid authentication token
- `404 Not Found` - User not found
- `500 Internal Server Error` - Database error

---

## Health Check

### Check API Health

Verify that the API server is running.

**Endpoint:** `GET /health`

**Success Response:** `200 OK`
```json
{
  "status": "ok"
}
```

**Note:** This endpoint does not require authentication.

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
curl -X POST http://localhost:3009/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"john_doe","password":"SecurePass123!"}'
```

**Login:**
```bash
curl -X POST http://localhost:3009/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"john_doe","password":"SecurePass123!"}'
```

**Get Users (with authentication):**
```bash
curl -X GET http://localhost:3009/users?limit=10&offset=0 \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

**Delete User:**
```bash
curl -X DELETE http://localhost:3009/users/1 \
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
