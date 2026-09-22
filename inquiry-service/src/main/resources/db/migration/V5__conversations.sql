-- Threaded conversations.
--
-- `inquiries` modelled one-directional, one-shot messages: a buyer wrote to a
-- listing and the seller could only answer outside the app. A thread is the pair
-- (listing, buyer) — a buyer asking about two cars from the same seller gets two
-- threads, which is what both sides expect from a marketplace inbox.
--
-- Unread counts are denormalised per participant. The alternative, a per-message
-- read flag, makes the inbox badge a scan of every message the user can see; this
-- makes it one indexed row per thread. Both counters are maintained in the same
-- transaction as the message insert (ConversationService), so they cannot drift.
--
-- `inquiries` is NOT dropped. It is backfilled below and then left alone as the
-- archive of what was sent before threads existed; nothing writes to it again.

CREATE TABLE IF NOT EXISTS conversations (
    id                   UUID PRIMARY KEY,
    listing_id           UUID NOT NULL,
    buyer_id             UUID NOT NULL,
    seller_id            UUID NOT NULL,
    last_message_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    last_message_preview TEXT,
    buyer_unread         INTEGER NOT NULL DEFAULT 0,
    seller_unread        INTEGER NOT NULL DEFAULT 0,
    created_at           TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    -- One thread per buyer per listing. This is also what makes "contact seller"
    -- idempotent: a second message from the same buyer appends instead of
    -- opening a duplicate thread.
    CONSTRAINT uq_conversations_listing_buyer UNIQUE (listing_id, buyer_id)
);

-- Covers the inbox query for either role: the user's threads, newest activity first.
CREATE INDEX IF NOT EXISTS idx_conversations_buyer
    ON conversations (buyer_id, last_message_at DESC);
CREATE INDEX IF NOT EXISTS idx_conversations_seller
    ON conversations (seller_id, last_message_at DESC);

CREATE TABLE IF NOT EXISTS messages (
    id              UUID PRIMARY KEY,
    conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id       UUID NOT NULL,
    body            TEXT NOT NULL,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_messages_conversation
    ON messages (conversation_id, created_at DESC);

-- ── Backfill ────────────────────────────────────────────────────────────────
--
-- Every existing inquiry becomes the first message of its thread. Old inquiries
-- keep their id as the message id, so an inquiry referenced in a log or an email
-- is still findable.
--
-- The join to inquiry_listing_view is what supplies seller_id; it is an INNER
-- join, so an inquiry whose listing never reached this service's projection is
-- left behind in `inquiries` rather than producing a thread with no seller. That
-- projection is backfilled in V4 from the same database, so in practice the only
-- rows this skips are inquiries about listings that were hard-deleted.

INSERT INTO conversations (
    id, listing_id, buyer_id, seller_id,
    last_message_at, last_message_preview, buyer_unread, seller_unread, created_at)
SELECT
    gen_random_uuid(),
    i.listing_id,
    i.sender_id,
    lv.seller_id,
    MAX(i.created_at),
    -- Preview of the most recent message in the thread.
    (SELECT LEFT(i2.message, 200)
       FROM inquiries i2
      WHERE i2.listing_id = i.listing_id AND i2.sender_id = i.sender_id
      ORDER BY i2.created_at DESC
      LIMIT 1),
    0,
    COUNT(*) FILTER (WHERE NOT i.read_by_seller),
    MIN(i.created_at)
FROM inquiries i
JOIN inquiry_listing_view lv ON lv.id = i.listing_id
GROUP BY i.listing_id, i.sender_id, lv.seller_id
ON CONFLICT (listing_id, buyer_id) DO NOTHING;

INSERT INTO messages (id, conversation_id, sender_id, body, created_at)
SELECT i.id, c.id, i.sender_id, i.message, i.created_at
FROM inquiries i
JOIN conversations c
  ON c.listing_id = i.listing_id AND c.buyer_id = i.sender_id
ON CONFLICT (id) DO NOTHING;
