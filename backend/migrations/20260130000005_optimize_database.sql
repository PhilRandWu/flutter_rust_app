-- 优化数据库设计

-- 1. 优化 users 表

-- 修改 password 字段长度，Argon2id 哈希值通常为 100-150 个字符
ALTER TABLE users ALTER COLUMN password TYPE VARCHAR(150);

-- 修改 email 字段为 NOT NULL，并添加检查约束确保格式正确
ALTER TABLE users ALTER COLUMN email SET NOT NULL;
ALTER TABLE users ADD CONSTRAINT check_email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$');

-- 添加 is_deleted 字段用于软删除
ALTER TABLE users ADD COLUMN is_deleted BOOLEAN NOT NULL DEFAULT false;

-- 修改唯一约束，考虑软删除的情况
ALTER TABLE users DROP CONSTRAINT unique_email;
ALTER TABLE users ADD CONSTRAINT unique_username UNIQUE (username);
ALTER TABLE users ADD CONSTRAINT unique_email UNIQUE (email);

-- 添加索引
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_is_deleted ON users(is_deleted);
CREATE INDEX idx_users_created_at ON users(created_at);

-- 2. 优化 user_tokens 表

-- 添加 token_type 字段，支持多种类型的令牌
ALTER TABLE user_tokens ADD COLUMN token_type VARCHAR(20) NOT NULL DEFAULT 'refresh';

-- 确保 token_id 索引考虑 token_type
DROP INDEX IF EXISTS idx_user_tokens_token_id;
CREATE INDEX idx_user_tokens_token_id_type ON user_tokens(token_id, token_type);

-- 3. 创建角色表和用户角色关系表，实现基于角色的访问控制
CREATE TABLE IF NOT EXISTS roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS user_roles (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id INTEGER NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, role_id)
);

-- 4. 创建审计日志表
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50) NOT NULL,
    resource_id VARCHAR(100),
    details JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 添加审计日志索引
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_resource ON audit_logs(resource_type, resource_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);

-- 5. 创建 OTP 单独表，减少 users 表宽度
CREATE TABLE IF NOT EXISTS user_otp (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    otp_verified BOOLEAN NOT NULL DEFAULT false,
    otp_base32 TEXT NOT NULL,
    otp_auth_url TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 从 users 表迁移 OTP 数据到 user_otp 表
INSERT INTO user_otp (user_id, otp_verified, otp_base32, otp_auth_url)
SELECT id, otp_verified, otp_base32, otp_auth_url
FROM users
WHERE otp_enabled = true AND otp_base32 IS NOT NULL;

-- 移除 users 表中的 OTP 相关字段
ALTER TABLE users DROP COLUMN otp_enabled;
ALTER TABLE users DROP COLUMN otp_verified;
ALTER TABLE users DROP COLUMN otp_base32;
ALTER TABLE users DROP COLUMN otp_auth_url;

-- 6. 初始化角色数据
INSERT INTO roles (name, description) VALUES
('user', '普通用户'),
('admin', '管理员')
ON CONFLICT (name) DO NOTHING;
