-- Local read model of users, owned by this service.
--
-- Replaces the @Immutable JPA view that mapped straight onto auth-service's `users`
-- table. That cross-context read is what made a schema-per-service split impossible:
-- the mapping was a real table dependency, not just a query.
--
-- Kept current by UserEventConsumer from the user-events topic. The backfill below
-- seeds it from `users` while every service still shares one schema - a one-time
-- migration step that stops being possible once the schemas are separated, which is
-- precisely why it runs now.

CREATE TABLE IF NOT EXISTS listing_user_view (
    id         UUID PRIMARY KEY,
    email      VARCHAR(255) NOT NULL,
    name       VARCHAR(100) NOT NULL,
    phone      VARCHAR(30),
    city_name  VARCHAR(100),
    plan       VARCHAR(20)  NOT NULL DEFAULT 'FREE',
    created_at TIMESTAMP WITH TIME ZONE,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_listing_user_view_email ON listing_user_view(email);

INSERT INTO listing_user_view (id, email, name, phone, city_name, plan, created_at, deleted_at)
SELECT u.id, u.email, u.name, u.phone, c.name, u.plan, u.created_at, u.deleted_at
FROM users u
LEFT JOIN cities c ON c.id = u.city_id
ON CONFLICT (id) DO NOTHING;
