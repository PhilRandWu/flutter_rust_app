use serde::Deserialize;
use std::{env, fs::read_to_string};

#[derive(Clone, Debug, Deserialize)]
pub struct ServerConfig {
    pub port: u16,
}

#[derive(Clone, Debug, Deserialize)]
pub struct DatabaseConfig {
    pub db_url: String,
}

#[derive(Clone, Debug, Deserialize)]
pub struct RedisConfig {
    pub redis_url: String,
}

#[derive(Clone, Debug, Deserialize)]
pub struct AuthConfig {
    pub secret_key: String,
    pub public_key: String,
    pub jwt_duration: u64,
    pub refresh_token_duration: u64,
    pub jwt_iss: String,
    pub jwt_aud: String,
}

#[derive(Clone, Debug, Deserialize)]
pub struct CorsConfig {
    pub origin: String,
    pub allowed_methods: Vec<String>,
    pub allowed_headers: Vec<String>,
}

#[derive(Clone, Debug, Deserialize)]
pub struct AppConfig {
    pub server: ServerConfig,
    pub database: DatabaseConfig,
    // pub redis: Option<RedisConfig>,
    pub auth: AuthConfig,
    pub cors: CorsConfig,
}

impl AppConfig {
    /// Load configuration from environment variables with fallback to app.yaml
    pub fn from_file(file_path: &str) -> Self {
        // Load .env file if it exists (ignore errors if not present)
        let _ = dotenvy::dotenv();

        // Try to load from environment variables first
        if let Ok(config) = Self::from_env() {
            return config;
        }

        // Fallback to YAML file
        let config_str = read_to_string(file_path).expect("Failed to read config file");
        serde_yaml::from_str(&config_str).expect("Failed to parse config file")
    }

    /// Load configuration from environment variables
    fn from_env() -> Result<Self, env::VarError> {
        Ok(AppConfig {
            server: ServerConfig {
                port: env::var("SERVER_PORT")?.parse().unwrap_or(3009),
            },
            database: DatabaseConfig {
                db_url: env::var("DATABASE_URL")?,
            },
            // redis: env::var("REDIS_URL").ok().map(|redis_url| RedisConfig { redis_url }),
            auth: AuthConfig {
                secret_key: env::var("JWT_SECRET_KEY")?,
                public_key: env::var("JWT_PUBLIC_KEY")?,
                jwt_duration: env::var("JWT_DURATION")?.parse().unwrap_or(86400),
                refresh_token_duration: env::var("JWT_REFRESH_DURATION")?.parse().unwrap_or(604800),
                jwt_iss: env::var("JWT_ISSUER")?,
                jwt_aud: env::var("JWT_AUDIENCE")?,
            },
            cors: CorsConfig {
                origin: env::var("CORS_ORIGIN")?,
                allowed_methods: env::var("CORS_ALLOWED_METHODS")
                    .unwrap_or_else(|_| "GET,POST,PUT,DELETE,OPTIONS,PATCH".to_string())
                    .split(',')
                    .map(|s| s.trim().to_string())
                    .collect(),
                allowed_headers: env::var("CORS_ALLOWED_HEADERS")
                    .unwrap_or_else(|_| {
                        "content-type,authorization,x-requested-with,accept,x-user-agent"
                            .to_string()
                    })
                    .split(',')
                    .map(|s| s.trim().to_string())
                    .collect(),
            },
        })
    }
}
