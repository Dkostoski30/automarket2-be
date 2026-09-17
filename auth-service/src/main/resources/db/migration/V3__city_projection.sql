-- Local read model of cities, owned by auth-service.
--
-- Replaces the @Immutable view that mapped onto listing-service's `cities` table.
-- Seeded here from `cities` while every service still shares one schema.
--
-- No consumer and no event stream, deliberately: cities are static reference data
-- with no mutation endpoint anywhere in the system (AdminReferenceController exposes
-- car brands only). If cities ever become editable, listing-service should publish
-- reference.city.* events and auth-service should consume them here - the same
-- pattern already used for users.

CREATE TABLE IF NOT EXISTS auth_city_view (
    id   UUID PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

INSERT INTO auth_city_view (id, name)
SELECT c.id, c.name FROM cities c
ON CONFLICT (id) DO NOTHING;
