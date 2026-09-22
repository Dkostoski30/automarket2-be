-- Local read model of listings, owned by auth-service.
--
-- Exists for one number: the `totalListings` on a public seller profile, which was
-- hardcoded to 0 (ISSUES.md #28) because the count lived in listing-service and was
-- never reconnected after the monolith was split.
--
-- A row per listing rather than a per-seller counter, deliberately. A counter has to
-- be incremented and decremented from events, and `listing.deleted` carries only the
-- listing id — there is no way to know whether the listing it removes was approved,
-- so the counter would drift. Storing the projectable state instead makes every
-- handler a blind upsert or a delete by primary key: replaying the topic produces the
-- same table, which is why this projection needs no inbox dedup table.
--
-- "Active" here means the same thing it means in listing-service's
-- countActiveBySellerId: approved and not deleted. Rejection soft-deletes the
-- listing, so a rejected listing is removed from this table rather than flagged.
--
-- Seeded from `listings` while every service still shares one schema, the same way
-- V3 seeds cities. Kept current afterwards by ListingEventConsumer.

CREATE TABLE IF NOT EXISTS auth_listing_view (
    listing_id UUID PRIMARY KEY,
    seller_id  UUID NOT NULL,
    approved   BOOLEAN NOT NULL DEFAULT FALSE
);

-- The only query this table serves: count a seller's approved listings.
CREATE INDEX IF NOT EXISTS idx_auth_listing_view_seller
    ON auth_listing_view (seller_id, approved);

INSERT INTO auth_listing_view (listing_id, seller_id, approved)
SELECT l.id, l.seller_id, l.approved
FROM listings l
WHERE l.deleted_at IS NULL
ON CONFLICT (listing_id) DO NOTHING;
