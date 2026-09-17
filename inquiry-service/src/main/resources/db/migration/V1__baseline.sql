-- Inquiry-service baseline schema
-- baseline-on-migrate: true means this runs only on fresh DBs; existing DBs are baselined at V0.

CREATE TABLE IF NOT EXISTS inquiries (
    id             UUID PRIMARY KEY,
    listing_id     UUID NOT NULL,
    sender_id      UUID NOT NULL,
    message        TEXT NOT NULL,
    read_by_seller BOOLEAN NOT NULL DEFAULT FALSE,
    created_at     TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_inquiries_sender_id  ON inquiries(sender_id);
CREATE INDEX IF NOT EXISTS idx_inquiries_listing_id ON inquiries(listing_id);
