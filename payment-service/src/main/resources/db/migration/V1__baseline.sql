-- Payment-service baseline schema
-- baseline-on-migrate: true means this runs only on fresh DBs; existing DBs are baselined at V0.

CREATE TABLE IF NOT EXISTS subscriptions (
    id                       UUID PRIMARY KEY,
    user_id                  UUID NOT NULL UNIQUE,
    plan                     VARCHAR(20) NOT NULL,
    status                   VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    stripe_subscription_id   VARCHAR(255),
    stripe_customer_id       VARCHAR(255),
    current_period_start     TIMESTAMP WITH TIME ZONE,
    current_period_end       TIMESTAMP WITH TIME ZONE,
    created_at               TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at               TIMESTAMP WITH TIME ZONE NOT NULL,
    created_by               VARCHAR(255)
);
