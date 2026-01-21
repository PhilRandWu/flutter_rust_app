# Flutter + Rust 开发工作流优化

# 默认配方
_default:
    @just --list

# 环境检查
[private]
check-env:
    @echo "🔍 检查开发环境..."
    @which fvm > /dev/null 2>&1 || (echo "❌ FVM未安装" && exit 1)
    @which cargo > /dev/null 2>&1 || (echo "❌ Cargo未安装" && exit 1)
    @which flutter_rust_bridge_codegen > /dev/null 2>&1 || (echo "❌ flutter_rust_bridge_codegen未安装" && exit 1)
    @echo "✅ 环境检查通过"

# 安装依赖
install-deps: check-env
    @echo "📦 安装项目依赖..."
    @cd frontend && fvm flutter pub get
    @cd backend && cargo fetch
    @echo "✅ 依赖安装完成"

# 快速启动开发环境
dev: install-deps
    @echo "🚀 启动开发环境..."
    @just backend-dev &
    @sleep 2
    @just frontend-dev

# 后端开发模式
backend-dev:
    @echo "🔧 启动后端开发服务器..."
    @cd backend && cargo watch -x run

# 前端开发模式
frontend-dev:
    @echo "🎯 启动前端开发服务器..."
    @cd frontend && fvm flutter run

# Web开发模式
web-dev: bridge-gen
    @echo "🌐 启动Web开发环境..."
    @cd frontend && flutter_rust_bridge_codegen build-web --wasm-pack-rustflags "-Ctarget-feature=+atomics -Clink-args=--shared-memory -Clink-args=--max-memory=1073741824 -Clink-args=--import-memory -Clink-args=--export=__wasm_init_tls -Clink-args=--export=__tls_size -Clink-args=--export=__tls_align -Clink-args=--export=__tls_base" && fvm flutter run -d chrome --web-header=Cross-Origin-Opener-Policy=same-origin --web-header=Cross-Origin-Embedder-Policy=require-corp

# 生成桥接代码
bridge-gen:
    @echo "🔄 生成Rust-Flutter桥接代码..."
    @cd frontend && flutter_rust_bridge_codegen generate

# 运行所有测试
test: test-backend test-frontend

# 后端测试
test-backend:
    @echo "🧪 运行后端测试..."
    @cd backend && cargo test

# 前端测试
test-frontend:
    @echo "🧪 运行前端测试..."
    @cd frontend && fvm flutter test

# 集成测试
test-integration:
    @echo "🔗 运行集成测试..."
    @cd frontend && fvm flutter test integration_test

# 代码质量检查
lint: lint-backend lint-frontend

# 后端代码检查
lint-backend:
    @echo "🔍 检查后端代码..."
    @cd backend && cargo clippy -- -D warnings
    @cd backend && cargo fmt --check

# 前端代码检查
lint-frontend:
    @echo "🔍 检查前端代码..."
    @cd frontend && fvm flutter analyze
    @cd frontend && fvm dart format --set-exit-if-changed .

# 构建所有平台
build-all: build-backend build-frontend build-web

# 构建后端
build-backend:
    @echo "🏗️  构建后端..."
    @cd backend && cargo build --release

# 构建前端
build-frontend:
    @echo "🏗️  构建前端..."
    @cd frontend && fvm flutter build apk
    @cd frontend && fvm flutter build ios

# 构建Web版本
build-web: bridge-gen
    @echo "🏗️  构建Web版本..."
    @cd frontend && flutter_rust_bridge_codegen build-web --wasm-pack-rustflags "-Ctarget-feature=+atomics -Clink-args=--shared-memory -Clink-args=--max-memory=1073741824 -Clink-args=--import-memory -Clink-args=--export=__wasm_init_tls -Clink-args=--export=__tls_size -Clink-args=--export=__tls_align -Clink-args=--export=__tls_base"
    @cd frontend && fvm flutter build web

# 清理构建缓存
clean:
    @echo "🧹 清理构建缓存..."
    @cd backend && cargo clean
    @cd frontend && fvm flutter clean
    @rm -rf rust_lib/target
    @echo "✅ 清理完成"

# 开发工具安装
install-tools:
    @echo "🔧 安装开发工具..."
    @cargo install cargo-watch cargo-audit
    @dart pub global activate melos
    @echo "✅ 开发工具安装完成"

# 安全审计
audit:
    @echo "🔒 运行安全审计..."
    @cd backend && cargo audit
    @cd frontend && fvm flutter pub deps

# 性能分析
profile-backend:
    @echo "📊 分析后端性能..."
    @cd backend && cargo bench

# 数据库迁移
db-migrate:
    @echo "🗄️  运行数据库迁移..."
    @cd backend && cargo run -- migrate

# 数据库回滚
db-rollback:
    @echo "🔄 数据库回滚..."
    @cd backend && cargo run -- rollback

# 生成API文档
docs:
    @echo "📚 生成API文档..."
    @cd backend && cargo doc --open
    @cd frontend && fvm dart doc .

# 发布准备
release-prep: clean install-deps lint test build-all
    @echo "🚀 发布准备完成！"

# Git hooks设置
setup-hooks:
    @echo "🪝 设置Git hooks..."
    @cp scripts/pre-commit .git/hooks/pre-commit
    @chmod +x .git/hooks/pre-commit
    @echo "✅ Git hooks设置完成"

# 安装文档工具
install-docs:
    @echo "📚 安装文档工具..."
    @cargo install cargo-doc
    @echo "✅ 文档工具安装完成"

# 开发环境完整设置
setup: check-env install-tools install-docs setup-hooks
    @echo "🎉 开发环境设置完成！"

# 帮助
help:
    @just --list