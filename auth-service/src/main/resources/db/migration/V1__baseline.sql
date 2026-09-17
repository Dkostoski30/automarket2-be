-- Auth-service baseline schema
-- baseline-on-migrate: true means this runs only on fresh DBs; existing DBs are baselined at V0.

CREATE TABLE IF NOT EXISTS roles (
    id          UUID PRIMARY KEY,
    name        VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS users (
    id            UUID PRIMARY KEY,
    email         VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR NOT NULL,
    name          VARCHAR(100) NOT NULL,
    phone         VARCHAR(30),
    city_id       UUID,
    plan          VARCHAR(20) NOT NULL DEFAULT 'FREE',
    deleted_at    TIMESTAMP WITH TIME ZONE,
    created_at    TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at    TIMESTAMP WITH TIME ZONE NOT NULL,
    created_by    VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS user_roles (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, role_id)
);

CREATE TABLE IF NOT EXISTS refresh_tokens (
    id          UUID PRIMARY KEY,
    token       VARCHAR(512) NOT NULL UNIQUE,
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    expires_at  TIMESTAMP WITH TIME ZONE NOT NULL,
    revoked     BOOLEAN NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Seed default roles
INSERT INTO roles (id, name) VALUES
    (gen_random_uuid(), 'ROLE_USER'),
    (gen_random_uuid(), 'ROLE_MODERATOR'),
    (gen_random_uuid(), 'ROLE_ADMIN')
ON CONFLICT (name) DO NOTHING;
