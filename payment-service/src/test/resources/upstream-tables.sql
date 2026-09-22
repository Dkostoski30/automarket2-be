-- Tables this service's migrations do NOT create, stubbed so Flyway can run
-- against an isolated database.
--
-- This is not test scaffolding for its own sake: payment-service's projection
-- backfill reads users, owned by auth-service. In the cluster the owner's schema is on this service's
-- migration search_path (db/migration/beforeEachMigrate.sql), so the table is found — but
-- migrations run with no ordering between services, so on a cold start this
-- service's migration can fail until the owner catches up. It recovers (the
-- migration is transactional and Flyway retries next boot), yet it makes the
-- dependency real rather than theoretical.
--
-- Loaded by the container, before Flyway. Columns match only what the backfill
-- selects.

-- Each table lives in the schema of the service that owns it, as in the cluster.
CREATE SCHEMA IF NOT EXISTS auth;

CREATE TABLE IF NOT EXISTS auth.users (
    id    UUID PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    name  VARCHAR(100) NOT NULL
);
