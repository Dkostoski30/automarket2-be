-- ═══════════════════════════════════════════════════════════════════
-- V9: Add slug, excerpt, cover_image_url, cover_image_key, published
--     to blogs table; drop legacy image_url column
-- ═══════════════════════════════════════════════════════════════════

-- Add new columns (nullable first so existing rows don't break)
ALTER TABLE blogs ADD COLUMN slug            VARCHAR(200);
ALTER TABLE blogs ADD COLUMN excerpt         VARCHAR(500);
ALTER TABLE blogs ADD COLUMN cover_image_url VARCHAR(1024);
ALTER TABLE blogs ADD COLUMN cover_image_key VARCHAR(1024);
ALTER TABLE blogs ADD COLUMN published       BOOLEAN NOT NULL DEFAULT FALSE;

-- Back-fill slug from title for existing rows (lowercase, spaces → hyphens, strip non-word chars)
UPDATE blogs
SET slug    = LOWER(REGEXP_REPLACE(REGEXP_REPLACE(title, '[^\\w\\s-]', '', 'g'), '\\s+', '-', 'g')),
    excerpt = LEFT(content, 200)
WHERE slug IS NULL;

-- Deduplicate slugs if any collisions after back-fill
UPDATE blogs b
SET slug = b.slug || '-' || b.id::text
WHERE (SELECT COUNT(*) FROM blogs b2 WHERE b2.slug = b.slug) > 1;

-- Copy image_url to cover_image_url for existing rows
UPDATE blogs SET cover_image_url = image_url WHERE image_url IS NOT NULL;

-- Now enforce NOT NULL and UNIQUE on slug, NOT NULL on excerpt
ALTER TABLE blogs ALTER COLUMN slug SET NOT NULL;
ALTER TABLE blogs ALTER COLUMN excerpt SET NOT NULL;
ALTER TABLE blogs ADD CONSTRAINT uq_blogs_slug UNIQUE (slug);

-- Drop the old column
ALTER TABLE blogs DROP COLUMN image_url;

CREATE INDEX idx_blogs_slug ON blogs(slug);
