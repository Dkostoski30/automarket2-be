-- ═══════════════════════════════════════════════════════════════════
-- V11: Seed test users with different roles for development
-- ═══════════════════════════════════════════════════════════════════

-- SuperAdmin user
INSERT INTO users (email, password_hash, name, phone, plan, enabled)
VALUES ('superadmin@automarket.mk',
        '$2b$12$Ct9XdbcsSoVkpkonkYkTFedblgV.p6EG3CD8g/1CDUJg7mH5RomDa',
        'Super Admin', '+389 70 000 001', 'FREE', true)
ON CONFLICT (email) DO NOTHING;

-- Admin user
INSERT INTO users (email, password_hash, name, phone, plan, enabled)
VALUES ('admin@automarket.mk',
        '$2b$12$jk0MghvCRZm3nYMoFOifUurPiFRTo4WZWuo04od7TEL5rj8KNmm/.',
        'Admin User', '+389 70 000 002', 'FREE', true)
ON CONFLICT (email) DO NOTHING;

-- Moderator user
INSERT INTO users (email, password_hash, name, phone, plan, enabled)
VALUES ('moderator@automarket.mk',
        '$2b$12$P0cJrgdMUy70dLVIV4Q3cuqjEuEkGqjgtpnNdsV3YYUwlO18gqOJ2',
        'Moderator User', '+389 70 000 003', 'FREE', true)
ON CONFLICT (email) DO NOTHING;

-- Regular user (free plan)
INSERT INTO users (email, password_hash, name, phone, plan, enabled)
VALUES ('user@automarket.mk',
        '$2b$12$D3bTw/GGM0C6sner3gcOUetV0mAcWVN/9iDbproquixuJ4fHIxGV6',
        'Regular User', '+389 70 000 004', 'FREE', true)
ON CONFLICT (email) DO NOTHING;

-- Premium user
INSERT INTO users (email, password_hash, name, phone, plan, enabled)
VALUES ('premium@automarket.mk',
        '$2b$12$kyMGKTtlVQeQPdIYHvFRbeSl5GNf4iV/AcsitunD2TkXyjC.oTZRC',
        'Premium User', '+389 70 000 005', 'PREMIUM', true)
ON CONFLICT (email) DO NOTHING;

-- Assign roles
-- SuperAdmin gets ROLE_USER + ROLE_SUPERADMIN
INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id FROM users u, roles r
WHERE u.email = 'superadmin@automarket.mk' AND r.name IN ('ROLE_USER', 'ROLE_SUPERADMIN')
ON CONFLICT DO NOTHING;

-- Admin gets ROLE_USER + ROLE_ADMIN
INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id FROM users u, roles r
WHERE u.email = 'admin@automarket.mk' AND r.name IN ('ROLE_USER', 'ROLE_ADMIN')
ON CONFLICT DO NOTHING;

-- Moderator gets ROLE_USER + ROLE_MODERATOR
INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id FROM users u, roles r
WHERE u.email = 'moderator@automarket.mk' AND r.name IN ('ROLE_USER', 'ROLE_MODERATOR')
ON CONFLICT DO NOTHING;

-- Regular user gets ROLE_USER
INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id FROM users u, roles r
WHERE u.email = 'user@automarket.mk' AND r.name = 'ROLE_USER'
ON CONFLICT DO NOTHING;

-- Premium user gets ROLE_USER
INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id FROM users u, roles r
WHERE u.email = 'premium@automarket.mk' AND r.name = 'ROLE_USER'
ON CONFLICT DO NOTHING;