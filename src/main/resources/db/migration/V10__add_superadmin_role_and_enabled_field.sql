-- ═══════════════════════════════════════════════════════════════════
-- V10: Add ROLE_SUPERADMIN, widen roles.name column, add enabled field to users
-- ═══════════════════════════════════════════════════════════════════

-- Widen the roles name column to accommodate ROLE_SUPERADMIN (15 chars)
ALTER TABLE roles ALTER COLUMN name TYPE VARCHAR(30);

-- Insert new SUPERADMIN role
INSERT INTO roles (name) VALUES ('ROLE_SUPERADMIN');

-- Add enabled field to users (default true for all existing users)
ALTER TABLE users ADD COLUMN enabled BOOLEAN NOT NULL DEFAULT true;

-- Assign SUPERADMIN to admin@automarket.mk if exists
INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id FROM users u, roles r
WHERE u.email = 'admin@automarket.mk' AND r.name = 'ROLE_SUPERADMIN'
ON CONFLICT DO NOTHING;
