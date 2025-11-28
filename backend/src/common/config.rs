use std::fs::read_to_string;
use serde::Deserialize;

#[derive(Clone, Debug, Deserialize)]
pub struct ServerConfig {
    pub port: u16,
}

#[derive(Clone, Debug, Deserialize)]
pub struct DatabaseConfig {
    pub db_url: String,
}

#[derive(Clone, Debug, Deserialize)]
pub struct AppConfig {
    pub server: ServerConfig,
    pub database: DatabaseConfig,
}

impl AppConfig {
    pub fn from_file(file_path: &str) -> Self {
        let config_str = read_to_string(file_path).expect("Failed to read config file");
        serde_yaml::from_str(&config_str).expect("Failed to parse config file")
    }
}