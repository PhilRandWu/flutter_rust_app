# 开发环境配置

## VS Code 设置

### 推荐插件
```json
{
  "recommendations": [
    "rust-lang.rust-analyzer",
    "vadimcn.vscode-lldb",
    "serayuzgur.crates",
    "tamasfe.even-better-toml",
    "Dart-Code.flutter",
    "Dart-Code.dart-code",
    "alexisvt.flutter-snippets",
    "Nash.awesome-flutter-snippets",
    "ms-vscode.vscode-json",
    "redhat.vscode-yaml",
    "ms-vscode.hexeditor",
    "pkief.material-icon-theme",
    "GitHub.copilot",
    "GitHub.copilot-chat"
  ]
}
```

### 工作区设置
```json
{
  "settings": {
    "rust-analyzer.cargo.features": "all",
    "rust-analyzer.checkOnSave.command": "clippy",
    "rust-analyzer.cargo.buildScripts.enable": true,
    "rust-analyzer.procMacro.enable": true,
    "rust-analyzer.imports.granularity.group": "module",
    "rust-analyzer.completion.autoimport.enable": true,
    "dart.flutterSdkPath": ".fvm/flutter_sdk",
    "dart.checkForSdkUpdates": false,
    "dart.showInspectorNotificationsForWidgetErrors": false,
    "dart.previewFlutterUiGuides": true,
    "dart.previewFlutterUiGuidesCustomTracking": true,
    "dart.hotReloadOnSave": "always",
    "dart.flutterHotReloadOnSave": "always",
    "files.watcherExclude": {
      "**/target/**": true,
      "**/.fvm/**": true,
      "**/build/**": true,
      "**/.dart_tool/**": true
    },
    "search.exclude": {
      "**/target/**": true,
      "**/.fvm/**": true,
      "**/build/**": true,
      "**/.dart_tool/**": true
    }
  }
}
```

## 环境变量配置

### .env 文件模板
```bash
# 后端配置
DATABASE_URL=postgres://user:password@localhost:5432/flutter_axum_app
REDIS_URL=redis://localhost:6379
JWT_SECRET=your-secret-key-here
PORT=8080
RUST_LOG=debug

# 前端配置
API_BASE_URL=http://localhost:8080
WEB_SOCKET_URL=ws://localhost:8080/ws
ENVIRONMENT=development
```

### Shell 配置
```bash
# ~/.zshrc 或 ~/.bashrc
export PATH="$PATH:$HOME/.cargo/bin"
export PATH="$PATH:$HOME/.pub-cache/bin"
export PATH="$PATH:$HOME/fvm/default/bin"

# Rust 配置
export RUST_LOG=debug
export RUST_BACKTRACE=1

# Flutter 配置
export FLUTTER_ROOT="$HOME/fvm/default"
export PUB_CACHE="$HOME/.pub-cache"
```

## Git 配置

### .gitignore 优化
```gitignore
# Flutter
**/flutter_export_environment.sh
**/Flutter/ephemeral/
**/Flutter/flutter_assets/
**/Flutter/flutter_build/
**/Flutter/flutter_export_environment.sh
**/Flutter/Generated.xcconfig
**/Flutter/ephemeral/Flutter-Generated.xcconfig

# Rust
**/target/
**/*.rs.bk
Cargo.lock

# FVM
.fvm/
.fvmrc

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Build
build/
dist/
*.log

# Environment
.env
.env.local
.env.*.local

# 临时文件
*.tmp
*.temp
.cache/
```

### Git 别名
```bash
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.visual '!gitk'
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
```

## Docker 开发环境

### docker-compose.yml
```yaml
version: '3.8'
services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: flutter_axum_app
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  backend:
    build: ./backend
    ports:
      - "8080:8080"
    depends_on:
      - postgres
      - redis
    environment:
      DATABASE_URL: postgres://user:password@postgres:5432/flutter_axum_app
      REDIS_URL: redis://redis:6379
    volumes:
      - ./backend:/app
      - cargo_cache:/usr/local/cargo/registry

volumes:
  postgres_data:
  cargo_cache:
```

## 性能优化配置

### Rust 编译优化
```toml
# backend/Cargo.toml
[profile.dev]
opt-level = 0
debug = true
debug-assertions = true
overflow-checks = true
lto = false
panic = 'unwind'
incremental = true
codegen-units = 256
rpath = false

[profile.dev.package."*"]
opt-level = 3

[profile.release]
opt-level = 3
debug = false
debug-assertions = false
overflow-checks = false
lto = true
panic = 'abort'
incremental = false
codegen-units = 1
strip = true
```

### Flutter 编译优化
```json
// frontend/android/app/build.gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
    
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
}
```

## 监控和调试

### 日志配置
```rust
// backend/src/logger.rs
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

pub fn init_logger() {
    let env_filter = tracing_subscriber::EnvFilter::try_from_default_env()
        .unwrap_or_else(|_| "info,tower_http=debug".into());

    tracing_subscriber::registry()
        .with(
            tracing_subscriber::fmt::layer()
                .with_file(true)
                .with_line_number(true)
                .with_thread_ids(true)
                .with_target(false)
                .compact(),
        )
        .with(env_filter)
        .init();
}
```

### 性能监控
```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'backend'
    static_configs:
      - targets: ['localhost:8080']
    metrics_path: '/metrics'
    scrape_interval: 5s
```