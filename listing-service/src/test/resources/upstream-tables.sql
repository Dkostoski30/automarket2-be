-- Tables this service's migrations do NOT create, stubbed so Flyway can run
-- against an isolated database.
--
-- This is not test scaffolding for its own sake: listing-service's projection
-- backfill reads users, owned by auth-service. Every service currently
-- shares one schema, so in the cluster the table happens to be there — but
-- migrations run with no ordering between services, so on a cold start this
-- service's migration can fail until the owner catches up. It recovers (the
-- migration is transactional and Flyway retries next boot), yet it makes the
-- dependency real rather than theoretical.
--
-- Loaded by the container, before Flyway. Columns match only what the backfill
-- selects.

CREATE TABLE IF NOT EXISTS users (
    id         UUID PRIMARY KEY,
    email      VARCHAR(255) NOT NULL,
    name       VARCHAR(100) NOT NULL,
    phone      VARCHAR(30),
    city_id    UUID,
    plan       VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE,
    deleted_at TIMESTAMP WITH TIME ZONE
);
