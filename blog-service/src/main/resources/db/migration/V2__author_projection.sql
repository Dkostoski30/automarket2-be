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

CREATE TABLE IF NOT EXISTS blog_author_view (
    id    UUID PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    name  VARCHAR(100) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_blog_author_view_email ON blog_author_view(email);

INSERT INTO blog_author_view (id, email, name)
SELECT u.id, u.email, u.name FROM users u
ON CONFLICT (id) DO NOTHING;
