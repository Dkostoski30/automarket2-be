-- Transactional outbox.
--
-- Events are written here in the same transaction as the state change that produced
-- them, then relayed to Kafka by OutboxRelay. This removes the dual-write hazard of
-- publishing from inside a transaction: either the state change and the event both
-- commit, or neither does.
--
-- source_service exists only because every service currently shares one schema, so
-- each relay must poll its own rows. It becomes redundant (but harmless) after the
-- schema-per-service split, which is why the table is not suffixed per service.

CREATE TABLE IF NOT EXISTS outbox (
    id             UUID PRIMARY KEY,
    source_service VARCHAR(64)  NOT NULL,
    topic          VARCHAR(255) NOT NULL,
    event_key      VARCHAR(255) NOT NULL,
    event_type     VARCHAR(128) NOT NULL,
    payload        TEXT         NOT NULL,
    created_at     TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    published_at   TIMESTAMP WITH TIME ZONE,
    attempts       INTEGER      NOT NULL DEFAULT 0,
    last_error     VARCHAR(1000)
);

-- Covers the relay's claim query: pending rows for one service, oldest first.
CREATE INDEX IF NOT EXISTS idx_outbox_pending
    ON outbox (source_service, published_at, created_at);

-- Consumer-side deduplication for at-least-once delivery.
-- Composite key: two consumer groups may each process the same event once.
CREATE TABLE IF NOT EXISTS processed_event (
    event_id       VARCHAR(64)  NOT NULL,
    consumer_group VARCHAR(128) NOT NULL,
    event_type     VARCHAR(128),
    processed_at   TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    PRIMARY KEY (event_id, consumer_group)
);
