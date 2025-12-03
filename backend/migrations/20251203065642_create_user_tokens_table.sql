CREATE TABLE user_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(), -- 主键 ID
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE, -- 关联用户 ID（用户删除时级联删除）
    token_id VARCHAR(64) NOT NULL UNIQUE, -- 对应 TokenClaims 中的 jti（token 唯一标识）
    expires_at TIMESTAMP NOT NULL, -- token 过期时间
    created_at TIMESTAMP NOT NULL DEFAULT NOW() -- 记录创建时间（可选，便于排查）
);

-- 索引优化（提高查询效率）
CREATE INDEX idx_user_tokens_user_id ON user_tokens(user_id); -- 按用户 ID 查询
CREATE INDEX idx_user_tokens_token_id ON user_tokens(token_id); -- 按 token_id 查询（验证 refresh token 时用）
CREATE INDEX idx_user_tokens_expires_at ON user_tokens(expires_at); -- 按过期时间查询（清理过期 token 时用）