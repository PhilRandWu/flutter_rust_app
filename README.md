
# Flutter-Axum Full-Stack App

> 🚀 **New to this project?** Check out [GETTING_STARTED.md](./GETTING_STARTED.md) for a quick 5-minute setup guide!

This is a full-stack application built with Flutter for the frontend and Axum (a Rust framework) for the backend. It demonstrates a complete development workflow, from UI to database, including cross-platform deployment and shared business logic using `flutter_rust_bridge`.

## Tech Stack

-   **Frontend**:
    -   [Flutter](https://flutter.dev/): A UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.
    -   [flutter_rust_bridge](https://github.com/fzyzcjy/flutter_rust_bridge): High-level memory-safe binding generator for Flutter/Dart <-> Rust.
-   **Backend**:
    -   [Rust](https://www.rust-lang.org/): A language focused on performance, reliability, and productivity.
    -   [Axum](https://github.com/tokio-rs/axum): A web application framework that focuses on ergonomics and modularity.
    -   [Tokio](https://tokio.rs/): An asynchronous runtime for Rust.
    -   [SQLx](https://github.com/launchbadge/sqlx): A modern, async-safe, and compile-time checked SQL toolkit for Rust.
    -   [PostgreSQL](https://www.postgresql.org/): A powerful, open-source object-relational database system.
-   **Shared Logic**:
    -   A dedicated `rust_lib` crate contains shared business logic (e.g., validation, computation) compiled for both the backend and the Flutter app.

## 🚀 Development Workflow (New: Optimized with Just!)

The project now supports **two workflow options**: traditional Makefile or modern Just commands.

### ✨ Quick Start with Just (Recommended)

```bash
# Install just (one-time setup)
cargo install just

# Setup development environment
just setup

# Start full development environment (backend + frontend)
just dev

# Run web version with Rust WASM support
just web-dev
```

### Traditional Makefile Workflow

```bash
# Run backend
make backend-run

# Run frontend (in another terminal)
make frontend-run

# Generate Rust-Flutter bridge (if you modify rust_lib)
make bridge-gen
```

### 🛠️ Available Commands

| Task | Just Command | Makefile Command | Description |
|------|-------------|------------------|-------------|
| Full Dev Environment | `just dev` | - | Run backend + frontend in parallel |
| Web Development | `just web-dev` | `make frontend-web-run` | Web version with WASM support |
| Build Web | `just build-web` | `make frontend-web-build` | Build web version with Rust WASM |
| Run Backend | `just backend` | `make backend-run` | Start backend server |
| Run Frontend | `just frontend` | `make frontend-run` | Start Flutter app |
| Run Tests | `just test` | - | Run all tests (Rust + Flutter) |
| Code Quality | `just lint` | - | Run all linting and formatting |
| Clean Build | `just clean` | `make clean` | Clean all build artifacts |
| View All Commands | `just --list` | `make help` | Show all available commands |

### 1. Backend Development (`/backend`)

-   **Run the server**: `make backend-run` or `cd backend && cargo run`
-   **Check code**: `make backend-check` or `cd backend && cargo check`
-   **Run tests**: `make backend-test` or `cd backend && cargo test`
-   **Database Migrations**: SQLx CLI is used for managing database migrations.
    ```bash
    # Install sqlx-cli (one-time setup)
    cargo install sqlx-cli
    # Run migrations
    cd backend && sqlx migrate run --source migrations --database-url <YOUR_DATABASE_URL>
    ```

### 2. Frontend Development (`/frontend`)

-   **Run the app**: `make frontend-run` or `cd frontend && flutter run`
-   **Run web version with Rust WASM**: 
  ```bash
  flutter_rust_bridge_codegen build-web --wasm-pack-rustflags "-Ctarget-feature=+atomics -Clink-args=--shared-memory -Clink-args=--max-memory=1073741824 -Clink-args=--import-memory -Clink-args=--export=__wasm_init_tls -Clink-args=--export=__tls_size -Clink-args=--export=__tls_align -Clink-args=--export=__tls_base"
  flutter run -d chrome --web-header=Cross-Origin-Opener-Policy=same-origin --web-header=Cross-Origin-Embedder-Policy=require-corp
  ```

### 3. Shared Rust Logic Development (`/rust_lib`)

This crate contains Rust code that can be called from the Flutter frontend.

-   **Generate bindings**: If you modify `rust_lib/src/api.rs`, run `make bridge-gen` or `./build.sh`
-   **Automated development**: Use `cargo-watch` for auto-regeneration on file changes
    ```bash
    cd rust_lib && cargo install cargo-watch
    cargo watch -c -w src --ignore src/frb_generated.rs -s "flutter_rust_bridge_codegen generate --rust-input crate::api --dart-output ../frontend/lib/bridge_generated.dart --rust-root . && cargo build"
    ```
-   For detailed instructions, see [flutter_rust_bridge_integration_en.md](./flutter_rust_bridge_integration_en.md).

## 🛠️ Development Tools (New!)

### Quick Development Tools

```bash
# Project status overview
./scripts/dev-tools.sh status

# Quick search in codebase
./scripts/dev-tools.sh search "auth"

# Performance monitoring
./scripts/dev-tools.sh monitor

# Quick test runner
./scripts/dev-tools.sh test
```

### Setup Development Environment

```bash
# Automated setup (installs dependencies, configures environment)
./scripts/setup-dev.sh

# Install Git hooks for code quality
just setup-hooks
```

### IDE Configuration

For optimal development experience, check out our [development environment guide](./docs/dev-environment.md) which includes:
- VS Code recommended extensions
- Rust and Flutter IDE settings
- Docker development environment setup
- Performance optimization configurations

---

# Flutter-Axum 全栈应用

> 🚀 **项目新手？** 查看 [GETTING_STARTED.md](./GETTING_STARTED.md) 获取 5 分钟快速上手指南！

这是一个使用 Flutter 构建前端、Axum (Rust 框架) 构建后端的全栈应用。它展示了从 UI 到数据库的完整开发流程，包括跨平台部署和使用 `flutter_rust_bridge` 实现的共享业务逻辑。

## 技术栈

-   **前端**:
    -   [Flutter](https://flutter.dev/): 用于从单一代码库为移动、Web 和桌面构建本地编译应用的 UI 工具包。
    -   [flutter_rust_bridge](https://github.com/fzyzcjy/flutter_rust_bridge): 用于 Flutter/Dart <-> Rust 的高级内存安全绑定生成器。
-   **后端**:
    -   [Rust](https://www.rust-lang.org/): 一门注重性能、可靠性和生产力的语言。
    -   [Axum](https://github.com/tokio-rs/axum): 一个专注于人体工程学和模块化的 Web 应用框架。
    -   [Tokio](https://tokio.rs/): Rust 的异步运行时。
    -   [SQLx](https://github.com/launchbadge/sqlx): 一个现代、异步安全且编译时检查的 Rust SQL 工具包。
    -   [PostgreSQL](https://www.postgresql.org/): 一个功能强大的开源对象关系数据库系统。
-   
## 🚀 开发流程（新增：优化的 Just 支持！）

项目现在支持**两种工作流选项**：传统 Makefile 或现代化的 Just 命令。

### ✨ 使用 Just 快速开始（推荐）

```bash
# 安装 just（一次性设置）
cargo install just

# 设置开发环境
just setup

# 启动完整开发环境（后端 + 前端）
just dev

# 运行带 Rust WASM 支持的 Web 版本
just web-dev
```

### 🛠️ 可用命令（已更新为 Just！）

| 任务 | Just 命令 | 描述 |
|------|-------------|-------------|
| 完整开发环境 | `just dev` | 并行运行后端 + 前端 |
| Web 开发 | `just web-dev` | 带 WASM 支持的 Web 版本 |
| 构建 Web | `just build-web` | 构建带 Rust WASM 的 Web 版本 |
| 运行后端 | `just backend` | 启动后端服务器 |
| 运行前端 | `just frontend` | 启动 Flutter 应用 |
| 运行测试 | `just test` | 运行所有测试（Rust + Flutter） |
| 代码质量 | `just lint` | 运行所有检查和格式化 |
| 清理构建 | `just clean` | 清理所有构建产物 |
| 查看所有命令 | `just --list` | 显示所有可用命令 |

### 1. 后端开发 (`/backend`)

-   **运行服务器**: `just backend` 或 `cd backend && cargo run`
-   **检查代码**: `just backend-check` 或 `cd backend && cargo check`
-   **运行测试**: `just backend-test` 或 `cd backend && cargo test`
-   **数据库迁移**: 使用 SQLx CLI 管理数据库迁移
    ```bash
    # 安装 sqlx-cli（首次设置）
    cargo install sqlx-cli
    # 运行迁移
    cd backend && sqlx migrate run --source migrations --database-url <YOUR_DATABASE_URL>
    ```

### 2. 前端开发 (`/frontend`)

-   **运行应用**: `just frontend` 或 `cd frontend && flutter run`
-   **运行带 Rust WASM 的 Web 版本**: 
  ```bash
  flutter_rust_bridge_codegen build-web --wasm-pack-rustflags "-Ctarget-feature=+atomics -Clink-args=--shared-memory -Clink-args=--max-memory=1073741824 -Clink-args=--import-memory -Clink-args=--export=__wasm_init_tls -Clink-args=--export=__tls_size -Clink-args=--export=__tls_align -Clink-args=--export=__tls_base"
  flutter run -d chrome --web-header=Cross-Origin-Opener-Policy=same-origin --web-header=Cross-Origin-Embedder-Policy=require-corp
  ```
  
  **简化方式**: 使用 `just web-dev` 命令自动完成上述步骤！
  
  **注意**: 如果遇到 "flutter: command not found" 错误，请确保 Flutter 已安装并在 PATH 中。详细安装说明请参考 [GETTING_STARTED.md](./GETTING_STARTED.md)。


## 🛠️ 开发工具（新增！）

### 快速开发工具

```bash
# 项目状态概览
./scripts/dev-tools.sh status

# 代码库快速搜索
./scripts/dev-tools.sh search "auth"

# 性能监控
./scripts/dev-tools.sh monitor

# 快速测试运行器
./scripts/dev-tools.sh test
```

### 设置开发环境

```bash
# 自动化设置（安装依赖、配置环境）
./scripts/setup-dev.sh

# 安装 Git 钩子以确保代码质量
just setup-hooks
```

### IDE 配置

为了获得最佳的开发体验，请查看我们的[开发环境指南](./docs/dev-environment.md)，其中包括：
- VS Code 推荐扩展
- Rust 和 Flutter IDE 设置
- Docker 开发环境设置
- 性能优化配置
