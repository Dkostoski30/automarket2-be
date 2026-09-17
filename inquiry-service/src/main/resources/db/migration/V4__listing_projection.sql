-- Local read model of listings, owned by inquiry-service.
--
-- Replaces the @Immutable view that mapped onto listing-service's `listings` table.
-- Kept current by ListingEventConsumer from the listing-events topic; seeded below
-- from `listings` while every service still shares one schema.

CREATE TABLE IF NOT EXISTS inquiry_listing_view (
    id         UUID PRIMARY KEY,
    title      VARCHAR(100) NOT NULL,
    seller_id  UUID NOT NULL,
    approved   BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_inquiry_listing_view_seller ON inquiry_listing_view(seller_id);

INSERT INTO inquiry_listing_view (id, title, seller_id, approved)
SELECT l.id, l.title, l.seller_id, l.approved FROM listings l
ON CONFLICT (id) DO NOTHING;
