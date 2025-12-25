# Backend - Rust Axum API Server

A robust REST API backend built with Rust, Axum web framework, and PostgreSQL.

## 🚀 Features

- **Authentication**: JWT-based authentication with refresh tokens
- **User Management**: CRUD operations for user accounts
- **Database**: PostgreSQL with SQLx for type-safe queries
- **Security**: Argon2 password hashing, Ed25519 JWT signatures
- **Logging**: Structured logging with tracing
- **Testing**: Integration tests with isolated test databases
- **CORS**: Configurable CORS support for frontend integration

## 📋 Prerequisites

- Rust 1.70+ (edition 2021)
- PostgreSQL 14+
- Cargo

## 🛠️ Installation

### 1. Clone the repository

```bash
git clone <repository-url>
cd backend
```

### 2. Set up environment variables

Copy the example environment file:

```bash
cp .env.example .env
```

Edit `.env` and configure your settings:

```env
# Server Configuration
SERVER_PORT=3009

# Database
DATABASE_URL=postgres://username:password@localhost/dbname

# JWT Configuration
JWT_SECRET_KEY=fixtures/private_key.pem
JWT_PUBLIC_KEY=fixtures/public_key.pem
JWT_DURATION=86400
JWT_REFRESH_DURATION=604800
JWT_ISSUER=my_service
JWT_AUDIENCE=my_app

# CORS
CORS_ORIGIN=http://localhost:51994
```

### 3. Set up PostgreSQL

Create a new database:

```bash
createdb your_database_name
```

### 4. Run migrations

```bash
cargo install sqlx-cli --no-default-features --features postgres
sqlx migrate run
```

### 5. Build the project

```bash
# Development build
cargo build

# Release build (optimized)
cargo build --release
```

## 🏃 Running the Server

### Development mode

```bash
cargo run
```

### Production mode

```bash
cargo run --release
```

The server will start on `http://0.0.0.0:3009` (or the port specified in your `.env` file).

## 🧪 Testing

Run all tests:

```bash
cargo test
```

Run tests with output:

```bash
cargo test -- --nocapture
```

Run specific test:

```bash
cargo test test_name
```

## 📚 API Documentation

See [API.md](./API.md) for detailed API endpoint documentation.

### Quick Overview

- `POST /auth/login` - User login
- `POST /auth/refresh` - Refresh access token
- `POST /auth/register` - Register new user
- `GET /users` - Get all users (paginated)
- `GET /users/:id` - Get user by ID
- `DELETE /users/:id` - Delete user
- `GET /health` - Health check endpoint

## 🏗️ Project Structure

```
backend/
├── src/
│   ├── common/           # Shared utilities
│   │   ├── auth.rs       # JWT and password handling
│   │   ├── config.rs     # Configuration management
│   │   ├── error.rs      # Error types and handling
│   │   └── mod.rs
│   ├── modules/          # Feature modules
│   │   ├── auth/         # Authentication logic
│   │   │   ├── dto.rs
│   │   │   ├── handlers.rs
│   │   │   ├── middleware.rs
│   │   │   ├── service.rs
│   │   │   └── tests.rs
│   │   ├── users/        # User management
│   │   │   ├── dto.rs
│   │   │   ├── entity.rs
│   │   │   ├── handlers.rs
│   │   │   └── services.rs
│   │   └── health/       # Health check
│   ├── lib.rs            # Library root
│   └── main.rs           # Application entry point
├── migrations/           # Database migrations
├── fixtures/             # Test data and keys
├── logs/                 # Application logs
├── Cargo.toml            # Dependencies
├── build.rs              # Build script
└── .env                  # Environment configuration
```

## 🔧 Configuration

The application uses a hierarchical configuration system:

1. **Environment Variables**: Highest priority
2. **`.env` file**: Loaded if present
3. **`app.yaml`**: Fallback configuration

### Environment Variables

All configuration can be set via environment variables:

- `SERVER_PORT` - Server port (default: 3009)
- `DATABASE_URL` - PostgreSQL connection string
- `JWT_SECRET_KEY` - Path to JWT private key
- `JWT_PUBLIC_KEY` - Path to JWT public key
- `JWT_DURATION` - Access token lifetime in seconds
- `JWT_REFRESH_DURATION` - Refresh token lifetime in seconds
- `JWT_ISSUER` - JWT issuer claim
- `JWT_AUDIENCE` - JWT audience claim
- `CORS_ORIGIN` - Allowed CORS origin

## 🔐 Security

- **Password Hashing**: Argon2 with secure defaults
- **JWT Signing**: Ed25519 elliptic curve signatures
- **Token Storage**: Refresh tokens stored in database with expiration
- **CORS**: Configurable origin restrictions
- **SQL Injection**: Protected by SQLx compile-time query verification

### Generating JWT Keys

JWT keys are automatically generated during the build process. For production, you should:

1. Generate keys once: `cargo build`
2. Securely store `fixtures/private_key.pem` and `fixtures/public_key.pem`
3. Use a secrets manager in production environments

## 📊 Logging

Logs are written to:
- **Console**: stderr (colored, human-readable)
- **File**: `logs/app.log` (daily rotation)

Set log level via environment:

```bash
RUST_LOG=debug cargo run
```

Available levels: `trace`, `debug`, `info`, `warn`, `error`

## 🚨 Troubleshooting

### Database connection fails

- Verify PostgreSQL is running: `pg_isready`
- Check connection string in `.env`
- Ensure database exists: `psql -l`

### JWT errors

- Ensure key files exist in `fixtures/`
- Rebuild to regenerate keys: `cargo clean && cargo build`

### Port already in use

- Change `SERVER_PORT` in `.env`
- Or kill the process using the port: `lsof -ti:3009 | xargs kill`

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Make your changes
4. Run tests: `cargo test`
5. Run linting: `cargo clippy`
6. Format code: `cargo fmt`
7. Commit changes: `git commit -am 'Add new feature'`
8. Push to branch: `git push origin feature/my-feature`
9. Submit a pull request

## 📝 Development Guidelines

- Follow Rust naming conventions
- Add tests for new features
- Document public APIs with doc comments
- Keep functions focused and small
- Use `Result` types for error handling
- Avoid `unwrap()` and `expect()` in production code

## 📜 License

[Your License Here]

## 👥 Authors

[Your Name/Team]

## 🙏 Acknowledgments

- [Axum](https://github.com/tokio-rs/axum) - Web framework
- [SQLx](https://github.com/launchbadge/sqlx) - Database toolkit
- [Tokio](https://tokio.rs/) - Async runtime
