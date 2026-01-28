#!/bin/bash
# 开发效率工具脚本集合

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 快速切换分支
switch_branch() {
    local branch=$1
    if [ -z "$branch" ]; then
        log_error "请提供分支名称"
        return 1
    fi
    
    log_info "切换到分支: $branch"
    git checkout "$branch" && git pull origin "$branch"
    log_success "分支切换完成"
}

# 快速创建功能分支
create_feature() {
    local feature=$1
    if [ -z "$feature" ]; then
        log_error "请提供功能名称"
        return 1
    fi
    
    local branch="feature/$feature"
    log_info "创建功能分支: $branch"
    git checkout -b "$branch"
    log_success "功能分支创建完成"
}

# 快速提交
quick_commit() {
    local message=$1
    if [ -z "$message" ]; then
        log_error "请提供提交信息"
        return 1
    fi
    
    log_info "快速提交: $message"
    git add . && git commit -m "$message"
    log_success "提交完成"
}

# 快速推送
quick_push() {
    local branch=$(git branch --show-current)
    log_info "推送到远程分支: $branch"
    git push origin "$branch"
    log_success "推送完成"
}

# 查看项目状态
project_status() {
    log_info "项目状态概览"
    echo "=================="
    
    # Git状态
    echo -e "${BLUE}Git状态:${NC}"
    git status --short
    
    # Rust状态
    echo -e "\n${BLUE}Rust状态:${NC}"
    cd backend && cargo check --quiet 2>/dev/null && log_success "Rust编译通过" || log_warning "Rust编译失败"
    
    # Flutter状态
    echo -e "\n${BLUE}Flutter状态:${NC}"
    cd ../frontend && fvm flutter analyze --quiet 2>/dev/null && log_success "Flutter分析通过" || log_warning "Flutter分析失败"
    
    # 依赖状态
    echo -e "\n${BLUE}依赖状态:${NC}"
    cd ../backend && cargo tree --duplicates 2>/dev/null | grep -q "duplicate" && log_warning "发现重复依赖" || log_success "依赖正常"
    cd ../frontend && fvm flutter pub deps --style=compact 2>/dev/null | grep -q "conflict" && log_warning "发现依赖冲突" || log_success "依赖正常"
    
    cd ..
}

# 快速清理
clean_all() {
    log_info "清理项目..."
    
    # Git清理
    git gc --aggressive --prune=now
    
    # Rust清理
    cd backend && cargo clean
    
    # Flutter清理
    cd ../frontend && fvm flutter clean
    
    # 系统清理
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sudo purge
    fi
    
    cd ..
    log_success "清理完成"
}

# 性能监控
monitor_performance() {
    log_info "性能监控"
    
    # 磁盘使用
    echo -e "${BLUE}磁盘使用:${NC}"
    du -sh . 2>/dev/null
    du -sh backend/target frontend/build 2>/dev/null | sort -hr
    
    # 内存使用
    echo -e "\n${BLUE}内存使用:${NC}"
    if command -v free &> /dev/null; then
        free -h
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        vm_stat | head -6
    fi
    
    # CPU使用
    echo -e "\n${BLUE}CPU使用:${NC}"
    if command -v htop &> /dev/null; then
        echo "htop可用，运行 'htop' 查看详细信息"
    else
        top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}'
    fi
}

# 快速搜索
quick_search() {
    local query=$1
    if [ -z "$query" ]; then
        log_error "请提供搜索关键词"
        return 1
    fi
    
    log_info "搜索: $query"
    
    # 搜索Rust代码
    echo -e "${BLUE}Rust代码:${NC}"
    grep -r --include="*.rs" "$query" backend/ | head -5
    
    # 搜索Dart代码
    echo -e "\n${BLUE}Dart代码:${NC}"
    grep -r --include="*.dart" "$query" frontend/ | head -5
    
    # 搜索配置文件
    echo -e "\n${BLUE}配置文件:${NC}"
    grep -r --include="*.toml" --include="*.yaml" --include="*.yml" "$query" . | head -5
}

# 快速文档生成
generate_docs() {
    log_info "生成文档..."
    
    # Rust文档
    cd backend && cargo doc --no-deps
    
    # Flutter文档
    cd ../frontend && fvm dart doc .
    
    cd ..
    log_success "文档生成完成"
}

# 快速测试
quick_test() {
    local scope=$1
    
    case $scope in
        "rust"|"backend")
            log_info "运行Rust测试..."
            cd backend && cargo test
            ;;
        "flutter"|"frontend")
            log_info "运行Flutter测试..."
            cd frontend && fvm flutter test
            ;;
        "all"|"")
            log_info "运行所有测试..."
            cd backend && cargo test
            cd ../frontend && fvm flutter test
            ;;
        *)
            log_error "未知测试范围: $scope"
            return 1
            ;;
    esac
    
    cd ..
    log_success "测试完成"
}

# 主函数
main() {
    local command=$1
    shift
    
    case $command in
        "switch"|"sw")
            switch_branch "$@"
            ;;
        "feature"|"feat")
            create_feature "$@"
            ;;
        "commit"|"ci")
            quick_commit "$@"
            ;;
        "push")
            quick_push
            ;;
        "status"|"st")
            project_status
            ;;
        "clean")
            clean_all
            ;;
        "monitor"|"mon")
            monitor_performance
            ;;
        "search"|"find")
            quick_search "$@"
            ;;
        "docs")
            generate_docs
            ;;
        "test"|"t")
            quick_test "$@"
            ;;
        "help"|"h"|"")
            echo "开发效率工具"
            echo "============="
            echo "Usage: ./dev-tools.sh <command> [args]"
            echo ""
            echo "Commands:"
            echo "  switch <branch>     - 切换分支"
            echo "  feature <name>      - 创建功能分支"
            echo "  commit <message>    - 快速提交"
            echo "  push               - 快速推送"
            echo "  status             - 查看项目状态"
            echo "  clean              - 清理项目"
            echo "  monitor            - 性能监控"
            echo "  search <query>     - 快速搜索"
            echo "  docs               - 生成文档"
            echo "  test [scope]       - 快速测试"
            echo "  help               - 显示帮助"
            ;;
        *)
            log_error "未知命令: $command"
            echo "运行 './dev-tools.sh help' 查看帮助"
            return 1
            ;;
    esac
}

# 执行主函数
main "$@"