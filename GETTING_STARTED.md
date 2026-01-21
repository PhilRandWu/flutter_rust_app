# 快速上手指南 / Getting Started Guide

> 这是一个使用 Flutter + Rust (Axum) 构建的全栈应用项目。本指南将帮助你在 5 分钟内启动项目。

[English Version](#english-version)

---

## 中文版

### 📋 前置要求

在开始之前，请确保已安装以下工具：

1. **Rust** (1.70+)
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   ```

2. **Flutter** (3.0+)
   ```bash
   # macOS
   brew install flutter
   # 或访问 https://flutter.dev/docs/get-started/install
   ```
   
   **验证安装：**
   ```bash
   flutter doctor
   ```
   
   **如果 flutter 命令未找到，请添加到 PATH：**
   ```bash
   # 对于 Intel Mac
   export PATH="$PATH:/usr/local/flutter/bin"
   # 对于 Apple Silicon Mac
   export PATH="$PATH:/opt/homebrew/flutter/bin"
   ```

3. **PostgreSQL** (可选，用于后端)
   ```bash
   # macOS
   brew install postgresql@15
   brew services start postgresql@15
   ```

4. **Make** (通常已预装在 macOS/Linux)

### 🚀 5 分钟快速启动

#### 步骤 1: 克隆并进入项目
```bash
cd Flutter-axum-app
```

#### 步骤 2: 配置数据库（后端需要）
```bash
# 创建数据库
createdb example

# 复制配置文件
cp backend/app.yaml.example backend/app.yaml  # 如果存在示例文件
# 编辑 backend/app.yaml 修改数据库连接信息
```

#### 步骤 3: 运行数据库迁移
```bash
cd backend
cargo install sqlx-cli --no-default-features --features postgres
sqlx migrate run --source migrations
cd ..
```

#### 步骤 4: 启动后端服务器
```bash
# 在第一个终端窗口
make backend-run
```

看到 `Listening on: 0.0.0.0:3009` 表示启动成功！

#### 步骤 5: 启动前端应用
```bash
# 在第二个终端窗口
make frontend-run
```

选择运行平台（Chrome、macOS、iOS等）即可！

### 📱 运行 Web 版本（带 Rust WASM 支持）

如果要运行支持 Rust WASM 的 Web 版本，请使用以下命令：

```bash
# 方法 1：使用 Makefile（推荐）
make frontend-web-run

# 方法 2：手动执行命令
flutter_rust_bridge_codegen build-web --wasm-pack-rustflags "-Ctarget-feature=+atomics -Clink-args=--shared-memory -Clink-args=--max-memory=1073741824 -Clink-args=--import-memory -Clink-args=--export=__wasm_init_tls -Clink-args=--export=__tls_size -Clink-args=--export=__tls_align -Clink-args=--export=__tls_base"
flutter run -d chrome --web-header=Cross-Origin-Opener-Policy=same-origin --web-header=Cross-Origin-Embedder-Policy=require-corp
```

### 🛠️ 常用命令

| 命令 | 说明 |
|------|------|
| `make backend-run` | 启动后端服务器 |
| `make backend-check` | 检查后端代码（不编译） |
| `make backend-test` | 运行后端测试 |
| `make frontend-run` | 启动前端应用 |
| `make frontend-web-build` | 构建支持 Rust WASM 的 Web 版本 |
| `make frontend-web-run` | 运行支持 Rust WASM 的 Web 版本 |
| `make bridge-gen` | 生成 Rust-Flutter 桥接代码 |
| `make clean` | 清理所有构建产物 |

### 📂 项目结构

```
.
├── backend/          # Rust Axum 后端服务器
│   ├── src/         # 源代码
│   ├── migrations/  # 数据库迁移文件
│   └── app.yaml     # 配置文件
├── frontend/         # Flutter 前端应用
│   ├── lib/         # Dart 源代码
│   └── web/         # Web 资源
├── rust_lib/         # 共享的 Rust 逻辑（供 Flutter 调用）
│   └── src/api.rs   # 导出给 Flutter 的 API
├── build.sh          # 代码生成脚本
└── Makefile          # 构建任务
```

### 🔧 开发工作流

#### 修改后端代码
1. 编辑 `backend/src/` 下的文件
2. 运行 `make backend-check` 检查代码
3. 运行 `make backend-run` 启动服务器（会自动重新编译）

#### 修改前端代码
1. 编辑 `frontend/lib/` 下的文件
2. 保存后 Flutter 会热重载（Hot Reload）
3. 如果热重载失败，按 `r` 键重启

#### 修改共享 Rust 代码
1. 编辑 `rust_lib/src/api.rs`
2. 运行 `make bridge-gen` 重新生成桥接代码
3. 重启 Flutter 应用

### ❓ 常见问题

**Q: 后端启动失败，显示数据库连接错误？**
- 确保 PostgreSQL 正在运行：`brew services list`
- 检查 `backend/app.yaml` 中的数据库 URL
- 确保已运行数据库迁移

**Q: 前端无法连接后端？**
- 确保后端正在运行（端口 3009）
- 检查 `backend/app.yaml` 中的 CORS 配置
- 前端默认连接 `http://0.0.0.0:3009`

**Q: Web 版本显示 CORS 错误？**
- 使用 `make frontend-web-run` 而不是 `flutter run -d chrome`
- 该命令会自动设置必要的 CORS 头部
- 或者在后端配置 CORS 白名单

**Q: 修改 rust_lib 后前端报错？**
- 运行 `make bridge-gen` 重新生成桥接代码
- 删除 `frontend/lib/bridge_generated.dart/` 后重新生成

### 📚 下一步

- 阅读 [README.md](./README.md) 了解完整技术栈
- 查看 [api_endpoints.md](./api_endpoints.md) 了解 API 接口
- 阅读 [flutter_rust_bridge_integration_zh.md](./flutter_rust_bridge_integration_zh.md) 了解 Rust-Flutter 集成

---

## English Version

### 📋 Prerequisites

Make sure you have the following tools installed:

1. **Rust** (1.70+)
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   ```

2. **Flutter** (3.0+)
   ```bash
   # macOS
   brew install flutter
   # Or visit https://flutter.dev/docs/get-started/install
   ```
   
   **Verify installation:**
   ```bash
   flutter doctor
   ```
   
   **If flutter command not found, add to PATH:**
   ```bash
   # For Intel Mac
   export PATH="$PATH:/usr/local/flutter/bin"
   # For Apple Silicon Mac
   export PATH="$PATH:/opt/homebrew/flutter/bin"
   ```

3. **PostgreSQL** (Optional, for backend)
   ```bash
   # macOS
   brew install postgresql@15
   brew services start postgresql@15
   ```

4. **Make** (Usually pre-installed on macOS/Linux)

### 🚀 5-Minute Quick Start

#### Step 1: Clone and Enter Project
```bash
cd Flutter-axum-app
```

#### Step 2: Configure Database (Backend)
```bash
# Create database
createdb example

# Copy config file
cp backend/app.yaml.example backend/app.yaml  # If example exists
# Edit backend/app.yaml to update database connection
```

#### Step 3: Run Database Migrations
```bash
cd backend
cargo install sqlx-cli --no-default-features --features postgres
sqlx migrate run --source migrations
cd ..
```

#### Step 4: Start Backend Server
```bash
# In first terminal window
make backend-run
```

You should see `Listening on: 0.0.0.0:3009` - Success!

#### Step 5: Start Frontend App
```bash
# In second terminal window
make frontend-run
```

Select your platform (Chrome, macOS, iOS, etc.)!

### 📱 Run Web Version (with Rust WASM Support)

To run the web version with Rust WASM support, use these commands:

```bash
# Method 1: Using Makefile (recommended)
make frontend-web-run

# Method 2: Manual commands
flutter_rust_bridge_codegen build-web --wasm-pack-rustflags "-Ctarget-feature=+atomics -Clink-args=--shared-memory -Clink-args=--max-memory=1073741824 -Clink-args=--import-memory -Clink-args=--export=__wasm_init_tls -Clink-args=--export=__tls_size -Clink-args=--export=__tls_align -Clink-args=--export=__tls_base"
flutter run -d chrome --web-header=Cross-Origin-Opener-Policy=same-origin --web-header=Cross-Origin-Embedder-Policy=require-corp
```

### 🛠️ Common Commands

| Command | Description |
|---------|-------------|
| `make backend-run` | Start backend server |
| `make backend-check` | Check backend code (no build) |
| `make backend-test` | Run backend tests |
| `make frontend-run` | Start frontend app |
| `make frontend-web-build` | Build web version with Rust WASM support |
| `make frontend-web-run` | Run web version with Rust WASM support |
| `make bridge-gen` | Generate Rust-Flutter bridge code |
| `make clean` | Clean all build artifacts |

### 📂 Project Structure

```
.
├── backend/          # Rust Axum backend server
│   ├── src/         # Source code
│   ├── migrations/  # Database migrations
│   └── app.yaml     # Configuration
├── frontend/         # Flutter frontend app
│   ├── lib/         # Dart source code
│   └── web/         # Web assets
├── rust_lib/         # Shared Rust logic (for Flutter)
│   └── src/api.rs   # APIs exported to Flutter
├── build.sh          # Code generation script
└── Makefile          # Build tasks
```

### 🔧 Development Workflow

#### Modifying Backend Code
1. Edit files in `backend/src/`
2. Run `make backend-check` to verify
3. Run `make backend-run` to start server (auto-recompiles)

#### Modifying Frontend Code
1. Edit files in `frontend/lib/`
2. Flutter hot reloads automatically on save
3. Press `r` to restart if hot reload fails

#### Modifying Shared Rust Code
1. Edit `rust_lib/src/api.rs`
2. Run `make bridge-gen` to regenerate bridge code
3. Restart Flutter app

### ❓ Common Issues

**Q: Backend fails to start with database connection error?**
- Ensure PostgreSQL is running: `brew services list`
- Check database URL in `backend/app.yaml`
- Make sure migrations have been run

**Q: Frontend can't connect to backend?**
- Ensure backend is running (port 3009)
- Check CORS config in `backend/app.yaml`
- Frontend defaults to `http://0.0.0.0:3009`

**Q: Web version shows CORS errors?**
- Use `make frontend-web-run` instead of `flutter run -d chrome`
- This command automatically sets the necessary CORS headers
- Or configure CORS whitelist in `backend/app.yaml`

**Q: Frontend errors after modifying rust_lib?**
- Run `make bridge-gen` to regenerate bridge code
- Delete `frontend/lib/bridge_generated.dart/` and regenerate

### 📚 Next Steps

- Read [README.md](./README.md) for full tech stack info
- Check [api_endpoints.md](./api_endpoints.md) for API documentation
- Read [flutter_rust_bridge_integration_en.md](./flutter_rust_bridge_integration_en.md) for Rust-Flutter integration

---

## 🤝 Contributing

Feel free to submit issues and pull requests!

## 📄 License

This project is open source and available under the MIT License.
