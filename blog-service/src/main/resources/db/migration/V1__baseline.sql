-- Blog-service baseline schema
-- baseline-on-migrate: true means this runs only on fresh DBs; existing DBs are baselined at V0.

CREATE TABLE IF NOT EXISTS blogs (
    id              UUID PRIMARY KEY,
    title           VARCHAR(100) NOT NULL,
    slug            VARCHAR(200) NOT NULL UNIQUE,
    excerpt         VARCHAR(500) NOT NULL,
    content         TEXT NOT NULL,
    cover_image_url VARCHAR(1024),
    cover_image_key VARCHAR(1024),
    published       BOOLEAN NOT NULL DEFAULT FALSE,
    author_id       UUID,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at      TIMESTAMP WITH TIME ZONE NOT NULL,
    created_by      VARCHAR(255)
);

CREATE INDEX IF NOT EXISTS idx_blogs_slug      ON blogs(slug);
CREATE INDEX IF NOT EXISTS idx_blogs_published ON blogs(published);
