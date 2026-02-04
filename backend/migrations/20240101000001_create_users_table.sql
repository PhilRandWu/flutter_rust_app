CREATE TABLE IF NOT EXISTS users (
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    username VARCHAR(50) NOT NULL,
    password VARCHAR(255) NOT NULL,
    otp_enabled BOOLEAN DEFAULT false,
    otp_verified BOOLEAN DEFAULT false,
    otp_base32 TEXT,
    otp_auth_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    -- 主键约束
    PRIMARY KEY (id),
    -- 用户名唯一约束
    UNIQUE (username)
);