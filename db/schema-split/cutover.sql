-- ============================================================================
-- Schema-per-service cutover (ARCHITECTURE.md §11.4)
--
-- One-off move of a database created before the split. Moves every table from
-- the shared `public` schema into the schema of the service that owns it, and
-- partitions the two tables four services shared (outbox, processed_event) so
-- each gets its own. A database created after the split never needs it: the
-- services create their schemas themselves.
--
-- WHO RUNS IT
--   Nobody by hand. k8s/deploy.sh (step 4b) and the `db-schema-split` service in
--   docker-compose.yml run it when they find public.flyway_history_auth, after
--   the services are stopped and before the new ones start. The services refuse
--   to boot against the old layout (spring.flyway.init-sqls), so an image rolled
--   out any other way — ArgoCD included — crash-loops with that message instead
--   of creating empty tables. To cut over under ArgoCD, run deploy.sh once, or:
--     kubectl -n automarket scale deploy auth-service listing-service blog-service inquiry-service payment-service --replicas=0
--     kubectl -n automarket exec -i postgres-0 -- psql -U automarket -d automarket -v ON_ERROR_STOP=1 < db/schema-split/cutover.sql
--
-- WHY IT IS NOT A FLYWAY MIGRATION
--   Flyway cannot move its own history table, and the move has to happen while
--   no service is running: an old pod still polling public.outbox after the move
--   would write events nobody relays.
--
-- It is one transaction and applies fully or not at all. Undo = restore the
-- pg_dump deploy.sh takes first, and deploy the previous release.
--
-- Kafka needs no handling: consumers resume from their committed offsets, and
-- events published while the services were down are simply consumed late.
-- Undelivered outbox rows move with their table and are relayed on restart.
-- ============================================================================

BEGIN;

-- Refuse to run while any service is connected. pgjdbc identifies itself with
-- this application_name by default; psql (this session) does not.
DO $$
DECLARE live INTEGER;
BEGIN
    SELECT count(*) INTO live FROM pg_stat_activity
     WHERE datname = current_database()
       AND pid <> pg_backend_pid()
       AND application_name = 'PostgreSQL JDBC Driver';
    IF live > 0 THEN
        RAISE EXCEPTION '% JDBC connection(s) still open. Scale the services to zero first.', live;
    END IF;
END $$;

-- Refuse to run twice. Without this the transaction would still roll back, but
-- on a far less obvious error (relation "public.users" does not exist).
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'auth') THEN
        RAISE EXCEPTION 'Schema "auth" already exists — the cutover has already run.';
    END IF;
END $$;

CREATE SCHEMA auth;
CREATE SCHEMA listing;
CREATE SCHEMA blog;
CREATE SCHEMA inquiry;
CREATE SCHEMA payment;

-- ── auth-service ────────────────────────────────────────────────────────────
ALTER TABLE public.users               SET SCHEMA auth;
ALTER TABLE public.roles               SET SCHEMA auth;
ALTER TABLE public.user_roles          SET SCHEMA auth;
ALTER TABLE public.refresh_tokens      SET SCHEMA auth;
ALTER TABLE public.auth_city_view      SET SCHEMA auth;
ALTER TABLE public.auth_listing_view   SET SCHEMA auth;
ALTER TABLE public.flyway_history_auth SET SCHEMA auth;

-- ── listing-service ─────────────────────────────────────────────────────────
ALTER TABLE public.cities                 SET SCHEMA listing;
ALTER TABLE public.car_brands             SET SCHEMA listing;
ALTER TABLE public.body_types             SET SCHEMA listing;
ALTER TABLE public.fuel_types             SET SCHEMA listing;
ALTER TABLE public.transmission_types     SET SCHEMA listing;
ALTER TABLE public.condition_types        SET SCHEMA listing;
ALTER TABLE public.listings               SET SCHEMA listing;
ALTER TABLE public.listing_images         SET SCHEMA listing;
ALTER TABLE public.listing_analytics      SET SCHEMA listing;
ALTER TABLE public.favorites              SET SCHEMA listing;
ALTER TABLE public.listing_user_view      SET SCHEMA listing;
ALTER TABLE public.flyway_history_listing SET SCHEMA listing;

-- ── blog-service ────────────────────────────────────────────────────────────
ALTER TABLE public.blogs               SET SCHEMA blog;
ALTER TABLE public.blog_author_view    SET SCHEMA blog;
ALTER TABLE public.flyway_history_blog SET SCHEMA blog;

-- ── inquiry-service ─────────────────────────────────────────────────────────
ALTER TABLE public.inquiries              SET SCHEMA inquiry;
ALTER TABLE public.conversations          SET SCHEMA inquiry;
ALTER TABLE public.messages               SET SCHEMA inquiry;
ALTER TABLE public.inquiry_user_view      SET SCHEMA inquiry;
ALTER TABLE public.inquiry_listing_view   SET SCHEMA inquiry;
ALTER TABLE public.flyway_history_inquiry SET SCHEMA inquiry;

-- ── payment-service ─────────────────────────────────────────────────────────
ALTER TABLE public.subscriptions          SET SCHEMA payment;
ALTER TABLE public.payment_user_view      SET SCHEMA payment;
ALTER TABLE public.flyway_history_payment SET SCHEMA payment;

-- ── Partition the shared outbox and inbox ───────────────────────────────────
-- Four services created one `outbox` and one `processed_event` in public, told
-- apart by source_service / consumer_group. Each now gets its own copy holding
-- only its own rows. Undelivered events move with them, so the relay picks them
-- up on restart and nothing is lost across the cutover. blog-service neither
-- publishes nor deduplicates, so it gets neither table.
CREATE TABLE auth.outbox    (LIKE public.outbox INCLUDING ALL);
CREATE TABLE listing.outbox (LIKE public.outbox INCLUDING ALL);
CREATE TABLE inquiry.outbox (LIKE public.outbox INCLUDING ALL);
CREATE TABLE payment.outbox (LIKE public.outbox INCLUDING ALL);

INSERT INTO auth.outbox    SELECT * FROM public.outbox WHERE source_service = 'auth-service';
INSERT INTO listing.outbox SELECT * FROM public.outbox WHERE source_service = 'listing-service';
INSERT INTO inquiry.outbox SELECT * FROM public.outbox WHERE source_service = 'inquiry-service';
INSERT INTO payment.outbox SELECT * FROM public.outbox WHERE source_service = 'payment-service';

CREATE TABLE auth.processed_event    (LIKE public.processed_event INCLUDING ALL);
CREATE TABLE listing.processed_event (LIKE public.processed_event INCLUDING ALL);
CREATE TABLE inquiry.processed_event (LIKE public.processed_event INCLUDING ALL);
CREATE TABLE payment.processed_event (LIKE public.processed_event INCLUDING ALL);

INSERT INTO auth.processed_event    SELECT * FROM public.processed_event WHERE consumer_group = 'auth-service';
INSERT INTO listing.processed_event SELECT * FROM public.processed_event WHERE consumer_group = 'listing-service';
INSERT INTO inquiry.processed_event SELECT * FROM public.processed_event WHERE consumer_group = 'inquiry-service';
INSERT INTO payment.processed_event SELECT * FROM public.processed_event WHERE consumer_group = 'payment-service';

-- Every row must have landed somewhere. A row owned by anything other than the
-- four services above is something this script did not anticipate, and dropping
-- the shared table would destroy it — so abort the whole cutover instead.
DO $$
DECLARE stray_outbox INTEGER; stray_inbox INTEGER;
BEGIN
    SELECT count(*) INTO stray_outbox FROM public.outbox
     WHERE source_service NOT IN ('auth-service', 'listing-service', 'inquiry-service', 'payment-service');
    SELECT count(*) INTO stray_inbox FROM public.processed_event
     WHERE consumer_group NOT IN ('auth-service', 'listing-service', 'inquiry-service', 'payment-service');
    IF stray_outbox > 0 OR stray_inbox > 0 THEN
        RAISE EXCEPTION 'Unowned rows: % in outbox, % in processed_event. Nothing was changed.',
            stray_outbox, stray_inbox;
    END IF;
END $$;

DROP TABLE public.outbox;
DROP TABLE public.processed_event;

-- Nothing owned by a service may remain in public. Catches a table added by a
-- future migration that this script was not updated for.
DO $$
DECLARE leftover TEXT;
BEGIN
    SELECT string_agg(table_name, ', ') INTO leftover
      FROM information_schema.tables
     WHERE table_schema = 'public' AND table_type = 'BASE TABLE';
    IF leftover IS NOT NULL THEN
        RAISE EXCEPTION 'Tables still in public after the move: %. Nothing was changed.', leftover;
    END IF;
END $$;

COMMIT;
