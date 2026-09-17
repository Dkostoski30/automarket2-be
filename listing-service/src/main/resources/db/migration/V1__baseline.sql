-- Listing-service baseline schema
-- baseline-on-migrate: true means this runs only on fresh DBs; existing DBs are baselined at V0.

CREATE TABLE IF NOT EXISTS cities (
    id   UUID PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS car_brands (
    id   UUID PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS body_types (
    id   UUID PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS fuel_types (
    id   UUID PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS transmission_types (
    id   UUID PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS condition_types (
    id   UUID PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS listings (
    id                    UUID PRIMARY KEY,
    title                 VARCHAR(100) NOT NULL,
    slug                  VARCHAR(150) NOT NULL UNIQUE,
    description           VARCHAR(2000) NOT NULL,
    price                 NUMERIC(12, 2) NOT NULL,
    condition_type_id     UUID REFERENCES condition_types(id),
    approved              BOOLEAN NOT NULL DEFAULT FALSE,
    featured              BOOLEAN NOT NULL DEFAULT FALSE,
    featured_until        TIMESTAMP WITH TIME ZONE,
    seller_id             UUID NOT NULL,
    car_brand_id          UUID REFERENCES car_brands(id),
    car_model             VARCHAR(100) NOT NULL,
    registration_year     INTEGER NOT NULL,
    kilometers            INTEGER NOT NULL,
    fuel_type_id          UUID REFERENCES fuel_types(id),
    body_type_id          UUID REFERENCES body_types(id),
    transmission_type_id  UUID REFERENCES transmission_types(id),
    num_doors             INTEGER,
    num_seats             INTEGER,
    kilowatts             INTEGER,
    deleted_at            TIMESTAMP WITH TIME ZONE,
    attributes            JSONB,
    created_at            TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at            TIMESTAMP WITH TIME ZONE NOT NULL,
    created_by            VARCHAR(255)
);

CREATE INDEX IF NOT EXISTS idx_listings_seller_id ON listings(seller_id);
CREATE INDEX IF NOT EXISTS idx_listings_approved  ON listings(approved) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS listing_images (
    id            UUID PRIMARY KEY,
    listing_id    UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    storage_key   VARCHAR NOT NULL,
    url           VARCHAR(1024) NOT NULL,
    display_order INTEGER NOT NULL DEFAULT 0,
    created_at    TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS listing_analytics (
    id             UUID PRIMARY KEY,
    listing_id     UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    date           DATE NOT NULL,
    view_count     INTEGER NOT NULL DEFAULT 0,
    inquiry_count  INTEGER NOT NULL DEFAULT 0,
    favorite_count INTEGER NOT NULL DEFAULT 0,
    UNIQUE (listing_id, date)
);

CREATE TABLE IF NOT EXISTS favorites (
    id         UUID PRIMARY KEY,
    user_id    UUID NOT NULL,
    listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    UNIQUE (user_id, listing_id)
);
