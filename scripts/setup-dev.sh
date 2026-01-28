#!/bin/zsh
# 开发环境快速设置脚本

set -e

echo "🚀 Flutter + Rust 开发环境设置"
echo "=================================="

# 检查系统要求
echo "🔍 检查系统要求..."
if ! command -v git &> /dev/null; then
    echo "❌ Git未安装"
    exit 1
fi

if ! command -v curl &> /dev/null; then
    echo "❌ curl未安装"
    exit 1
fi

# 安装FVM（Flutter版本管理器）
echo "📦 安装FVM..."
if ! command -v fvm &> /dev/null; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew tap leoafarias/fvm
        brew install fvm
    else
        curl -fsSL https://fvm.app/install.sh | bash
    fi
fi

# 安装Flutter
echo "📦 安装Flutter..."
fvm install 3.35.4
fvm global 3.35.4

# 安装Rust工具链
echo "📦 安装Rust工具链..."
if ! command -v cargo &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
fi

# 安装开发工具
echo "🔧 安装开发工具..."
cargo install cargo-watch cargo-audit flutter_rust_bridge_codegen

# 安装Flutter依赖
echo "📦 安装Flutter依赖..."
cd frontend
fvm flutter pub get
cd ..

# 安装Rust依赖
echo "📦 安装Rust依赖..."
cd backend
cargo fetch
cd ..

# 生成桥接代码
echo "🔄 生成桥接代码..."
./build.sh

# 设置Git hooks
echo "🪝 设置Git hooks..."
cp scripts/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

echo ""
echo "✅ 开发环境设置完成！"
echo ""
echo "可用命令:"
echo "  just dev          - 启动开发环境"
echo "  just web-dev      - Web开发模式"
echo "  just test         - 运行所有测试"
echo "  just lint         - 代码质量检查"
echo "  just build-all    - 构建所有平台"
echo ""
echo "更多信息: just --list"