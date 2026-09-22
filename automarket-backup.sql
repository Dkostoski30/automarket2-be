--
-- PostgreSQL database dump
--

\restrict keqxPYNw9xF0moiiURCOoD43I8j6YjAYkSKmHurYqUeOIt3abfImd79eIhbc62e

-- Dumped from database version 16.14
-- Dumped by pg_dump version 16.14

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: listings_search_vector_update(); Type: FUNCTION; Schema: public; Owner: automarket
--

CREATE FUNCTION public.listings_search_vector_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.search_vector := to_tsvector('english',
        coalesce(NEW.title, '') || ' ' ||
        coalesce(NEW.description, '') || ' ' ||
        coalesce(NEW.car_model, '')
    );
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.listings_search_vector_update() OWNER TO automarket;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: auth_city_view; Type: TABLE; Schema: public; Owner: automarket
--

CREATE TABLE public.auth_city_view (
    id uuid NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.auth_city_view OWNER TO automarket;

--
-- Name: auth_listing_view; Type: TABLE; Schema: public; Owner: automarket
--

CREATE TABLE public.auth_listing_view (
    listing_id uuid NOT NULL,
    seller_id uuid NOT NULL,
    approved boolean DEFAULT false NOT NULL
);


ALTER TABLE public.auth_listing_view OWNER TO automarket;

--
-- Name: blog_author_view; Type: TABLE; Schema: public; Owner: automarket
--

CREATE TABLE public.blog_author_view (
    id uuid NOT NULL,
    email character varying(255) NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.blog_author_view OWNER TO automarket;

--
-- Name: blogs; Type: TABLE; Schema: public; Owner: automarket
--

CREATE TABLE public.blogs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    title character varying(100) NOT NULL,
    content text NOT NULL,
    author_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying(255),
    slug character varying(200) NOT NULL,
    excerpt character varying(500) NOT NULL,
    cover_image_url character varying(1024),
    cover_image_key character varying(1024),
    published boolean DEFAULT false NOT NULL
);


ALTER TABLE public.blogs OWNER TO automarket;

--
-- Name: body_types; Type: TABLE; Schema: public; Owner: automarket
--

CREATE TABLE public.body_types (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.body_types OWNER TO automarket;

--
-- Name: car_brands; Type: TABLE; Schema: public; Owner: automarket
--

CREATE TABLE public.car_brands (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.car_brands OWNER TO automarket;

--
-- Name: cities; Type: TABLE; Schema: public; Owner: automarket
--

CREATE TABLE public.cities (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.cities OWNER TO automarket;

--
-- Name: condition_types; Type: TABLE; Schema: public; Owner: automarket
--

CREATE TABLE public.condition_types (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.condition_types OWNER TO automarket;

--
-- Name: favorites; Type: TABLE; Schema: public; Owner: automarket
--

CREATE TABLE public.favorites (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    listing_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.favorites OWNER TO automarket;

--
-- Name: flyway_history_auth; Type: TABLE; Schema: public; Owner: automarket
--

CREATE TABLE public.flyway_history_auth (
    installed_rank integer NOT NULL,
    version character varying(50),
    description character varying(200) NOT NULL,
    type character varying(20) NOT NULL,
    script character varying(1000) NOT NULL,
    checksum integer,
    installed_by character varying(100) NOT NULL,
    installed_on timestamp without time zone DEFAULT now() NOT NULL,
    execution_time integer NOT NULL,
    success boolean NOT NULL
);


ALTER TABLE public.flyway_history_auth OWNER TO automarket;

--
-- Name: flyway_history_blog; Type: TABLE; Schema: public; Owner: automarket
--

CREATE TABLE public.flyway_history_blog (
    installed_rank integer NOT NULL,
    version character varying(50),
    description character varying(200) NOT NULL,
    type character varying(20) NOT NULL,
    script character varying(1000) NOT NULL,
    checksum integer,
    installed_by character varying(100) NOT NULL,
    installed_on timestamp without time zone DEFAULT now() NOT NULL,
    execution_time integer NOT NULL,
    success boolean NOT NULL
);


ALTER TABLE public.flyway_history_blog OWNER TO automarket;

--
-- Name: flyway_history_inquiry; Type: TABLE; Schema: public; Owner: automarket
--

CREATE TABLE public.flyway_history_inquiry (
    installed_rank integer NOT NULL,
    version character varying(50),
    description character varying(200) NOT NULL,
    type character varying(20) NOT NULL,
    script character varying(1000) NOT NULL,
    checksum integer,
    installed_by character varying(100) NOT NULL,
    installed_on timestamp without time zone DEFAULT now() NOT NULL,
    execution_time integer NOT NULL,
    success boolean NOT NULL
);


ALTER TABLE public.flyway_history_inquiry OWNER TO automarket;

--
-- Name: flyway_history_listing; Type: TABLE; Schema: public; Owner: automarket
--

CREATE TABLE public.flyway_history_listing (
    installed_rank integer NOT NULL,
    version character varying(50),
    description character varying(200) NOT NULL,
    type character varying(20) NOT NULL,
    script character varying(1000) NOT NULL,
    checksum integer,
    installed_by character varying(100) NOT NULL,
    installed_on timestamp without time zone DEFAULT now() NOT NULL,
    execution_time integer NOT NULL,
    success boolean NOT NULL
);


ALTER TABLE public.flyway_history_listing OWNER TO automarket;

--
-- Name: flyway_history_payment; Type: TABLE; Schema: public; Owner: automarket
--

CREATE TABLE public.flyway_history_payment (
    installed_rank integer NOT NULL,
    version character varying(50),
    description character varying(200) NOT NULL,
    type character varying(20) NOT NULL,
    script character varying(1000) NOT NULL,
    checksum integer,
    installed_by character varying(100) NOT NULL,
    installed_on timestamp without time zone DEFAULT now() NOT NULL,
    execution_time integer NOT NULL,
    success boolean NOT NULL
);


ALTER TABLE public.flyway_history_payment OWNER TO automarket;

--
-- Name: flyway_schema_history; Type: TABLE; Schema: public; Owner: automarket
--

CREATE TABLE public.flyway_schema_history (
    installed_rank integer NOT NULL,
    version character varying(50),
    description character varying(200) NOT NULL,
    type character varying(20) NOT NULL,
    script character varying(1000) NOT NULL,
    checksum integer,
    installed_by character varying(100) NOT NULL,
    installed_on timestamp without time zone DEFAULT now() NOT NULL,
    execution_time integer NOT NULL,
    success boolean NOT NULL
);


ALTER TABLE public.flyway_schema_history OWNER TO automarket;

--
-- Name: fuel_types; Type: TABLE; Schema: public; Owner: automarket
--

CREATE TABLE public.fuel_types (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.fuel_types OWNER TO automarket;

--
-- Name: inquiries; Type: TABLE; Schema: public; Owner: automarket
--

CREATE TABLE public.inquiries (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    listing_id uuid NOT NULL,
    sender_id uuid NOT NULL,
    message text NOT NULL,
    read_by_seller boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.inquiries OWNER TO automarket;

--
-- Name: inquiry_listing_view; Type: TABLE; Schema: public; Owner: automarket
--

CREATE TABLE public.inquiry_listing_view (
    id uuid NOT NULL,
    title character varying(100) NOT NULL,
    seller_id uuid NOT NULL,
    approved boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.inquiry_listing_view OWNER TO automarket;

--
-- Name: inquiry_user_view; Type: TABLE; Schema: public; Owner: automarket
--

CREATE TABLE public.inquiry_user_view (
    id uuid NOT NULL,
    email character varying(255) NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.inquiry_user_view OWNER TO automarket;

--
-- Name: listing_analytics; Type: TABLE; Schema: public; Owner: automarket
--

CREATE TABLE public.listing_analytics (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    listing_id uuid NOT NULL,
    date date NOT NULL,
    view_count integer DEFAULT 0 NOT NULL,
    inquiry_count integer DEFAULT 0 NOT NULL,
    favorite_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.listing_analytics OWNER TO automarket;

--
-- Name: listing_images; Type: TABLE; Schema: public; Owner: automarket
--

CREATE TABLE public.listing_images (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    listing_id uuid NOT NULL,
    storage_key character varying(512) NOT NULL,
    url character varying(1024) NOT NULL,
    display_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.listing_images OWNER TO automarket;

--
-- Name: listing_user_view; Type: TABLE; Schema: public; Owner: automarket
--

CREATE TABLE public.listing_user_view (
    id uuid NOT NULL,
    email character varying(255) NOT NULL,
    name character varying(100) NOT NULL,
    phone character varying(30),
    city_name character varying(100),
    plan character varying(20) DEFAULT 'FREE'::character varying NOT NULL,
    created_at timestamp with time zone,
    deleted_at timestamp with time zone
);


ALTER TABLE public.listing_user_view OWNER TO automarket;

--
-- Name: listings; Type: TABLE; Schema: public; Owner: automarket
--

CREATE TABLE public.listings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    title character varying(100) NOT NULL,
    slug character varying(150) NOT NULL,
    description text NOT NULL,
    price numeric(12,2) NOT NULL,
    condition_type_id uuid,
    approved boolean DEFAULT false NOT NULL,
    featured boolean DEFAULT false NOT NULL,
    featured_until timestamp with time zone,
    seller_id uuid NOT NULL,
    car_brand_id uuid,
    car_model character varying(100) NOT NULL,
    registration_year integer NOT NULL,
    kilometers integer NOT NULL,
    fuel_type_id uuid,
    body_type_id uuid,
    transmission_type_id uuid,
    num_doors integer,
    num_seats integer,
    kilowatts integer,
    attributes jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying(255),
    deleted_at timestamp with time zone,
    search_vector tsvector,
    CONSTRAINT listings_kilometers_check CHECK ((kilometers >= 0)),
    CONSTRAINT listings_kilowatts_check CHECK ((kilowatts > 0)),
    CONSTRAINT listings_num_doors_check CHECK (((num_doors >= 1) AND (num_doors <= 10))),
    CONSTRAINT listings_num_seats_check CHECK (((num_seats >= 1) AND (num_seats <= 20))),
    CONSTRAINT listings_price_check CHECK ((price >= (0)::numeric)),
    CONSTRAINT listings_registration_year_check CHECK (((registration_year >= 1886) AND (registration_year <= 2100)))
);


ALTER TABLE public.listings OWNER TO automarket;

--
-- Name: outbox; Type: TABLE; Schema: public; Owner: automarket
--

CREATE TABLE public.outbox (
    id uuid NOT NULL,
    source_service character varying(64) NOT NULL,
    topic character varying(255) NOT NULL,
    event_key character varying(255) NOT NULL,
    event_type character varying(128) NOT NULL,
    payload text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    published_at timestamp with time zone,
    attempts integer DEFAULT 0 NOT NULL,
    last_error character varying(1000)
);


ALTER TABLE public.outbox OWNER TO automarket;

--
-- Name: payment_user_view; Type: TABLE; Schema: public; Owner: automarket
--

CREATE TABLE public.payment_user_view (
    id uuid NOT NULL,
    email character varying(255) NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.payment_user_view OWNER TO automarket;

--
-- Name: processed_event; Type: TABLE; Schema: public; Owner: automarket
--

CREATE TABLE public.processed_event (
    event_id character varying(64) NOT NULL,
    consumer_group character varying(128) NOT NULL,
    event_type character varying(128),
    processed_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.processed_event OWNER TO automarket;

--
-- Name: refresh_tokens; Type: TABLE; Schema: public; Owner: automarket
--

CREATE TABLE public.refresh_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    token character varying(512) NOT NULL,
    user_id uuid NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    revoked boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.refresh_tokens OWNER TO automarket;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: automarket
--

CREATE TABLE public.roles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(30) NOT NULL
);


ALTER TABLE public.roles OWNER TO automarket;

--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: automarket
--

CREATE TABLE public.subscriptions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    plan character varying(20) NOT NULL,
    status character varying(20) DEFAULT 'ACTIVE'::character varying NOT NULL,
    stripe_subscription_id character varying(255),
    stripe_customer_id character varying(255),
    current_period_start timestamp with time zone,
    current_period_end timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying(255)
);


ALTER TABLE public.subscriptions OWNER TO automarket;

--
-- Name: transmission_types; Type: TABLE; Schema: public; Owner: automarket
--

CREATE TABLE public.transmission_types (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.transmission_types OWNER TO automarket;

--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: automarket
--

CREATE TABLE public.user_roles (
    user_id uuid NOT NULL,
    role_id uuid NOT NULL
);


ALTER TABLE public.user_roles OWNER TO automarket;

--
-- Name: users; Type: TABLE; Schema: public; Owner: automarket
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    name character varying(100) NOT NULL,
    phone character varying(30),
    city_id uuid,
    plan character varying(20) DEFAULT 'FREE'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying(255),
    deleted_at timestamp with time zone,
    enabled boolean DEFAULT true NOT NULL
);


ALTER TABLE public.users OWNER TO automarket;

--
-- Data for Name: auth_city_view; Type: TABLE DATA; Schema: public; Owner: automarket
--

COPY public.auth_city_view (id, name) FROM stdin;
2034be85-bde5-44a3-9e81-17d2dfedc4b4	Skopje
e6d535d5-3205-4b59-a5e7-3d80e7e4d1be	Bitola
a58c42f7-5c1f-4b13-a13a-315ff36dc90b	Kumanovo
f2755650-1329-4531-b414-fadf55c26557	Prilep
ac265a4a-2d9d-4ff7-b5aa-d15e41a96901	Tetovo
32139dc4-d6be-40bb-bdcd-714a5603cbf8	Veles
769f0050-b84e-4666-9f91-1bd47d1f0489	Štip
e9849a12-2ad6-480b-bf87-3429d2565beb	Ohrid
30c4c444-11e9-455f-8ad2-63cb5c514096	Gostivar
51105815-266b-4651-a989-f3932d378c59	Strumica
8f92562d-b87f-43f8-beca-ce45ecf73630	Kavadarci
d3f48f67-003d-471f-b93f-a89452865b34	Kočani
66745071-0c3b-4331-9c1d-f50442de0294	Kičevo
95c7e7e9-4593-464f-87a2-6e9e3f11b8aa	Struga
f92bb45c-c347-49fa-aa52-19c0a48f0fc1	Radoviš
09275485-40a1-400a-b561-98a873051e9c	Gevgelija
88ec43d4-9d23-475e-8d79-c74094056038	Debar
de0a9425-23c6-47b1-8ccc-7d5f976caf30	Kriva Palanka
9bbe9a51-9a08-41db-9d22-ebb707e30ff9	Negotino
e6162a41-33ee-49a3-b51c-c96d7fdfe1fd	Vinica
\.


--
-- Data for Name: auth_listing_view; Type: TABLE DATA; Schema: public; Owner: automarket
--

COPY public.auth_listing_view (listing_id, seller_id, approved) FROM stdin;
e34bc7f3-2c05-4501-a0a2-8485e2b2f6ae	3fb5443b-e25b-43e5-a677-0cd7b6c77f62	t
c809a9af-3a5b-49aa-a416-ba7f9666b0fd	8d11d611-807e-408b-ba9b-fc6eb4b84b86	t
3a35b1fd-a6b1-4891-bb7e-da394a9dec6b	3fb5443b-e25b-43e5-a677-0cd7b6c77f62	t
94336ae8-266f-4a34-a56f-c025c093fac9	923a0bc7-5008-4228-aaee-01126af673f0	t
c675e64e-80e2-4c5d-8190-c9d6fda1da2d	85538ad0-0bc5-4539-8e9d-158cec1003b7	t
194361d9-248a-4326-a562-9bc80edf87b0	1231c400-0c5d-445d-8fd4-cfd562e46bf5	t
28619579-63d6-462c-90a2-5f92edba9ef3	0f3f2825-d73c-4d57-8d52-ff5072c3fdf6	t
83c23c7b-9dcd-486d-bf37-61aea2b92f14	75d8dafb-2d53-48e6-97ea-483d7534c0a0	f
1d6b2ebc-c39b-46e5-b3cd-5cfdac2213c7	740483d6-9239-470c-a813-31cfed5182a6	t
2324d1f8-952e-4bcf-9893-a9e0a1ffe515	8d11d611-807e-408b-ba9b-fc6eb4b84b86	t
07b5061a-9441-4c07-9628-aa49767f8451	0f3f2825-d73c-4d57-8d52-ff5072c3fdf6	t
56572e8e-5fb3-440f-ba77-af00c6d3fa1f	d4269afa-baac-4de1-8a0d-f8a186bff526	t
a91ba2b6-ca6d-4010-b0da-818993e3e65b	923a0bc7-5008-4228-aaee-01126af673f0	t
a80c9f1b-5c75-4d7d-878d-94afbf6e0ab0	2fccfa32-7dee-4274-90a6-2294531c0710	t
e48c5831-b619-4000-80a2-6e03aaa98c97	85538ad0-0bc5-4539-8e9d-158cec1003b7	t
8be5f9cd-9806-454d-94a4-8e795d93054c	292e621c-f44a-49e8-a92a-6455ea65629e	t
6e4196b7-5f63-44b5-9f53-de594e2777c6	b1ba0660-e3df-4b8c-b2a9-4414d104189e	t
d6b750c1-3b36-4e6b-9707-3731faab57b3	d81ec3ca-9c3c-4354-9386-3f7d8a91efe4	t
33504139-3147-4fc7-828d-08ef67bbf186	b18ee252-3735-4afb-9f52-804477425db6	t
9f36339c-9535-41b0-8c96-74c747bee0f4	740483d6-9239-470c-a813-31cfed5182a6	t
eaee3c3f-1c28-4401-9e33-cb5900ad7179	c87953f6-a443-4fb7-9c6c-788ccefc95ca	f
3aa34d57-aac7-4d3c-a64b-34f5bfbd4c25	85538ad0-0bc5-4539-8e9d-158cec1003b7	t
97dc8ee5-49ff-440b-89de-91e4fdb97d70	d4269afa-baac-4de1-8a0d-f8a186bff526	t
af89edb0-1427-41f4-abea-036d209f318d	923a0bc7-5008-4228-aaee-01126af673f0	t
452110da-c7c3-4812-88fc-98df81c9100a	b1ba0660-e3df-4b8c-b2a9-4414d104189e	f
15a1a9b0-b89a-4608-aac8-43281faa1158	b487c11a-1041-49b4-a94f-b41fab5bb7bb	f
\.


--
-- Data for Name: blog_author_view; Type: TABLE DATA; Schema: public; Owner: automarket
--

COPY public.blog_author_view (id, email, name) FROM stdin;
923a0bc7-5008-4228-aaee-01126af673f0	marko.petrovski@gmail.com	Marko Petrovski
85538ad0-0bc5-4539-8e9d-158cec1003b7	ana.stojanova@yahoo.com	Ana Stojanova
740483d6-9239-470c-a813-31cfed5182a6	igor.nikolov@hotmail.com	Igor Nikolov
75d8dafb-2d53-48e6-97ea-483d7534c0a0	elena.dimova@gmail.com	Elena Dimova
0f3f2825-d73c-4d57-8d52-ff5072c3fdf6	stefan.trajkov@gmail.com	Stefan Trajkov
d4269afa-baac-4de1-8a0d-f8a186bff526	maja.kostadinova@gmail.com	Maja Kostadinova
292e621c-f44a-49e8-a92a-6455ea65629e	aleksandar.ristov@gmail.com	Aleksandar Ristov
2fccfa32-7dee-4274-90a6-2294531c0710	ivana.georgievska@gmail.com	Ivana Georgievska
b1ba0660-e3df-4b8c-b2a9-4414d104189e	nikola.andonov@gmail.com	Nikola Andonov
b18ee252-3735-4afb-9f52-804477425db6	tamara.mitrevska@gmail.com	Tamara Mitrevska
d81ec3ca-9c3c-4354-9386-3f7d8a91efe4	dejan.milosevski@gmail.com	Dejan Milosevski
c87953f6-a443-4fb7-9c6c-788ccefc95ca	kristina.ilievska@gmail.com	Kristina Ilievska
7204b7eb-a53b-4d49-8e7e-d8bb4f3bea8a	superadmin@automarket.mk	Super Admin
b487c11a-1041-49b4-a94f-b41fab5bb7bb	admin@automarket.mk	Admin User
1231c400-0c5d-445d-8fd4-cfd562e46bf5	moderator@automarket.mk	Moderator User
8d11d611-807e-408b-ba9b-fc6eb4b84b86	user@automarket.mk	Regular User
3fb5443b-e25b-43e5-a677-0cd7b6c77f62	premium@automarket.mk	Premium User
4de9f430-653d-44b4-9993-ab276dddf190	kostoskidaniel13@gmail.com	Daniel Kostoski
53598466-cec5-4763-a545-109c21d7fc9f	kostoskidaniel14@gmail.com	Daniel Kostoski
\.


--
-- Data for Name: blogs; Type: TABLE DATA; Schema: public; Owner: automarket
--

COPY public.blogs (id, title, content, author_id, created_at, updated_at, created_by, slug, excerpt, cover_image_url, cover_image_key, published) FROM stdin;
3fdca476-0ac5-412f-9b19-c480572dbc9e	How to Prepare Your Car for Winter	Winter driving in Macedonia can be challenging, especially in mountainous regions. Here's how to prepare your car:\n\n## Tires\nSwitch to winter tires when temperatures consistently drop below 7°C. They provide significantly better grip on cold, wet, and icy roads.\n\n## Battery\nCold weather reduces battery capacity. Have your battery tested and replace it if it's more than 4 years old.\n\n## Antifreeze\nCheck your coolant mix is adequate for the expected temperatures. A 50/50 mix of antifreeze and water protects down to about -35°C.\n\n## Wipers and Washer Fluid\nInstall winter wiper blades and fill up with winter-grade washer fluid that won't freeze.\n\n## Lights\nWith shorter days, ensure all lights are working properly. Clean headlight lenses for maximum visibility.\n\n## Emergency Kit\nKeep a blanket, torch, ice scraper, jump cables, and a small shovel in your boot.	1231c400-0c5d-445d-8fd4-cfd562e46bf5	2026-04-18 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	moderator@automarket.mk	how-to-prepare-car-for-winter	Essential winter preparation checklist to keep you safe on the road during the cold months in Macedonia.	https://images.unsplash.com/photo-1477346611705-65d1883cee1e?w=1200	seed/blog-winter.jpg	t
324fb9b2-96fb-4e6d-9e32-a695f3801e1a	AutoMarket Guide to Car Insurance in Macedonia	## Coming Soon\n\nThis article will cover:\n- Mandatory third-party liability insurance\n- Comprehensive (kasko) insurance explained\n- How premiums are calculated\n- Tips for reducing your premium\n- Claim process walkthrough\n- Best insurance providers comparison	b487c11a-1041-49b4-a94f-b41fab5bb7bb	2026-05-08 21:26:25.972172+00	2026-05-09 09:26:25.972172+00	admin@automarket.mk	guide-car-insurance-macedonia	Draft: Comprehensive overview of mandatory and optional car insurance types available in Macedonia.	\N	\N	f
0ef55779-b3be-4acc-955e-d9f90f9c3965	Top 10 Tips for Buying a Used Car in 2024	Buying a used car can be a daunting experience, but with the right knowledge, you can find a great deal. Here are our top 10 tips:\n\n## 1. Set Your Budget\nBefore you start looking, know exactly how much you can afford — including insurance, tax, and maintenance costs.\n\n## 2. Research the Model\nLook up common issues, running costs, and reliability ratings for any model you're considering.\n\n## 3. Check the Service History\nA full service history is essential. It shows the car has been properly maintained and can significantly affect resale value.\n\n## 4. Get an Independent Inspection\nNever rely solely on the seller's word. Pay for a professional pre-purchase inspection.\n\n## 5. Test Drive Thoroughly\nDrive on different road types — city, highway, and hills. Listen for unusual noises and check all electronics.\n\n## 6. Verify the Mileage\nCompare the odometer reading with service records and MOT history to spot potential clocking.\n\n## 7. Check for Outstanding Finance\nUse a vehicle check service to ensure there's no outstanding finance, insurance write-offs, or stolen flags.\n\n## 8. Inspect the Bodywork\nLook for mismatched paint, uneven panel gaps, and signs of accident repair.\n\n## 9. Negotiate the Price\nAlways negotiate. Use comparable listings as leverage and don't be afraid to walk away.\n\n## 10. Get Everything in Writing\nEnsure any verbal promises are documented in the sales contract.	b487c11a-1041-49b4-a94f-b41fab5bb7bb	2026-04-04 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	admin@automarket.mk	top-10-tips-buying-used-car-2024	Navigate the used car market with confidence using our expert tips on inspections, negotiations, and avoiding common pitfalls.	https://images.unsplash.com/photo-1449965408869-ebd13bc9e5a8?w=1200	seed/blog-used-car-tips.jpg	t
b8c029d8-fc70-4827-a540-9ea231fa21bf	Electric Cars: Are They Worth It in Macedonia?	Electric vehicles (EVs) are gaining popularity worldwide, but how practical are they in Macedonia?\n\n## Charging Infrastructure\nMacedonia's charging network is still developing. Major cities like Skopje have several fast chargers, but rural coverage remains limited. Home charging is the most convenient option if you have a garage.\n\n## Cost of Ownership\nWhile EVs have a higher purchase price, electricity is significantly cheaper than petrol or diesel. Maintenance costs are also lower — no oil changes, fewer brake replacements thanks to regenerative braking.\n\n## Range Anxiety\nModern EVs offer 300-500 km of range, which covers most daily needs. For long trips within the country, the distances are manageable with a single charge.\n\n## Government Incentives\nCurrently, there are limited incentives for EV purchases in Macedonia. However, the lower running costs can offset the higher initial investment over 3-5 years.\n\n## Our Verdict\nIf you have home charging and primarily drive in the city, an EV makes excellent financial sense. For frequent long-distance drivers, a plug-in hybrid might be a better compromise.	b487c11a-1041-49b4-a94f-b41fab5bb7bb	2026-04-11 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	admin@automarket.mk	electric-cars-worth-it-macedonia	We explore the pros and cons of owning an electric vehicle in Macedonia, from charging infrastructure to total cost of ownership.	https://images.unsplash.com/photo-1593941707882-a5bba14938c7?w=1200	seed/blog-ev.jpg	t
e0983b61-a173-415d-b682-4f591c6a0af0	SUV vs Sedan: Which Is Right for You?	The SUV vs sedan debate is one of the most common dilemmas for car buyers. Let's break it down:\n\n## Space and Practicality\nSUVs offer more cargo space and a higher seating position. Sedans counter with easier parking and lower loading heights.\n\n## Fuel Economy\nSedans typically consume less fuel due to lighter weight and better aerodynamics. The gap is narrowing with modern SUVs, but it's still significant.\n\n## Driving Dynamics\nSedans generally handle better with a lower centre of gravity. SUVs compensate with available AWD systems for rough roads.\n\n## Safety\nBoth types score well in modern crash tests. SUVs offer the psychological benefit of a commanding view, while sedans benefit from lower rollover risk.\n\n## Cost\nSedans are usually cheaper to buy, insure, and maintain. SUVs come at a premium but hold their resale value better.\n\n## Our Recommendation\nChoose a sedan if you prioritize efficiency and driving pleasure. Go for an SUV if you need space, ground clearance, or frequently tackle rough roads.	b487c11a-1041-49b4-a94f-b41fab5bb7bb	2026-04-25 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	admin@automarket.mk	suv-vs-sedan-which-right-for-you	A comprehensive comparison of SUVs and sedans to help you decide which body style suits your lifestyle best.	https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?w=1200	seed/blog-suv-sedan.jpg	t
0bb1a4ba-f476-4922-a61c-466d72f4df37	Best First Cars for New Drivers in Macedonia	Getting your first car is exciting, but choosing the right one matters. Here are our top picks for new drivers in Macedonia:\n\n## 1. Dacia Sandero\nThe most affordable new car on the market. Simple, reliable, and cheap to run. Insurance group 1-3.\n\n## 2. Opel Corsa\nCompact, easy to park, and available with a small turbo engine. Modern safety features come standard.\n\n## 3. Renault Clio\nStylish interior that punches above its weight. Excellent safety rating and low running costs.\n\n## 4. Volkswagen Polo\nBuilt like a small Golf. Premium feel, great resale value, and rock-solid reliability.\n\n## 5. Suzuki Swift\nLightweight, fun to drive, and very fuel efficient. The sport version is a hidden gem.\n\n## What to Look For\n- Small engine (1.0-1.2L) for lower insurance\n- High safety rating (minimum 4 stars Euro NCAP)\n- Good parts availability in Macedonia\n- Manual transmission to learn properly\n- Under 100,000 km if buying used	b487c11a-1041-49b4-a94f-b41fab5bb7bb	2026-05-02 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	admin@automarket.mk	best-first-cars-new-drivers-macedonia	Our picks for the safest, most affordable, and easiest-to-insure first cars available on the Macedonian market.	https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=1200	seed/blog-first-car.jpg	t
60089b11-864f-4e5f-a0b8-b5ee6b1a2e38	The Rise of Hybrid Cars: A Practical Guide	Hybrid cars are everywhere now, but which type is right for you?\n\n## Types of Hybrid\n\n### Mild Hybrid (MHEV)\nA small electric motor assists the petrol/diesel engine. Cannot drive on electric alone. Improves fuel economy by 5-15%. Examples: most new Audis, Suzuki Swift.\n\n### Full Hybrid (HEV)\nCan drive short distances on electric power alone. Self-charging — no plug needed. Great for city driving. Examples: Toyota Yaris, Honda Jazz.\n\n### Plug-in Hybrid (PHEV)\nLarger battery that you charge at home or at a charging station. 40-80 km electric-only range. Best of both worlds if you charge regularly. Examples: BMW 330e, Volvo XC60 Recharge.\n\n## Which Should You Choose?\n- **Short city commute** → Full Hybrid (Toyota)\n- **Mixed driving with home charging** → Plug-in Hybrid\n- **Highway driving** → Mild Hybrid or Diesel\n- **No charging option** → Full Hybrid\n\n## Running Costs\nHybrids typically save 20-40% on fuel compared to equivalent petrol cars. Maintenance is similar, though brake pads last longer due to regenerative braking.	1231c400-0c5d-445d-8fd4-cfd562e46bf5	2026-05-06 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	moderator@automarket.mk	rise-of-hybrid-cars-practical-guide	Everything you need to know about hybrid cars — mild, full, and plug-in — and which type suits your driving style.	https://images.unsplash.com/photo-1611016186353-652a19d4e502?w=1200	seed/blog-hybrid.jpg	t
b1d0b9d1-c224-40f3-9f92-ca5722ba93bc	Understanding Car Finance Options	Not everyone can buy a car outright. Here are the main financing options available:\n\n## Bank Loan\nA traditional personal loan from your bank. You own the car from day one and can sell it whenever you want. Interest rates vary based on your credit history.\n\n## Dealer Finance\nConvenient but often more expensive. Always compare the dealer's APR with your bank before signing.\n\n## Leasing\nYou pay monthly to use the car for a fixed period (usually 2-4 years). Lower monthly payments but you don't own the car and face mileage restrictions.\n\n## Tips for Getting the Best Deal\n- Shop around for the best interest rate\n- Make the largest deposit you can afford\n- Keep the term as short as possible to minimize total interest\n- Read the fine print carefully\n- Factor in insurance and maintenance costs	b487c11a-1041-49b4-a94f-b41fab5bb7bb	2026-05-08 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	admin@automarket.mk	understanding-car-finance-options	A guide to the different ways you can finance your next car purchase, from bank loans to leasing.	https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=1200	seed/blog-finance.jpg	f
\.


--
-- Data for Name: body_types; Type: TABLE DATA; Schema: public; Owner: automarket
--

COPY public.body_types (id, name) FROM stdin;
5bba7a9c-deaa-43c0-8764-21cf79df49ea	Sedan
f0c38b3b-be37-4d6e-98bb-13cdcc67e27c	Hatchback
d31ffe0a-0b23-4b68-aecc-4cd6f2cc93b4	SUV
8fd1493d-ba36-4e78-ae14-d8fefc440971	Coupe
ceb6d871-70bb-4efe-80cb-b001ee34e69b	Estate / Wagon
7ff49846-674f-46c2-b5a0-a0ec99fc0964	Convertible
4179daed-7f57-4253-a30e-6a4ff853bc28	Van
b9d08bd8-7b72-41f4-ae11-9432d181c57a	Pickup
a3e78081-2a6a-42ca-8f98-70703bda56dd	Minivan
9c902fa1-b678-438a-be27-bfde0ce28945	Roadster
\.


--
-- Data for Name: car_brands; Type: TABLE DATA; Schema: public; Owner: automarket
--

COPY public.car_brands (id, name) FROM stdin;
7e093505-fcdc-4ff2-9d18-c7f507f0768f	Audi
f9d1f607-79e0-43ab-b7e7-572de70378ce	BMW
a106b6a1-b645-4408-a85e-71e19bc34c3c	Mercedes-Benz
0ea35b4e-0c92-4451-8cd5-a13267005c2c	Volkswagen
e1f40c06-d33a-47f0-b772-869fcca3a800	Toyota
7f178758-c66a-4143-926a-bcebd5d50731	Honda
78ca100d-0f50-44e0-8e69-f630ff57725a	Ford
a7a69696-c77a-4110-8b29-4850b12b8b09	Opel
bea4e9fb-6dc2-4ff9-a7a0-0e6a66cb163f	Peugeot
5da38a3d-9370-4dff-a2f4-e521b360d878	Renault
2574c3e4-c3f4-4404-a909-dea12fb44e73	Skoda
02719acd-69f9-4837-aaca-ddbefee8cea4	Seat
d327be90-7163-4cec-a458-120f09effe20	Fiat
13852180-f597-4c3c-97a3-126842197b74	Hyundai
2e75408a-3e83-499e-ba15-e968790db482	Kia
85835ed2-3306-410f-a5c1-31ad140287ae	Nissan
4389c283-1841-4387-80af-3b0278484052	Mazda
3d357720-f5ac-4d7c-96a2-8652662077c3	Volvo
a7619f40-df18-4390-96f8-0b797147a31e	Porsche
61567359-0d60-4cdf-9641-e98c57139140	Land Rover
df6008b3-b9f3-45a5-8d38-85776380afab	Jeep
ca32b11b-bb5b-4ee9-83a9-719fb0e2dcb6	Mitsubishi
e6fe7931-ee59-4bd5-b39a-25106c5f1476	Suzuki
d0905a94-e7bf-4f2c-a689-1608dbd48725	Subaru
919a99a2-d6b6-43e2-8a29-44937fe1ffa4	Lexus
eda7aa3c-32cf-43c5-830a-ebe7093ec6a8	Alfa Romeo
1276b9e9-7dd5-4974-802f-fc7ffa3cd9a3	Citroën
4a5f3e54-23b7-436a-8d07-26589437fa3f	Dacia
1d4db490-81b3-4ac6-9061-1eb33ebe4817	Mini
4555b586-1cf6-42e2-b2a3-e74ce5f381f3	Tesla
\.


--
-- Data for Name: cities; Type: TABLE DATA; Schema: public; Owner: automarket
--

COPY public.cities (id, name) FROM stdin;
2034be85-bde5-44a3-9e81-17d2dfedc4b4	Skopje
e6d535d5-3205-4b59-a5e7-3d80e7e4d1be	Bitola
a58c42f7-5c1f-4b13-a13a-315ff36dc90b	Kumanovo
f2755650-1329-4531-b414-fadf55c26557	Prilep
ac265a4a-2d9d-4ff7-b5aa-d15e41a96901	Tetovo
32139dc4-d6be-40bb-bdcd-714a5603cbf8	Veles
769f0050-b84e-4666-9f91-1bd47d1f0489	Štip
e9849a12-2ad6-480b-bf87-3429d2565beb	Ohrid
30c4c444-11e9-455f-8ad2-63cb5c514096	Gostivar
51105815-266b-4651-a989-f3932d378c59	Strumica
8f92562d-b87f-43f8-beca-ce45ecf73630	Kavadarci
d3f48f67-003d-471f-b93f-a89452865b34	Kočani
66745071-0c3b-4331-9c1d-f50442de0294	Kičevo
95c7e7e9-4593-464f-87a2-6e9e3f11b8aa	Struga
f92bb45c-c347-49fa-aa52-19c0a48f0fc1	Radoviš
09275485-40a1-400a-b561-98a873051e9c	Gevgelija
88ec43d4-9d23-475e-8d79-c74094056038	Debar
de0a9425-23c6-47b1-8ccc-7d5f976caf30	Kriva Palanka
9bbe9a51-9a08-41db-9d22-ebb707e30ff9	Negotino
e6162a41-33ee-49a3-b51c-c96d7fdfe1fd	Vinica
\.


--
-- Data for Name: condition_types; Type: TABLE DATA; Schema: public; Owner: automarket
--

COPY public.condition_types (id, name) FROM stdin;
dfff3d12-d89c-41c7-b13e-250236f0ca6e	New
4c5a38fd-b5a4-4c24-885a-f9e1c9b3dc7a	Used
a6b7528e-344e-4c38-8c73-b7e5efb6ca4a	Certified Pre-Owned
e19c344d-4b20-4432-bb25-714a16f67214	Salvage
\.


--
-- Data for Name: favorites; Type: TABLE DATA; Schema: public; Owner: automarket
--

COPY public.favorites (id, user_id, listing_id, created_at) FROM stdin;
449e25dd-9102-482c-8ad2-020db09e57e1	8d11d611-807e-408b-ba9b-fc6eb4b84b86	e34bc7f3-2c05-4501-a0a2-8485e2b2f6ae	2026-04-29 09:26:25.972172+00
7c61949f-9a08-454a-bde3-d562222ee9ea	8d11d611-807e-408b-ba9b-fc6eb4b84b86	28619579-63d6-462c-90a2-5f92edba9ef3	2026-04-30 09:26:25.972172+00
1b6df004-8409-4197-b331-59afda4b0750	8d11d611-807e-408b-ba9b-fc6eb4b84b86	3a35b1fd-a6b1-4891-bb7e-da394a9dec6b	2026-05-01 09:26:25.972172+00
b48e9728-5088-45ee-b98f-9a1bdedd43f3	8d11d611-807e-408b-ba9b-fc6eb4b84b86	07b5061a-9441-4c07-9628-aa49767f8451	2026-05-04 09:26:25.972172+00
d1d21177-224a-4ff1-af50-fee64a535fdc	3fb5443b-e25b-43e5-a677-0cd7b6c77f62	c809a9af-3a5b-49aa-a416-ba7f9666b0fd	2026-05-02 09:26:25.972172+00
87f2697b-1c79-4749-ab9a-7ae21b598fbc	3fb5443b-e25b-43e5-a677-0cd7b6c77f62	94336ae8-266f-4a34-a56f-c025c093fac9	2026-05-03 09:26:25.972172+00
b766207c-8702-414a-bff6-715f11e85ba0	3fb5443b-e25b-43e5-a677-0cd7b6c77f62	3aa34d57-aac7-4d3c-a64b-34f5bfbd4c25	2026-05-06 09:26:25.972172+00
6aea38a4-b469-4649-a019-bef6e03850a7	1231c400-0c5d-445d-8fd4-cfd562e46bf5	28619579-63d6-462c-90a2-5f92edba9ef3	2026-05-03 09:26:25.972172+00
84b51bad-e695-413e-9a1c-634d55643087	1231c400-0c5d-445d-8fd4-cfd562e46bf5	07b5061a-9441-4c07-9628-aa49767f8451	2026-05-05 09:26:25.972172+00
8d6c705d-a849-4662-838a-185cf3d592e8	b487c11a-1041-49b4-a94f-b41fab5bb7bb	1d6b2ebc-c39b-46e5-b3cd-5cfdac2213c7	2026-05-04 09:26:25.972172+00
346f6f4f-45f1-4cc7-bc82-905c9a739cb1	b487c11a-1041-49b4-a94f-b41fab5bb7bb	e48c5831-b619-4000-80a2-6e03aaa98c97	2026-05-07 09:26:25.972172+00
fb5bd1cc-60bd-4afe-b4b2-9522c08cf977	923a0bc7-5008-4228-aaee-01126af673f0	e34bc7f3-2c05-4501-a0a2-8485e2b2f6ae	2026-05-05 09:26:25.972172+00
5018b73a-45e2-4e6b-a8f4-0d9f9afe5f0e	923a0bc7-5008-4228-aaee-01126af673f0	07b5061a-9441-4c07-9628-aa49767f8451	2026-05-06 09:26:25.972172+00
0d51d1e4-1d65-4f50-8533-19ebe188878b	923a0bc7-5008-4228-aaee-01126af673f0	af89edb0-1427-41f4-abea-036d209f318d	2026-05-08 09:26:25.972172+00
cf512617-3559-4740-9ba3-e65851745530	75d8dafb-2d53-48e6-97ea-483d7534c0a0	56572e8e-5fb3-440f-ba77-af00c6d3fa1f	2026-05-03 09:26:25.972172+00
44fd7fd6-db0e-4ab3-971d-bf81cc1491f2	75d8dafb-2d53-48e6-97ea-483d7534c0a0	97dc8ee5-49ff-440b-89de-91e4fdb97d70	2026-05-04 09:26:25.972172+00
87cebd8a-47b2-43a4-a45b-583dabc048c0	75d8dafb-2d53-48e6-97ea-483d7534c0a0	a80c9f1b-5c75-4d7d-878d-94afbf6e0ab0	2026-05-07 09:26:25.972172+00
74cb849c-d3dc-4ea4-8433-be0a599a0e0b	85538ad0-0bc5-4539-8e9d-158cec1003b7	28619579-63d6-462c-90a2-5f92edba9ef3	2026-05-06 09:26:25.972172+00
a9b42166-b0c9-4256-8784-4efffd00acb2	85538ad0-0bc5-4539-8e9d-158cec1003b7	3a35b1fd-a6b1-4891-bb7e-da394a9dec6b	2026-05-07 09:26:25.972172+00
c83ce414-2430-41c6-ad14-a248dadd8f9f	740483d6-9239-470c-a813-31cfed5182a6	af89edb0-1427-41f4-abea-036d209f318d	2026-05-07 09:26:25.972172+00
4f107782-6776-40c3-881c-4c41b7ff32d8	740483d6-9239-470c-a813-31cfed5182a6	9f36339c-9535-41b0-8c96-74c747bee0f4	2026-05-08 09:26:25.972172+00
48516e4e-e7e3-44b6-ba8f-3eff4027e66e	b18ee252-3735-4afb-9f52-804477425db6	a80c9f1b-5c75-4d7d-878d-94afbf6e0ab0	2026-05-08 09:26:25.972172+00
84865b9d-6e0a-4803-a3d3-c534230d154d	b18ee252-3735-4afb-9f52-804477425db6	97dc8ee5-49ff-440b-89de-91e4fdb97d70	2026-05-09 01:26:25.972172+00
36a5c2a7-b802-4cd6-846b-195c903a7151	d81ec3ca-9c3c-4354-9386-3f7d8a91efe4	e34bc7f3-2c05-4501-a0a2-8485e2b2f6ae	2026-05-08 15:26:25.972172+00
ab21f8b2-5e12-4554-9905-d64a95b89cc2	c87953f6-a443-4fb7-9c6c-788ccefc95ca	c675e64e-80e2-4c5d-8190-c9d6fda1da2d	2026-05-09 03:26:25.972172+00
\.


--
-- Data for Name: flyway_history_auth; Type: TABLE DATA; Schema: public; Owner: automarket
--

COPY public.flyway_history_auth (installed_rank, version, description, type, script, checksum, installed_by, installed_on, execution_time, success) FROM stdin;
1	0	<< Flyway Baseline >>	BASELINE	<< Flyway Baseline >>	\N	automarket	2026-09-21 16:58:45.561077	0	t
2	1	baseline	SQL	V1__baseline.sql	-28752284	automarket	2026-09-21 16:58:45.709005	101	t
3	2	outbox and inbox	SQL	V2__outbox_and_inbox.sql	-1785141059	automarket	2026-09-21 16:58:45.903039	27	t
4	3	city projection	SQL	V3__city_projection.sql	1240465646	automarket	2026-09-21 16:58:45.978707	42	t
5	4	listing projection	SQL	V4__listing_projection.sql	-1583047238	automarket	2026-09-21 16:58:46.088305	42	t
\.


--
-- Data for Name: flyway_history_blog; Type: TABLE DATA; Schema: public; Owner: automarket
--

COPY public.flyway_history_blog (installed_rank, version, description, type, script, checksum, installed_by, installed_on, execution_time, success) FROM stdin;
1	0	<< Flyway Baseline >>	BASELINE	<< Flyway Baseline >>	\N	automarket	2026-09-21 16:58:20.236563	0	t
2	1	baseline	SQL	V1__baseline.sql	-1161002005	automarket	2026-09-21 16:58:20.657049	101	t
3	2	author projection	SQL	V2__author_projection.sql	-72305294	automarket	2026-09-21 16:58:20.888508	60	t
\.


--
-- Data for Name: flyway_history_inquiry; Type: TABLE DATA; Schema: public; Owner: automarket
--

COPY public.flyway_history_inquiry (installed_rank, version, description, type, script, checksum, installed_by, installed_on, execution_time, success) FROM stdin;
1	0	<< Flyway Baseline >>	BASELINE	<< Flyway Baseline >>	\N	automarket	2026-09-21 16:58:34.884694	0	t
2	1	baseline	SQL	V1__baseline.sql	567680930	automarket	2026-09-21 16:58:35.409783	88	t
3	2	outbox and inbox	SQL	V2__outbox_and_inbox.sql	-1785141059	automarket	2026-09-21 16:58:35.613997	111	t
4	3	user projection	SQL	V3__user_projection.sql	-1587922851	automarket	2026-09-21 16:58:35.860991	80	t
5	4	listing projection	SQL	V4__listing_projection.sql	813715027	automarket	2026-09-21 16:58:36.015121	117	t
\.


--
-- Data for Name: flyway_history_listing; Type: TABLE DATA; Schema: public; Owner: automarket
--

COPY public.flyway_history_listing (installed_rank, version, description, type, script, checksum, installed_by, installed_on, execution_time, success) FROM stdin;
1	0	<< Flyway Baseline >>	BASELINE	<< Flyway Baseline >>	\N	automarket	2026-09-17 23:21:31.474621	0	t
2	1	baseline	SQL	V1__baseline.sql	394733057	automarket	2026-09-17 23:21:31.620799	36	t
3	2	seed reference data	SQL	V2__seed_reference_data.sql	-1649112715	automarket	2026-09-17 23:21:31.69412	28	t
4	3	outbox and inbox	SQL	V3__outbox_and_inbox.sql	-1785141059	automarket	2026-09-17 23:21:31.756983	40	t
5	4	user projection	SQL	V4__user_projection.sql	-678256565	automarket	2026-09-17 23:21:31.819932	30	t
\.


--
-- Data for Name: flyway_history_payment; Type: TABLE DATA; Schema: public; Owner: automarket
--

COPY public.flyway_history_payment (installed_rank, version, description, type, script, checksum, installed_by, installed_on, execution_time, success) FROM stdin;
1	0	<< Flyway Baseline >>	BASELINE	<< Flyway Baseline >>	\N	automarket	2026-09-21 16:58:34.476473	0	t
2	1	baseline	SQL	V1__baseline.sql	724773924	automarket	2026-09-21 16:58:34.914824	43	t
3	2	outbox and inbox	SQL	V2__outbox_and_inbox.sql	-1785141059	automarket	2026-09-21 16:58:35.294458	77	t
4	3	user projection	SQL	V3__user_projection.sql	-598795962	automarket	2026-09-21 16:58:35.557481	57	t
\.


--
-- Data for Name: flyway_schema_history; Type: TABLE DATA; Schema: public; Owner: automarket
--

COPY public.flyway_schema_history (installed_rank, version, description, type, script, checksum, installed_by, installed_on, execution_time, success) FROM stdin;
1	1	core schema	SQL	V1__core_schema.sql	-493457023	automarket	2026-05-09 09:26:24.77388	220	t
2	2	reference data	SQL	V2__reference_data.sql	2117831942	automarket	2026-05-09 09:26:25.07398	118	t
3	3	listings schema	SQL	V3__listings_schema.sql	340884419	automarket	2026-05-09 09:26:25.236971	122	t
4	4	blog schema	SQL	V4__blog_schema.sql	-1933308435	automarket	2026-05-09 09:26:25.403437	18	t
5	5	business features	SQL	V5__business_features.sql	839791265	automarket	2026-05-09 09:26:25.437435	101	t
6	6	search fulltext	SQL	V6__search_fulltext.sql	1510533095	automarket	2026-05-09 09:26:25.557722	9	t
7	7	seed reference data	SQL	V7__seed_reference_data.sql	954786532	automarket	2026-05-09 09:26:25.578561	8	t
8	8	convert smallint columns to integer	SQL	V8__convert_smallint_columns_to_integer.sql	76025452	automarket	2026-05-09 09:26:25.597171	227	t
9	9	blog add slug excerpt cover published	SQL	V9__blog_add_slug_excerpt_cover_published.sql	672527127	automarket	2026-05-09 09:26:25.84265	23	t
10	10	add superadmin role and enabled field	SQL	V10__add_superadmin_role_and_enabled_field.sql	-478856740	automarket	2026-05-09 09:26:25.87726	7	t
11	11	seed test users	SQL	V11__seed_test_users.sql	1943035777	automarket	2026-05-09 09:26:25.894166	14	t
12	12	seed test data	SQL	V12__seed_test_data.sql	1164943627	automarket	2026-05-09 09:26:25.920518	227	t
\.


--
-- Data for Name: fuel_types; Type: TABLE DATA; Schema: public; Owner: automarket
--

COPY public.fuel_types (id, name) FROM stdin;
fa54edc7-e3ea-40fc-853e-7b176eef8801	Petrol
adf641a5-9326-431b-9a3f-6189f29da1b3	Diesel
2278fa3f-7b85-4ccf-83fa-432be624f4b3	Electric
28d4ba18-300c-4532-92d6-63d74469b43a	Hybrid
d0b29c0a-47bc-4b9a-bb99-16402b93f416	Plug-in Hybrid
d9f96c4f-799d-4819-a3e5-7fde5e92f34d	LPG
cf3f7d32-6deb-4a9e-9b5d-3a73477683ac	CNG
0ec5bb01-a0ab-4e39-9c5f-7eb821e4953f	Hydrogen
\.


--
-- Data for Name: inquiries; Type: TABLE DATA; Schema: public; Owner: automarket
--

COPY public.inquiries (id, listing_id, sender_id, message, read_by_seller, created_at) FROM stdin;
d1b0af6e-951b-46ef-9c4b-48817b23237d	e34bc7f3-2c05-4501-a0a2-8485e2b2f6ae	8d11d611-807e-408b-ba9b-fc6eb4b84b86	Hi, is this BMW still available? I am very interested. Can we arrange a test drive this weekend?	f	2026-05-04 09:26:25.972172+00
bd4eb8b4-1c92-4f88-adea-24d18e6f1061	e34bc7f3-2c05-4501-a0a2-8485e2b2f6ae	923a0bc7-5008-4228-aaee-01126af673f0	Hello! What is the lowest you would go on the BMW? I can pay cash today. Also, any scratches on the body?	t	2026-05-06 09:26:25.972172+00
df08dcfb-4e21-4395-a007-770016687e7c	e34bc7f3-2c05-4501-a0a2-8485e2b2f6ae	d81ec3ca-9c3c-4354-9386-3f7d8a91efe4	Does the M Sport package include the adaptive suspension? And is the timing chain or belt?	f	2026-05-08 09:26:25.972172+00
0ae616b5-48d4-4d16-8aee-815e2107d988	3a35b1fd-a6b1-4891-bb7e-da394a9dec6b	8d11d611-807e-408b-ba9b-fc6eb4b84b86	Hello, what is the lowest price you would accept for the C-Class? Also, has it ever been in an accident?	t	2026-05-01 09:26:25.972172+00
3f75f1ff-2767-457d-a239-0dfd7248b8b5	3a35b1fd-a6b1-4891-bb7e-da394a9dec6b	85538ad0-0bc5-4539-8e9d-158cec1003b7	Beautiful car! Is the panoramic roof the full-length one or partial? Can I see it in Bitola?	t	2026-05-05 09:26:25.972172+00
04e7fec7-c687-4099-8b85-db0b7d35f98c	28619579-63d6-462c-90a2-5f92edba9ef3	1231c400-0c5d-445d-8fd4-cfd562e46bf5	Interested in the Model 3. How is the battery health? Do you have the degradation report from Tesla?	f	2026-05-05 09:26:25.972172+00
69b116cd-e05f-4aec-a5d4-a3b13e3c5ef9	28619579-63d6-462c-90a2-5f92edba9ef3	75d8dafb-2d53-48e6-97ea-483d7534c0a0	Is the Full Self-Driving package included or just basic Autopilot? What about supercharger transfers?	f	2026-05-07 09:26:25.972172+00
646cec02-9799-4f06-bda0-f37eb0700c59	07b5061a-9441-4c07-9628-aa49767f8451	923a0bc7-5008-4228-aaee-01126af673f0	Wow, what a spec! Is the price negotiable? I am a serious buyer from Skopje. Can come see it today.	t	2026-05-07 09:26:25.972172+00
1a624e93-0c0e-4e76-a343-b466935d3fe2	c809a9af-3a5b-49aa-a416-ba7f9666b0fd	3fb5443b-e25b-43e5-a677-0cd7b6c77f62	Nice Golf! Would you consider a part exchange with my Audi A3? Similar value. Let me know.	t	2026-04-29 09:26:25.972172+00
9e8374cf-3e63-4535-942c-3a4c94acc844	2324d1f8-952e-4bcf-9893-a9e0a1ffe515	b487c11a-1041-49b4-a94f-b41fab5bb7bb	Is this Sandero actually brand new? The price seems too good. Can you provide the invoice?	f	2026-05-03 09:26:25.972172+00
feca2151-b715-46d7-98a7-6dee857c8fc1	a80c9f1b-5c75-4d7d-878d-94afbf6e0ab0	b18ee252-3735-4afb-9f52-804477425db6	So cute! How long does it take to charge from 0-100%? Is the range really 320 km in real life?	f	2026-05-06 09:26:25.972172+00
2b25df5e-867d-49cb-b796-d14bffe52205	e48c5831-b619-4000-80a2-6e03aaa98c97	740483d6-9239-470c-a813-31cfed5182a6	My wife loves this car. Is the B5 the diesel or petrol version? Can we arrange a viewing in Bitola?	t	2026-05-02 09:26:25.972172+00
788bf000-59c6-4dcf-b957-81b20d4d447d	af89edb0-1427-41f4-abea-036d209f318d	d4269afa-baac-4de1-8a0d-f8a186bff526	Does the 7-seat version sacrifice boot space? I need to fit a double pram. Also, any electrical issues?	f	2026-05-04 09:26:25.972172+00
6c6ffe7d-b01e-447d-ae97-1905f4d5baa8	97dc8ee5-49ff-440b-89de-91e4fdb97d70	c87953f6-a443-4fb7-9c6c-788ccefc95ca	Love the JCW trim! Is the sport exhaust the factory one or aftermarket? Real reason for selling?	t	2026-05-05 09:26:25.972172+00
b256f67f-c345-4e85-b65e-b92eba57c086	d6b750c1-3b36-4e6b-9707-3731faab57b3	4de9f430-653d-44b4-9993-ab276dddf190	is it available?	f	2026-09-21 18:45:43.699816+00
76f00dcb-bbca-46f0-8e99-4abe145ec0ca	e48c5831-b619-4000-80a2-6e03aaa98c97	4de9f430-653d-44b4-9993-ab276dddf190	AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA	f	2026-09-21 19:12:34.618256+00
11b91bcb-6876-4ac5-9c22-17b99a0b34ae	c675e64e-80e2-4c5d-8190-c9d6fda1da2d	4de9f430-653d-44b4-9993-ab276dddf190	TEEEEEEEEEEEEEEEEEEEEEST	f	2026-09-21 19:12:45.264698+00
ff8e9e6f-c5fa-4e73-bf25-994d63c58e22	d6b750c1-3b36-4e6b-9707-3731faab57b3	53598466-cec5-4763-a545-109c21d7fc9f	Test poraka 2	f	2026-09-22 16:59:29.606673+00
\.


--
-- Data for Name: inquiry_listing_view; Type: TABLE DATA; Schema: public; Owner: automarket
--

COPY public.inquiry_listing_view (id, title, seller_id, approved, deleted_at) FROM stdin;
e34bc7f3-2c05-4501-a0a2-8485e2b2f6ae	BMW 320d M Sport 2021	3fb5443b-e25b-43e5-a677-0cd7b6c77f62	t	\N
c809a9af-3a5b-49aa-a416-ba7f9666b0fd	Volkswagen Golf 8 1.5 TSI	8d11d611-807e-408b-ba9b-fc6eb4b84b86	t	\N
3a35b1fd-a6b1-4891-bb7e-da394a9dec6b	Mercedes-Benz C220d AMG Line	3fb5443b-e25b-43e5-a677-0cd7b6c77f62	t	\N
94336ae8-266f-4a34-a56f-c025c093fac9	Toyota RAV4 2.5 Hybrid AWD	923a0bc7-5008-4228-aaee-01126af673f0	t	\N
c675e64e-80e2-4c5d-8190-c9d6fda1da2d	Audi A3 Sportback 35 TFSI S-Line	85538ad0-0bc5-4539-8e9d-158cec1003b7	t	\N
194361d9-248a-4326-a562-9bc80edf87b0	Skoda Octavia Combi 2.0 TDI	1231c400-0c5d-445d-8fd4-cfd562e46bf5	t	\N
28619579-63d6-462c-90a2-5f92edba9ef3	Tesla Model 3 Long Range 2023	0f3f2825-d73c-4d57-8d52-ff5072c3fdf6	t	\N
83c23c7b-9dcd-486d-bf37-61aea2b92f14	Opel Corsa 1.2 Turbo 2023	75d8dafb-2d53-48e6-97ea-483d7534c0a0	f	\N
1d6b2ebc-c39b-46e5-b3cd-5cfdac2213c7	Ford Ranger Wildtrak 2.0 EcoBlue	740483d6-9239-470c-a813-31cfed5182a6	t	\N
2324d1f8-952e-4bcf-9893-a9e0a1ffe515	Dacia Sandero Stepway TCe 90	8d11d611-807e-408b-ba9b-fc6eb4b84b86	t	\N
07b5061a-9441-4c07-9628-aa49767f8451	Porsche Cayenne S 2.9 V6 Biturbo	0f3f2825-d73c-4d57-8d52-ff5072c3fdf6	t	\N
56572e8e-5fb3-440f-ba77-af00c6d3fa1f	Renault Clio 1.0 TCe Intens	d4269afa-baac-4de1-8a0d-f8a186bff526	t	\N
a91ba2b6-ca6d-4010-b0da-818993e3e65b	Hyundai Tucson 1.6 T-GDI Hybrid	923a0bc7-5008-4228-aaee-01126af673f0	t	\N
a80c9f1b-5c75-4d7d-878d-94afbf6e0ab0	Fiat 500e La Prima 42 kWh	2fccfa32-7dee-4274-90a6-2294531c0710	t	\N
e48c5831-b619-4000-80a2-6e03aaa98c97	Volvo XC60 B5 Inscription AWD	85538ad0-0bc5-4539-8e9d-158cec1003b7	t	\N
8be5f9cd-9806-454d-94a4-8e795d93054c	Peugeot 3008 1.5 BlueHDi GT	292e621c-f44a-49e8-a92a-6455ea65629e	t	\N
6e4196b7-5f63-44b5-9f53-de594e2777c6	Kia Sportage 1.6 T-GDI GT-Line	b1ba0660-e3df-4b8c-b2a9-4414d104189e	t	\N
d6b750c1-3b36-4e6b-9707-3731faab57b3	Seat Leon FR 1.5 eTSI 150	d81ec3ca-9c3c-4354-9386-3f7d8a91efe4	t	\N
33504139-3147-4fc7-828d-08ef67bbf186	Nissan Qashqai 1.3 DIG-T Tekna+	b18ee252-3735-4afb-9f52-804477425db6	t	\N
9f36339c-9535-41b0-8c96-74c747bee0f4	Mazda CX-5 2.2 Skyactiv-D AWD	740483d6-9239-470c-a813-31cfed5182a6	t	\N
eaee3c3f-1c28-4401-9e33-cb5900ad7179	Honda Civic 2.0 e:HEV Advance	c87953f6-a443-4fb7-9c6c-788ccefc95ca	f	\N
3aa34d57-aac7-4d3c-a64b-34f5bfbd4c25	Alfa Romeo Giulia 2.2 JTDm Veloce	85538ad0-0bc5-4539-8e9d-158cec1003b7	t	\N
97dc8ee5-49ff-440b-89de-91e4fdb97d70	Mini Cooper S 2.0 John Cooper Works Trim	d4269afa-baac-4de1-8a0d-f8a186bff526	t	\N
af89edb0-1427-41f4-abea-036d209f318d	Land Rover Discovery Sport 2.0 D200 R-Dynamic	923a0bc7-5008-4228-aaee-01126af673f0	t	\N
452110da-c7c3-4812-88fc-98df81c9100a	Suzuki Jimny 1.5 AllGrip Pro	b1ba0660-e3df-4b8c-b2a9-4414d104189e	f	\N
7a3bc970-06a6-426f-83cd-b7018bdffc87	BMW 525i E60 2006 - SOLD	292e621c-f44a-49e8-a92a-6455ea65629e	t	\N
15a1a9b0-b89a-4608-aac8-43281faa1158	Testaaaaaaaaaaaaa	b487c11a-1041-49b4-a94f-b41fab5bb7bb	f	\N
\.


--
-- Data for Name: inquiry_user_view; Type: TABLE DATA; Schema: public; Owner: automarket
--

COPY public.inquiry_user_view (id, email, name) FROM stdin;
923a0bc7-5008-4228-aaee-01126af673f0	marko.petrovski@gmail.com	Marko Petrovski
85538ad0-0bc5-4539-8e9d-158cec1003b7	ana.stojanova@yahoo.com	Ana Stojanova
740483d6-9239-470c-a813-31cfed5182a6	igor.nikolov@hotmail.com	Igor Nikolov
75d8dafb-2d53-48e6-97ea-483d7534c0a0	elena.dimova@gmail.com	Elena Dimova
0f3f2825-d73c-4d57-8d52-ff5072c3fdf6	stefan.trajkov@gmail.com	Stefan Trajkov
d4269afa-baac-4de1-8a0d-f8a186bff526	maja.kostadinova@gmail.com	Maja Kostadinova
292e621c-f44a-49e8-a92a-6455ea65629e	aleksandar.ristov@gmail.com	Aleksandar Ristov
2fccfa32-7dee-4274-90a6-2294531c0710	ivana.georgievska@gmail.com	Ivana Georgievska
b1ba0660-e3df-4b8c-b2a9-4414d104189e	nikola.andonov@gmail.com	Nikola Andonov
b18ee252-3735-4afb-9f52-804477425db6	tamara.mitrevska@gmail.com	Tamara Mitrevska
d81ec3ca-9c3c-4354-9386-3f7d8a91efe4	dejan.milosevski@gmail.com	Dejan Milosevski
c87953f6-a443-4fb7-9c6c-788ccefc95ca	kristina.ilievska@gmail.com	Kristina Ilievska
7204b7eb-a53b-4d49-8e7e-d8bb4f3bea8a	superadmin@automarket.mk	Super Admin
b487c11a-1041-49b4-a94f-b41fab5bb7bb	admin@automarket.mk	Admin User
1231c400-0c5d-445d-8fd4-cfd562e46bf5	moderator@automarket.mk	Moderator User
8d11d611-807e-408b-ba9b-fc6eb4b84b86	user@automarket.mk	Regular User
3fb5443b-e25b-43e5-a677-0cd7b6c77f62	premium@automarket.mk	Premium User
4de9f430-653d-44b4-9993-ab276dddf190	kostoskidaniel13@gmail.com	Daniel Kostoski
53598466-cec5-4763-a545-109c21d7fc9f	kostoskidaniel14@gmail.com	Daniel Kostoski
\.


--
-- Data for Name: listing_analytics; Type: TABLE DATA; Schema: public; Owner: automarket
--

COPY public.listing_analytics (id, listing_id, date, view_count, inquiry_count, favorite_count) FROM stdin;
8494ff6e-9249-45ed-9239-36517ea1bb3d	194361d9-248a-4326-a562-9bc80edf87b0	2026-05-09	37	2	1
e72308ad-aa8d-40f6-9422-ff150ee7bece	194361d9-248a-4326-a562-9bc80edf87b0	2026-05-08	49	0	1
69f72b5a-cfde-4157-bbda-a817294976f4	194361d9-248a-4326-a562-9bc80edf87b0	2026-05-07	47	1	0
39ac7d24-ea6b-46fd-954b-58215fb9c750	194361d9-248a-4326-a562-9bc80edf87b0	2026-05-06	31	2	1
7ba841a6-2810-4751-b0b6-b6b9256516c5	194361d9-248a-4326-a562-9bc80edf87b0	2026-05-05	42	0	1
04a982ea-ee2f-4620-85af-510efdb689df	194361d9-248a-4326-a562-9bc80edf87b0	2026-05-04	32	2	2
5239a15d-601e-444a-8b0d-2c3e527fb91e	194361d9-248a-4326-a562-9bc80edf87b0	2026-05-03	35	2	1
5a03b2e2-caad-48e9-9e6c-bec3fe9c0683	194361d9-248a-4326-a562-9bc80edf87b0	2026-05-02	23	1	1
8185b07d-c31a-4ff0-b4de-a2c5a39c0cf1	194361d9-248a-4326-a562-9bc80edf87b0	2026-05-01	23	0	0
87a641d0-5c59-42ef-ba1a-ac89288234ce	194361d9-248a-4326-a562-9bc80edf87b0	2026-04-30	29	0	0
9e87f0c1-1f9e-4b90-af42-3e96fcb822db	194361d9-248a-4326-a562-9bc80edf87b0	2026-04-29	22	2	1
a6ab276b-506b-4fb6-bd61-cdf364d418ff	194361d9-248a-4326-a562-9bc80edf87b0	2026-04-28	40	0	1
78ed86ec-d195-4f54-9a38-7c86343570ae	194361d9-248a-4326-a562-9bc80edf87b0	2026-04-27	38	0	0
a3d0dbce-c2a5-4bfc-a40a-49573b6e4141	194361d9-248a-4326-a562-9bc80edf87b0	2026-04-26	28	1	0
6e6e4d3c-7d7e-4a00-af9f-2136f64dc9f1	194361d9-248a-4326-a562-9bc80edf87b0	2026-04-25	21	0	1
3ed85e12-5eef-4c8d-97eb-91c870bb215b	194361d9-248a-4326-a562-9bc80edf87b0	2026-04-24	22	2	0
4b68bf1e-1533-4300-b89f-f7b239e30cc6	194361d9-248a-4326-a562-9bc80edf87b0	2026-04-23	25	1	1
94021dd0-a6ad-4a20-8ca1-f75afbd9a865	194361d9-248a-4326-a562-9bc80edf87b0	2026-04-22	26	2	1
307b124e-9613-4439-84bd-0a5ec5da8fc1	194361d9-248a-4326-a562-9bc80edf87b0	2026-04-21	34	1	1
0f958792-9f44-439a-84c1-f2d4f25025af	194361d9-248a-4326-a562-9bc80edf87b0	2026-04-20	23	1	1
dc4abfdf-1878-4e1a-bbd2-c3130a4417a2	194361d9-248a-4326-a562-9bc80edf87b0	2026-04-19	33	2	0
520d5381-7fae-460b-83b2-c4384e5c2d1c	194361d9-248a-4326-a562-9bc80edf87b0	2026-04-18	38	0	1
01c59f5e-ca79-4359-b086-d04413534d20	194361d9-248a-4326-a562-9bc80edf87b0	2026-04-17	32	2	1
7e7d83b3-3480-4eb4-8275-af7df47070fb	194361d9-248a-4326-a562-9bc80edf87b0	2026-04-16	21	2	2
5ef3e3b3-6b32-4594-8710-2946219d44a3	194361d9-248a-4326-a562-9bc80edf87b0	2026-04-15	23	2	0
17965680-84e2-4698-8eb3-8dbe8a5718ea	194361d9-248a-4326-a562-9bc80edf87b0	2026-04-14	33	1	1
b629d05c-69eb-4aaf-93db-066050b87289	194361d9-248a-4326-a562-9bc80edf87b0	2026-04-13	38	1	0
35afe423-bcbc-4be8-945c-c2e6b782f549	194361d9-248a-4326-a562-9bc80edf87b0	2026-04-12	38	2	2
01a351ba-eb17-45f2-899b-b1dd5331fafe	194361d9-248a-4326-a562-9bc80edf87b0	2026-04-11	36	1	0
74af04ae-34bc-4420-807e-7fa0aa4daf11	194361d9-248a-4326-a562-9bc80edf87b0	2026-04-10	33	0	0
b885907e-efa5-475b-aa30-4e7f11983dee	e34bc7f3-2c05-4501-a0a2-8485e2b2f6ae	2026-05-09	64	0	0
badcb697-138b-44d3-a620-39993107618f	e34bc7f3-2c05-4501-a0a2-8485e2b2f6ae	2026-05-08	56	2	1
d99cdb50-1244-4dfe-92bd-b9d63bbd0193	e34bc7f3-2c05-4501-a0a2-8485e2b2f6ae	2026-05-07	53	0	0
8321dd17-46cb-48cf-adb1-aa4a7c4a1411	e34bc7f3-2c05-4501-a0a2-8485e2b2f6ae	2026-05-06	55	0	1
21fe892e-15e5-401f-9584-b8dc2cf21914	e34bc7f3-2c05-4501-a0a2-8485e2b2f6ae	2026-05-05	55	1	1
fcfda22c-da3e-4e0f-8115-1e1fa02731a6	e34bc7f3-2c05-4501-a0a2-8485e2b2f6ae	2026-05-04	53	2	1
6fecc10a-96dc-45e4-a197-fc5f396c6ba0	e34bc7f3-2c05-4501-a0a2-8485e2b2f6ae	2026-05-03	51	2	2
8f59a585-412a-4a3e-b355-9cf4fe760d5f	e34bc7f3-2c05-4501-a0a2-8485e2b2f6ae	2026-05-02	44	0	0
f6895e25-2f94-4e3b-86a3-0e5d2f7f818e	e34bc7f3-2c05-4501-a0a2-8485e2b2f6ae	2026-05-01	51	2	0
d82dae3b-025f-40b5-9e81-ce4b28a9bd7d	e34bc7f3-2c05-4501-a0a2-8485e2b2f6ae	2026-04-30	49	2	0
9a65e93a-2630-4461-9373-a7a338faa816	e34bc7f3-2c05-4501-a0a2-8485e2b2f6ae	2026-04-29	47	0	1
c22d02be-9a71-4aeb-81a3-b011eaea48c3	e34bc7f3-2c05-4501-a0a2-8485e2b2f6ae	2026-04-28	52	0	0
e0fa3ef0-923b-4a8b-867e-3bc1595d62c9	e34bc7f3-2c05-4501-a0a2-8485e2b2f6ae	2026-04-27	58	1	1
a2891884-0166-4316-93f9-686e11386cca	e34bc7f3-2c05-4501-a0a2-8485e2b2f6ae	2026-04-26	47	1	0
f128827d-824a-41d6-be21-0a3f11e34303	e34bc7f3-2c05-4501-a0a2-8485e2b2f6ae	2026-04-25	57	0	1
9bc9af21-ad10-4849-a514-9bd775a51414	e34bc7f3-2c05-4501-a0a2-8485e2b2f6ae	2026-04-24	44	1	0
9de69867-c266-40b8-abe8-8941b4b37ef4	e34bc7f3-2c05-4501-a0a2-8485e2b2f6ae	2026-04-23	45	2	0
d046d2d7-fb3f-4624-977f-7347ed4a4032	e34bc7f3-2c05-4501-a0a2-8485e2b2f6ae	2026-04-22	51	1	0
2478f123-0d19-465f-8fc8-0f554148e112	e34bc7f3-2c05-4501-a0a2-8485e2b2f6ae	2026-04-21	54	2	0
682e59a2-0ec0-49d7-84cf-7305868c08cd	e34bc7f3-2c05-4501-a0a2-8485e2b2f6ae	2026-04-20	49	0	1
0765453d-0a8f-405e-8421-76ca1c33e5f8	e34bc7f3-2c05-4501-a0a2-8485e2b2f6ae	2026-04-19	58	0	0
b69a1de4-ab34-4379-8ee9-046e0030381d	e34bc7f3-2c05-4501-a0a2-8485e2b2f6ae	2026-04-18	56	0	0
90f34e86-67c0-466e-9bce-c020976eb70c	e34bc7f3-2c05-4501-a0a2-8485e2b2f6ae	2026-04-17	54	2	1
999b8a66-c7d7-4f86-9e1c-aa20583b1f78	e34bc7f3-2c05-4501-a0a2-8485e2b2f6ae	2026-04-16	59	2	1
be28a6a8-8654-472c-a285-056f614e0611	e34bc7f3-2c05-4501-a0a2-8485e2b2f6ae	2026-04-15	53	1	0
fa6c36ca-0caf-42ed-abd6-7a75b7523158	e34bc7f3-2c05-4501-a0a2-8485e2b2f6ae	2026-04-14	59	2	0
c54a3074-b954-4ace-844b-cdb5e4171e32	e34bc7f3-2c05-4501-a0a2-8485e2b2f6ae	2026-04-13	57	0	1
6f8d8c38-4352-46ff-8a7a-13bba74c1160	e34bc7f3-2c05-4501-a0a2-8485e2b2f6ae	2026-04-12	52	0	1
a400b25b-9576-47db-ab3f-7be0203bc613	e34bc7f3-2c05-4501-a0a2-8485e2b2f6ae	2026-04-11	54	2	0
e978dd3a-df60-4b48-9e8f-46085124a5a4	e34bc7f3-2c05-4501-a0a2-8485e2b2f6ae	2026-04-10	56	0	0
ed6e8149-9c15-4cda-8e5c-1b4717d0fb9a	94336ae8-266f-4a34-a56f-c025c093fac9	2026-05-09	33	0	1
136dfa9c-1ae5-482d-8e3e-92ee8c9584bb	94336ae8-266f-4a34-a56f-c025c093fac9	2026-05-08	23	1	1
ced3a0a1-af66-4990-b0b1-5e53d66c1391	94336ae8-266f-4a34-a56f-c025c093fac9	2026-05-07	38	2	1
a267121d-32d3-4f4c-a5f4-c6bb45f8d6c6	94336ae8-266f-4a34-a56f-c025c093fac9	2026-05-06	38	0	1
873ee6aa-11be-449f-8ff6-adc4661be35f	94336ae8-266f-4a34-a56f-c025c093fac9	2026-05-05	36	1	1
f6f212b1-d5cf-40ee-bb47-c970a75886cb	94336ae8-266f-4a34-a56f-c025c093fac9	2026-05-04	28	0	0
da0632d9-4d4f-41f0-b433-e867400c8060	94336ae8-266f-4a34-a56f-c025c093fac9	2026-05-03	27	0	0
bac4914c-7a72-483a-a8e2-0343a0a0a9c5	94336ae8-266f-4a34-a56f-c025c093fac9	2026-05-02	12	1	1
6e11f674-416c-4d49-8150-1d08c7c009f8	94336ae8-266f-4a34-a56f-c025c093fac9	2026-05-01	24	2	1
b739db04-bae8-4941-929e-5c14549fb393	94336ae8-266f-4a34-a56f-c025c093fac9	2026-04-30	15	1	0
4dc25dfe-93b6-4ad1-b33a-562f989b611d	94336ae8-266f-4a34-a56f-c025c093fac9	2026-04-29	21	1	1
a22b89ff-5755-4480-9961-f457e74edc7b	94336ae8-266f-4a34-a56f-c025c093fac9	2026-04-28	14	1	1
7d38b862-2787-4907-94af-f112249df1ff	94336ae8-266f-4a34-a56f-c025c093fac9	2026-04-27	18	0	0
35829604-6480-466b-94d5-460f043400fc	94336ae8-266f-4a34-a56f-c025c093fac9	2026-04-26	27	1	0
5d477a3e-8578-4dbd-933b-1685ccf526b9	94336ae8-266f-4a34-a56f-c025c093fac9	2026-04-25	28	1	1
719f4c6f-361a-40f0-942f-120f8af5201a	94336ae8-266f-4a34-a56f-c025c093fac9	2026-04-24	14	0	1
08c33513-97bc-47e0-8839-7f79cc62f6ac	94336ae8-266f-4a34-a56f-c025c093fac9	2026-04-23	24	1	1
8887d5ab-588c-4b32-b9b9-106012f16e0e	94336ae8-266f-4a34-a56f-c025c093fac9	2026-04-22	11	0	1
cd833c46-38b8-4967-99ae-d6ed7dbc4f87	94336ae8-266f-4a34-a56f-c025c093fac9	2026-04-21	29	1	0
a534d89f-dda3-4001-bb76-c3d80fa721a4	94336ae8-266f-4a34-a56f-c025c093fac9	2026-04-20	19	1	1
23d36c90-6435-4c86-a017-3ae5613292ec	94336ae8-266f-4a34-a56f-c025c093fac9	2026-04-19	25	2	1
242ce68d-9c21-4740-b010-6ce537099c5c	94336ae8-266f-4a34-a56f-c025c093fac9	2026-04-18	24	0	1
2227055c-dbf2-41a5-8955-33d68c163115	94336ae8-266f-4a34-a56f-c025c093fac9	2026-04-17	11	2	1
67a088db-d9a1-42e4-a6cc-d65e210103b6	94336ae8-266f-4a34-a56f-c025c093fac9	2026-04-16	11	1	0
6719b24b-2e75-45ab-8760-d0c16a08730f	94336ae8-266f-4a34-a56f-c025c093fac9	2026-04-15	16	1	1
dcb425cc-d16a-4ae7-a9c4-f91412a4f9c1	94336ae8-266f-4a34-a56f-c025c093fac9	2026-04-14	25	1	1
a61961f5-d39a-443d-9144-c2da06508e0b	94336ae8-266f-4a34-a56f-c025c093fac9	2026-04-13	26	1	0
c0986d61-b9be-4edd-8b92-f5bd63cd85c2	94336ae8-266f-4a34-a56f-c025c093fac9	2026-04-12	23	0	2
3dc3e4ec-4a76-4d56-8b85-9c6eace6fe4c	94336ae8-266f-4a34-a56f-c025c093fac9	2026-04-11	26	2	1
4223b495-b0fb-404e-8fbd-3bd57babbc40	94336ae8-266f-4a34-a56f-c025c093fac9	2026-04-10	11	0	1
9f110ae3-f3d4-4c33-8249-d8ad50047fe8	07b5061a-9441-4c07-9628-aa49767f8451	2026-05-09	58	2	1
2ba0c8dc-1a55-43b6-b737-e7cf3e09c9c0	07b5061a-9441-4c07-9628-aa49767f8451	2026-05-08	56	2	1
5f9b43f5-54d6-4b6d-8d4f-1da018275800	07b5061a-9441-4c07-9628-aa49767f8451	2026-05-07	56	0	0
ead2596f-c507-401c-8a1d-a4fbf8b051af	07b5061a-9441-4c07-9628-aa49767f8451	2026-05-06	55	0	2
b1634bbd-78da-4506-9a3b-f43e4018f110	07b5061a-9441-4c07-9628-aa49767f8451	2026-05-05	47	0	0
ccde36e8-d91d-465a-8e65-aefc6c52e571	07b5061a-9441-4c07-9628-aa49767f8451	2026-05-04	57	2	0
8a2d5225-610e-4dd4-824a-a81f7d88ae84	07b5061a-9441-4c07-9628-aa49767f8451	2026-05-03	49	1	1
004e3398-0e35-444b-b50d-31368e314819	07b5061a-9441-4c07-9628-aa49767f8451	2026-05-02	49	2	1
e85f1ebb-18b5-45da-9f46-06a699762cfa	07b5061a-9441-4c07-9628-aa49767f8451	2026-05-01	45	0	0
ec18a23a-82fe-4797-b7f3-f3a999c919ee	07b5061a-9441-4c07-9628-aa49767f8451	2026-04-30	45	2	1
5e466d81-aa55-4a69-9971-7aee709d3cae	07b5061a-9441-4c07-9628-aa49767f8451	2026-04-29	42	0	1
f4507189-b021-4a19-b9c4-3de4d59499de	07b5061a-9441-4c07-9628-aa49767f8451	2026-04-28	40	2	1
bb06d194-2d13-4e00-b556-8ed226cf23f5	07b5061a-9441-4c07-9628-aa49767f8451	2026-04-27	47	1	0
1a078a9c-20be-4a76-946d-173a1746e620	07b5061a-9441-4c07-9628-aa49767f8451	2026-04-26	53	2	0
28cbc54c-c6d7-4b40-81ba-dfe7182d91f2	07b5061a-9441-4c07-9628-aa49767f8451	2026-04-25	44	1	1
eff52635-3108-4c17-b98c-81b0b0632e01	07b5061a-9441-4c07-9628-aa49767f8451	2026-04-24	50	0	1
e3499da4-402d-47c9-8bac-ce4e514f725f	07b5061a-9441-4c07-9628-aa49767f8451	2026-04-23	46	2	1
199595e4-b395-4740-9b23-765f66fcbc25	07b5061a-9441-4c07-9628-aa49767f8451	2026-04-22	36	0	0
f56c1650-145d-4d39-a488-f259f2fe2b47	07b5061a-9441-4c07-9628-aa49767f8451	2026-04-21	36	2	1
5e4efaa8-c51d-46e9-8ae9-4116000a7e22	07b5061a-9441-4c07-9628-aa49767f8451	2026-04-20	40	2	2
06295fd5-0b67-404a-bc39-9b3529ffbfe9	07b5061a-9441-4c07-9628-aa49767f8451	2026-04-19	48	2	1
701a2406-16dc-4269-9286-f46a1ff8471e	07b5061a-9441-4c07-9628-aa49767f8451	2026-04-18	40	1	1
f8d0ea05-e1d6-4248-a940-f4b29396e416	07b5061a-9441-4c07-9628-aa49767f8451	2026-04-17	39	0	1
f1ab4e70-e78d-41e0-a2f8-140afd17dd07	07b5061a-9441-4c07-9628-aa49767f8451	2026-04-16	52	1	1
b2574696-c088-4900-91d7-e38f2a0dd36c	07b5061a-9441-4c07-9628-aa49767f8451	2026-04-15	36	0	1
9e4069b4-c001-41a2-9fd3-67b22fac376b	07b5061a-9441-4c07-9628-aa49767f8451	2026-04-14	53	2	0
7e062d3f-0239-4819-bb12-519c34056994	07b5061a-9441-4c07-9628-aa49767f8451	2026-04-13	40	2	1
25d0a9e5-e3df-446f-9f66-adad4c6cfcb6	07b5061a-9441-4c07-9628-aa49767f8451	2026-04-12	54	0	1
759eeaeb-9fa4-49dc-9630-ae642b8d56b9	07b5061a-9441-4c07-9628-aa49767f8451	2026-04-11	52	2	0
292285c7-74f7-43c9-831d-069ffee84830	07b5061a-9441-4c07-9628-aa49767f8451	2026-04-10	53	1	1
a270bdbc-6d35-4c5f-bc7a-6af2c0868f56	8be5f9cd-9806-454d-94a4-8e795d93054c	2026-05-09	29	2	0
6482bf13-a083-47d4-a57d-95e74f833b12	8be5f9cd-9806-454d-94a4-8e795d93054c	2026-05-08	40	0	0
3dacb8c8-3179-49c2-a7ce-32e111d0500e	8be5f9cd-9806-454d-94a4-8e795d93054c	2026-05-07	37	0	0
51bab31b-69fd-4c81-b792-30789aeeada6	8be5f9cd-9806-454d-94a4-8e795d93054c	2026-05-06	43	0	1
0af6808e-0320-47e9-a831-271e7e078509	8be5f9cd-9806-454d-94a4-8e795d93054c	2026-05-05	37	2	1
a77c63d8-5f4a-4c7d-a3f3-e97ceeb718f3	8be5f9cd-9806-454d-94a4-8e795d93054c	2026-05-04	36	0	1
ad1366a2-4615-4433-927c-967980e1bb53	8be5f9cd-9806-454d-94a4-8e795d93054c	2026-05-03	28	1	0
b37e8fe0-dab4-42a5-8490-56dab0ae0f6b	8be5f9cd-9806-454d-94a4-8e795d93054c	2026-05-02	31	1	1
b907d370-41bc-4811-8947-6a735f1eda36	8be5f9cd-9806-454d-94a4-8e795d93054c	2026-05-01	19	2	0
1e109192-71f4-4429-a16b-004433f8a061	8be5f9cd-9806-454d-94a4-8e795d93054c	2026-04-30	23	1	1
f5e43807-a421-4d86-8235-bd43a41cee0a	8be5f9cd-9806-454d-94a4-8e795d93054c	2026-04-29	31	1	2
93a4e7dc-dd56-4f99-8203-ade41e3e68c8	8be5f9cd-9806-454d-94a4-8e795d93054c	2026-04-28	27	1	1
ff4e67a2-b701-4511-b80d-a1af1110f531	8be5f9cd-9806-454d-94a4-8e795d93054c	2026-04-27	22	0	1
5b40e1eb-7eae-4dc8-a862-19671a7bd42f	8be5f9cd-9806-454d-94a4-8e795d93054c	2026-04-26	20	2	2
96e422f3-2acc-4b3c-98e0-789132d0032c	8be5f9cd-9806-454d-94a4-8e795d93054c	2026-04-25	22	1	0
16c71686-0e57-476d-8ad2-158350e06c3e	8be5f9cd-9806-454d-94a4-8e795d93054c	2026-04-24	20	2	1
7511cc5e-8196-440e-9338-4d765d5f6856	8be5f9cd-9806-454d-94a4-8e795d93054c	2026-04-23	19	2	1
f193104a-b8b0-4223-b644-4e725929a28e	8be5f9cd-9806-454d-94a4-8e795d93054c	2026-04-22	29	1	0
bff146d9-d3c9-4018-8702-84a02d21ea31	8be5f9cd-9806-454d-94a4-8e795d93054c	2026-04-21	31	0	1
458ea167-9c5d-4b52-ae9a-546c4855a31f	8be5f9cd-9806-454d-94a4-8e795d93054c	2026-04-20	16	0	1
32bedd5f-955c-4c66-abf2-1db8b494de24	8be5f9cd-9806-454d-94a4-8e795d93054c	2026-04-19	25	2	0
b81beeaf-4266-4415-9b2c-2890c1bc6a4c	8be5f9cd-9806-454d-94a4-8e795d93054c	2026-04-18	16	0	0
7160b0dc-3bb7-4257-b21b-060fc11e5e0d	8be5f9cd-9806-454d-94a4-8e795d93054c	2026-04-17	17	2	0
55ef18f9-2575-4c88-bb5d-aa0ccb09ed71	8be5f9cd-9806-454d-94a4-8e795d93054c	2026-04-16	17	0	0
a107e0a7-8285-43df-9a2d-e0af985cc3a0	8be5f9cd-9806-454d-94a4-8e795d93054c	2026-04-15	29	2	1
192c6bf6-2ec1-484b-a663-919eb1b613ce	8be5f9cd-9806-454d-94a4-8e795d93054c	2026-04-14	24	0	2
b6420a3d-0016-4f97-b6ad-cc29d46fe56d	8be5f9cd-9806-454d-94a4-8e795d93054c	2026-04-13	21	1	1
03e47d4a-7f16-41c2-bea0-91003dbec08a	8be5f9cd-9806-454d-94a4-8e795d93054c	2026-04-12	20	1	1
5d7bf212-2c51-44c7-adaa-806bfc554831	8be5f9cd-9806-454d-94a4-8e795d93054c	2026-04-11	17	2	1
eae7199a-1c60-4751-accd-aa705055ea1a	8be5f9cd-9806-454d-94a4-8e795d93054c	2026-04-10	22	1	2
3169c856-ff9b-4d27-abd8-7717351fde34	9f36339c-9535-41b0-8c96-74c747bee0f4	2026-05-09	31	2	1
a4d40e0e-ce23-49dc-bdc7-a55f8beab66e	9f36339c-9535-41b0-8c96-74c747bee0f4	2026-05-08	38	1	1
e2a3705d-0b15-47dc-9edd-3147d2b5d23c	9f36339c-9535-41b0-8c96-74c747bee0f4	2026-05-07	42	1	1
28368f4e-f849-4ca1-8e7c-b7b6e1e6413e	9f36339c-9535-41b0-8c96-74c747bee0f4	2026-05-06	29	2	2
ffe45349-5276-4571-9d5f-eca231b19b17	9f36339c-9535-41b0-8c96-74c747bee0f4	2026-05-05	43	0	1
f773cec7-bed4-409c-95b8-8b0248e7bd72	9f36339c-9535-41b0-8c96-74c747bee0f4	2026-05-04	42	1	1
f87e7004-6246-4b2a-81b7-0351ec481f6f	9f36339c-9535-41b0-8c96-74c747bee0f4	2026-05-03	40	1	1
cfcf4fb1-e767-4e67-af52-32ddaec6ea03	9f36339c-9535-41b0-8c96-74c747bee0f4	2026-05-02	20	0	1
0118992a-0669-426a-9fd3-40bda71c5d61	9f36339c-9535-41b0-8c96-74c747bee0f4	2026-05-01	26	0	1
389bc8c1-1221-46c4-886a-dc4a414eb8d9	9f36339c-9535-41b0-8c96-74c747bee0f4	2026-04-30	23	1	1
35ee1b2d-7560-4edb-8a8e-3521c5663900	9f36339c-9535-41b0-8c96-74c747bee0f4	2026-04-29	27	2	0
c260ae2b-87a7-4207-b56d-ea53ad645de5	9f36339c-9535-41b0-8c96-74c747bee0f4	2026-04-28	34	2	0
9de6d14b-6af1-40ec-8565-b7768ba44bf0	9f36339c-9535-41b0-8c96-74c747bee0f4	2026-04-27	29	1	2
20982608-0dcb-497c-9de3-7fcb24fb4ff1	9f36339c-9535-41b0-8c96-74c747bee0f4	2026-04-26	23	1	0
d4e23d75-8581-43cb-9c10-1b4325a2a939	9f36339c-9535-41b0-8c96-74c747bee0f4	2026-04-25	28	0	1
38ee664e-b960-4cac-bfa7-f1c8ba18d972	9f36339c-9535-41b0-8c96-74c747bee0f4	2026-04-24	24	1	1
4b24c3de-3c36-49c3-9d37-4a1d28524e3a	9f36339c-9535-41b0-8c96-74c747bee0f4	2026-04-23	28	1	0
ed2f4a81-2192-494f-9e41-c7dca6dbad08	9f36339c-9535-41b0-8c96-74c747bee0f4	2026-04-22	33	2	1
7b7b59ec-283b-43fe-a65b-88f9bdabb616	9f36339c-9535-41b0-8c96-74c747bee0f4	2026-04-21	21	0	1
b192402e-6e61-4a61-aa7c-cd58f3045859	9f36339c-9535-41b0-8c96-74c747bee0f4	2026-04-20	26	1	1
0f44124b-f27f-48a1-9955-1bb0f3798e51	9f36339c-9535-41b0-8c96-74c747bee0f4	2026-04-19	33	0	1
e6b4a496-6521-4dba-85ac-8bc97c6c87aa	9f36339c-9535-41b0-8c96-74c747bee0f4	2026-04-18	21	0	1
023b026f-6bd7-4912-93e7-cb415e08abe4	9f36339c-9535-41b0-8c96-74c747bee0f4	2026-04-17	29	0	1
d9dfca19-1977-451d-8031-43204fcbecbd	9f36339c-9535-41b0-8c96-74c747bee0f4	2026-04-16	29	2	1
6cb8a321-4d5a-4d53-bb8b-6c25ed27243a	9f36339c-9535-41b0-8c96-74c747bee0f4	2026-04-15	32	2	1
1b922ef0-7e0f-4393-bdcc-b8ac7d496151	9f36339c-9535-41b0-8c96-74c747bee0f4	2026-04-14	28	0	1
27035921-1e0a-47f2-b7e3-b6a69b6feed6	9f36339c-9535-41b0-8c96-74c747bee0f4	2026-04-13	24	0	0
8980aed4-fa42-43aa-98a0-037d0311ba5d	9f36339c-9535-41b0-8c96-74c747bee0f4	2026-04-12	19	0	1
231fa52b-983e-4745-bc6b-7ca142156a0c	9f36339c-9535-41b0-8c96-74c747bee0f4	2026-04-11	21	1	0
451e7550-e1e9-4006-88fb-ac020aab97f5	9f36339c-9535-41b0-8c96-74c747bee0f4	2026-04-10	25	2	0
e013d3ab-c6f1-452c-89db-0815a50f1915	3aa34d57-aac7-4d3c-a64b-34f5bfbd4c25	2026-05-09	45	0	0
e22b8168-b9e2-468a-9d0b-bcb38b9a7a36	3aa34d57-aac7-4d3c-a64b-34f5bfbd4c25	2026-05-08	34	2	2
b5064e33-cb19-47c2-8010-549997d7a9e5	3aa34d57-aac7-4d3c-a64b-34f5bfbd4c25	2026-05-07	32	0	1
47d1f76e-2e3c-4a54-ac56-718f53b4befc	3aa34d57-aac7-4d3c-a64b-34f5bfbd4c25	2026-05-06	31	1	1
20d5153c-76a2-4e22-b64c-5e77caf70fd5	3aa34d57-aac7-4d3c-a64b-34f5bfbd4c25	2026-05-05	39	2	1
41aa1bce-5770-42bb-9aa4-5b0ebf8a6df0	3aa34d57-aac7-4d3c-a64b-34f5bfbd4c25	2026-05-04	30	0	0
848aa0b9-b6bf-4a45-9c7c-114369c3e51e	3aa34d57-aac7-4d3c-a64b-34f5bfbd4c25	2026-05-03	37	1	0
17933f88-5a05-4f28-b442-0b1cc5ac976f	3aa34d57-aac7-4d3c-a64b-34f5bfbd4c25	2026-05-02	25	1	2
29f8b4fd-d880-46db-b752-9d10a6b957f5	3aa34d57-aac7-4d3c-a64b-34f5bfbd4c25	2026-05-01	25	1	0
8ed6fff2-8761-4b84-b953-986868290e09	3aa34d57-aac7-4d3c-a64b-34f5bfbd4c25	2026-04-30	19	0	0
fd1f2206-8620-4b1c-b493-813b0dbb28c6	3aa34d57-aac7-4d3c-a64b-34f5bfbd4c25	2026-04-29	34	1	0
fc631ed5-7d29-4498-a231-72590d3ede98	3aa34d57-aac7-4d3c-a64b-34f5bfbd4c25	2026-04-28	24	2	1
24b56c63-f8a3-4a4e-834d-d728fa99fd40	3aa34d57-aac7-4d3c-a64b-34f5bfbd4c25	2026-04-27	30	0	2
d93c7aaf-df38-4451-af39-3e933c78d1c0	3aa34d57-aac7-4d3c-a64b-34f5bfbd4c25	2026-04-26	29	1	0
3940e3d8-6d0b-4a17-b6b0-8d94436fb7ad	3aa34d57-aac7-4d3c-a64b-34f5bfbd4c25	2026-04-25	33	2	1
0c3b7a06-7ac8-4d55-82eb-9c56b75385b0	3aa34d57-aac7-4d3c-a64b-34f5bfbd4c25	2026-04-24	35	0	0
7c7ba39d-129a-4041-bbac-1d89a0a88f2e	3aa34d57-aac7-4d3c-a64b-34f5bfbd4c25	2026-04-23	28	2	1
a82ce567-9d50-4f5f-8a1d-bf5099573896	3aa34d57-aac7-4d3c-a64b-34f5bfbd4c25	2026-04-22	28	0	1
4ea7d450-2df3-4146-be1e-62a33e484583	3aa34d57-aac7-4d3c-a64b-34f5bfbd4c25	2026-04-21	16	2	0
7c9b50ac-c6cc-481a-ad62-ed5f01b8a2c2	3aa34d57-aac7-4d3c-a64b-34f5bfbd4c25	2026-04-20	20	2	0
9c8e92fc-002b-447b-a3c7-f8fc397b1ac6	3aa34d57-aac7-4d3c-a64b-34f5bfbd4c25	2026-04-19	29	0	2
cfcd787a-eee9-44ce-9eb4-da33ed2b4e97	3aa34d57-aac7-4d3c-a64b-34f5bfbd4c25	2026-04-18	22	2	0
94cee3d8-6439-4be6-aafd-fa2ed1b572ca	3aa34d57-aac7-4d3c-a64b-34f5bfbd4c25	2026-04-17	33	0	0
71bed98a-116b-4765-82e8-ae2cb122ba08	3aa34d57-aac7-4d3c-a64b-34f5bfbd4c25	2026-04-16	20	0	1
10404d88-c7c1-4363-840a-f0609f8e5f8b	3aa34d57-aac7-4d3c-a64b-34f5bfbd4c25	2026-04-15	28	1	0
156175c1-936b-4361-9c35-927ea761e73d	3aa34d57-aac7-4d3c-a64b-34f5bfbd4c25	2026-04-14	34	0	1
a0e300a6-fc21-4b94-867b-c07d69e8cc17	3aa34d57-aac7-4d3c-a64b-34f5bfbd4c25	2026-04-13	31	0	1
778bff9e-43fd-45ae-ab97-c337fa3c2eca	3aa34d57-aac7-4d3c-a64b-34f5bfbd4c25	2026-04-12	35	2	0
41c81c3e-165b-4b68-99c6-24759e9aaad9	3aa34d57-aac7-4d3c-a64b-34f5bfbd4c25	2026-04-11	21	2	1
1eff8fb0-ff86-4c5f-a206-5c83382b7034	3aa34d57-aac7-4d3c-a64b-34f5bfbd4c25	2026-04-10	33	0	0
1b843403-9f5d-489c-8f13-916fa22848b9	c809a9af-3a5b-49aa-a416-ba7f9666b0fd	2026-05-09	35	1	1
e36d8ebd-641c-4fa4-b6be-7fc3841f48e4	c809a9af-3a5b-49aa-a416-ba7f9666b0fd	2026-05-08	35	0	0
8b26b395-760f-478a-9cee-7ee105de2bc7	c809a9af-3a5b-49aa-a416-ba7f9666b0fd	2026-05-07	38	2	0
86a36052-5d99-4d55-88d1-5560385bdc68	c809a9af-3a5b-49aa-a416-ba7f9666b0fd	2026-05-06	27	1	2
5a1b50c8-932b-4e5e-ac98-4505e7a06801	c809a9af-3a5b-49aa-a416-ba7f9666b0fd	2026-05-05	34	0	1
cda1602e-d022-4771-a5c9-8153c4b2f0df	c809a9af-3a5b-49aa-a416-ba7f9666b0fd	2026-05-04	34	0	2
8181c3e9-b288-4533-b8d1-f5dd566b7131	c809a9af-3a5b-49aa-a416-ba7f9666b0fd	2026-05-03	40	1	0
b7f5585f-5ceb-4036-b368-5763d70b8b23	c809a9af-3a5b-49aa-a416-ba7f9666b0fd	2026-05-02	30	2	0
7e45e6b2-4696-4b58-9d67-e39abf238fc2	c809a9af-3a5b-49aa-a416-ba7f9666b0fd	2026-05-01	21	2	1
e27ac1b5-a564-4091-bd77-5b7b1b6c5486	c809a9af-3a5b-49aa-a416-ba7f9666b0fd	2026-04-30	24	1	0
a0486c20-1380-4085-a2a9-5d67617b9825	c809a9af-3a5b-49aa-a416-ba7f9666b0fd	2026-04-29	25	2	2
d473618e-4f91-43b1-8ccc-0d5558859dd0	c809a9af-3a5b-49aa-a416-ba7f9666b0fd	2026-04-28	27	0	2
c22be64c-6576-4f5b-88f3-f51e56562653	c809a9af-3a5b-49aa-a416-ba7f9666b0fd	2026-04-27	28	0	0
58c542dc-2518-49c7-9480-1297232fdeb0	c809a9af-3a5b-49aa-a416-ba7f9666b0fd	2026-04-26	27	2	1
48deccbd-668c-47a1-a002-d82179d56bab	c809a9af-3a5b-49aa-a416-ba7f9666b0fd	2026-04-25	31	1	2
a5bb271a-fc6f-4b56-beba-5b2efca1b184	c809a9af-3a5b-49aa-a416-ba7f9666b0fd	2026-04-24	27	0	1
4d9e2484-fed3-4501-9000-9846b204fac1	c809a9af-3a5b-49aa-a416-ba7f9666b0fd	2026-04-23	30	1	0
d74b3038-fc6a-41e1-b5e9-e061d6f140cf	c809a9af-3a5b-49aa-a416-ba7f9666b0fd	2026-04-22	27	0	0
f38e79e3-907b-4c91-b009-4cd3e389cd57	c809a9af-3a5b-49aa-a416-ba7f9666b0fd	2026-04-21	30	2	0
242ab1c7-ba1c-4a7c-bc6c-42edcb03ad1c	c809a9af-3a5b-49aa-a416-ba7f9666b0fd	2026-04-20	26	0	2
98d13c66-5fbe-4d37-a798-329ce4ea8523	c809a9af-3a5b-49aa-a416-ba7f9666b0fd	2026-04-19	29	1	1
0a269f7f-3176-4427-8cad-0b6f20b0938b	c809a9af-3a5b-49aa-a416-ba7f9666b0fd	2026-04-18	16	2	0
1c7c9bd2-daa7-48a1-a4d0-9378f69edd9e	c809a9af-3a5b-49aa-a416-ba7f9666b0fd	2026-04-17	26	0	2
2a7cab7c-f70f-43b5-aa0c-c57f2b482fb3	c809a9af-3a5b-49aa-a416-ba7f9666b0fd	2026-04-16	25	0	1
36f546d7-8355-4bfc-9b2f-403b8cc79641	c809a9af-3a5b-49aa-a416-ba7f9666b0fd	2026-04-15	30	2	1
c7f64965-876c-4ee9-bec1-84f2322b9379	c809a9af-3a5b-49aa-a416-ba7f9666b0fd	2026-04-14	20	2	0
5e1d4e6c-323c-4185-95d0-a3bae1409b31	c809a9af-3a5b-49aa-a416-ba7f9666b0fd	2026-04-13	28	0	0
2cea2471-7216-4534-b3ed-105750bf0329	c809a9af-3a5b-49aa-a416-ba7f9666b0fd	2026-04-12	26	1	1
882e74ae-959b-472c-9459-e5369625af1d	c809a9af-3a5b-49aa-a416-ba7f9666b0fd	2026-04-11	21	1	0
2e681e05-7a03-43c1-91e6-75cda2ddb1ee	c809a9af-3a5b-49aa-a416-ba7f9666b0fd	2026-04-10	21	2	0
721ddfa1-07aa-4d86-8a26-4f18d7872255	3a35b1fd-a6b1-4891-bb7e-da394a9dec6b	2026-05-09	36	0	0
8d97212a-919f-4678-99bc-8719b3799b7b	3a35b1fd-a6b1-4891-bb7e-da394a9dec6b	2026-05-08	27	2	0
89837c89-81c7-4a99-9ce3-59eed20b9478	3a35b1fd-a6b1-4891-bb7e-da394a9dec6b	2026-05-07	33	1	0
26daab23-3654-4490-83bf-c1fba12a5499	3a35b1fd-a6b1-4891-bb7e-da394a9dec6b	2026-05-06	38	0	0
cf71f458-7672-4a4a-a1ad-6078d4bb1586	3a35b1fd-a6b1-4891-bb7e-da394a9dec6b	2026-05-05	29	1	1
75fc9b6d-4d02-415b-a4eb-ce7093e5981a	3a35b1fd-a6b1-4891-bb7e-da394a9dec6b	2026-05-04	36	0	1
a65d4e38-a2c3-4d92-883d-660014025448	3a35b1fd-a6b1-4891-bb7e-da394a9dec6b	2026-05-03	33	0	1
60090664-f8b5-4e41-9e18-17de1210533b	3a35b1fd-a6b1-4891-bb7e-da394a9dec6b	2026-05-02	10	1	0
88184979-b420-436f-91a9-fba00101e506	3a35b1fd-a6b1-4891-bb7e-da394a9dec6b	2026-05-01	17	1	0
e9f859e5-989c-41b2-89f9-54ed186d17d6	3a35b1fd-a6b1-4891-bb7e-da394a9dec6b	2026-04-30	26	1	1
4763e751-f451-4e79-bd5e-207c8d1ddbb5	3a35b1fd-a6b1-4891-bb7e-da394a9dec6b	2026-04-29	27	0	1
88d9c7c2-ab85-4e5b-af2d-4588558505e2	3a35b1fd-a6b1-4891-bb7e-da394a9dec6b	2026-04-28	21	1	1
57751647-58c8-4ca9-8656-2340f53ca86e	3a35b1fd-a6b1-4891-bb7e-da394a9dec6b	2026-04-27	19	0	2
29ea1b26-8670-416d-a944-ea6a0db355b5	3a35b1fd-a6b1-4891-bb7e-da394a9dec6b	2026-04-26	20	0	1
8d5c5166-20d8-40ff-8b33-3ada7c4ac1af	3a35b1fd-a6b1-4891-bb7e-da394a9dec6b	2026-04-25	16	0	0
16115996-2669-4a60-a41a-3a1a276a2327	3a35b1fd-a6b1-4891-bb7e-da394a9dec6b	2026-04-24	29	2	0
ff8ed641-b7b6-47c6-b58f-011f66880591	3a35b1fd-a6b1-4891-bb7e-da394a9dec6b	2026-04-23	23	2	1
09eba294-ce93-4e58-94b1-32463f91db33	3a35b1fd-a6b1-4891-bb7e-da394a9dec6b	2026-04-22	17	2	1
3c9cac48-0006-40b9-bda5-4c14d8a26f20	3a35b1fd-a6b1-4891-bb7e-da394a9dec6b	2026-04-21	25	0	1
374412bf-72d5-4874-ba0a-49f10db90adf	3a35b1fd-a6b1-4891-bb7e-da394a9dec6b	2026-04-20	13	0	2
297bf47f-7be7-4b63-a465-3dfe3e64f9cf	3a35b1fd-a6b1-4891-bb7e-da394a9dec6b	2026-04-19	26	0	0
383a2cd3-7199-479c-97c2-686fdcb27f71	3a35b1fd-a6b1-4891-bb7e-da394a9dec6b	2026-04-18	29	0	1
bc222648-95e1-4b97-976c-2503d7ba7d55	3a35b1fd-a6b1-4891-bb7e-da394a9dec6b	2026-04-17	12	2	0
5fe22dc5-d3b3-451c-a240-400ecf29e665	3a35b1fd-a6b1-4891-bb7e-da394a9dec6b	2026-04-16	27	2	0
9d98d981-a15d-4c3d-8530-50c12143b5f1	3a35b1fd-a6b1-4891-bb7e-da394a9dec6b	2026-04-15	29	1	1
4efda6c5-68ed-48d5-b682-6d8498f63512	3a35b1fd-a6b1-4891-bb7e-da394a9dec6b	2026-04-14	26	2	1
d887c6f2-f9b9-4086-9f85-30844d767fbd	3a35b1fd-a6b1-4891-bb7e-da394a9dec6b	2026-04-13	24	2	0
65b599b6-e05a-40f3-b33e-42728b506024	3a35b1fd-a6b1-4891-bb7e-da394a9dec6b	2026-04-12	30	1	2
5468e2f9-cf0a-462f-becf-db9640dcab88	3a35b1fd-a6b1-4891-bb7e-da394a9dec6b	2026-04-11	20	1	1
ef653bf0-f9fa-4a96-9493-9fbb7b7548a5	3a35b1fd-a6b1-4891-bb7e-da394a9dec6b	2026-04-10	18	0	1
055a39e2-c48d-4634-9cd0-010aa3320d35	c675e64e-80e2-4c5d-8190-c9d6fda1da2d	2026-05-09	63	0	0
8ccf24ae-a184-4002-b2f2-806542c36373	c675e64e-80e2-4c5d-8190-c9d6fda1da2d	2026-05-08	67	1	1
fbf97974-8761-4574-8b7f-1c33db7ef1b3	c675e64e-80e2-4c5d-8190-c9d6fda1da2d	2026-05-07	65	0	1
44aef3bc-6aa8-4019-b82e-76c11e713404	c675e64e-80e2-4c5d-8190-c9d6fda1da2d	2026-05-06	67	2	1
77555aae-a52a-427f-8c6e-35b9b234763a	c675e64e-80e2-4c5d-8190-c9d6fda1da2d	2026-05-05	54	1	0
fbf1a276-33ef-47d4-864e-93141fd4a0a2	c675e64e-80e2-4c5d-8190-c9d6fda1da2d	2026-05-04	63	1	1
a3db4c09-bae1-4d33-816b-3f6abe15de2f	c675e64e-80e2-4c5d-8190-c9d6fda1da2d	2026-05-03	57	1	1
aab3879c-3e42-408d-a9fa-b5e4ea395c32	c675e64e-80e2-4c5d-8190-c9d6fda1da2d	2026-05-02	50	0	1
ba8fbfa3-c315-4947-b168-f34cdac293c4	c675e64e-80e2-4c5d-8190-c9d6fda1da2d	2026-05-01	58	2	1
4d8ada90-7d66-4b72-8a9e-7df649c4c4e3	c675e64e-80e2-4c5d-8190-c9d6fda1da2d	2026-04-30	59	1	0
cd8cd770-7a7a-4b7f-a6b6-d681b1a2cd3a	c675e64e-80e2-4c5d-8190-c9d6fda1da2d	2026-04-29	48	1	1
92765810-b3a3-49be-ad9f-639be146cdd0	c675e64e-80e2-4c5d-8190-c9d6fda1da2d	2026-04-28	44	0	1
82db9629-f9db-45f7-8312-bf7073d08dbc	c675e64e-80e2-4c5d-8190-c9d6fda1da2d	2026-04-27	46	2	1
59a9dc9c-a3e1-41e8-9f32-4b9a289a50a1	c675e64e-80e2-4c5d-8190-c9d6fda1da2d	2026-04-26	49	1	0
58c5e674-c088-4046-b636-afed8efe9235	c675e64e-80e2-4c5d-8190-c9d6fda1da2d	2026-04-25	43	1	0
6cdee6af-2b31-4e25-8e79-e692d973195f	c675e64e-80e2-4c5d-8190-c9d6fda1da2d	2026-04-24	47	2	1
9aad6ec8-d4ba-49e9-a2c4-bfd857cda970	c675e64e-80e2-4c5d-8190-c9d6fda1da2d	2026-04-23	54	0	1
206b60ca-0820-48b3-b2e5-2c3939c26eb0	c675e64e-80e2-4c5d-8190-c9d6fda1da2d	2026-04-22	45	0	0
66deadbc-54a6-448b-a175-759a912c79ab	c675e64e-80e2-4c5d-8190-c9d6fda1da2d	2026-04-21	52	1	1
db86f8a1-d194-42e2-b40e-7e3ef829e129	c675e64e-80e2-4c5d-8190-c9d6fda1da2d	2026-04-20	53	2	1
c6f1264b-768e-4bf3-be4f-a4dfaa30da19	c675e64e-80e2-4c5d-8190-c9d6fda1da2d	2026-04-19	43	0	1
ecc9a4c4-63a4-4e8c-855c-fa5ab20b7580	c675e64e-80e2-4c5d-8190-c9d6fda1da2d	2026-04-18	43	0	0
03e3e23d-e50d-47c2-9832-181d47bb3c00	c675e64e-80e2-4c5d-8190-c9d6fda1da2d	2026-04-17	47	2	2
3c90beb7-eb3b-4dc4-aa1c-bd5d3825face	c675e64e-80e2-4c5d-8190-c9d6fda1da2d	2026-04-16	56	1	0
212d68d5-e3ee-4331-b600-fb4f81ac3112	c675e64e-80e2-4c5d-8190-c9d6fda1da2d	2026-04-15	41	0	0
91ec8262-7082-4ec9-bba6-5b99b81ea1ee	c675e64e-80e2-4c5d-8190-c9d6fda1da2d	2026-04-14	56	0	0
35823377-278f-4133-a228-791cc255df16	c675e64e-80e2-4c5d-8190-c9d6fda1da2d	2026-04-13	49	0	0
0d401478-2cab-433f-b719-b7f4b4fb05f2	c675e64e-80e2-4c5d-8190-c9d6fda1da2d	2026-04-12	51	2	1
5eb8c34d-1c21-463d-bbe2-e6bebb9c0656	c675e64e-80e2-4c5d-8190-c9d6fda1da2d	2026-04-11	43	1	1
e8beb7a0-193d-4be6-b906-92e2cd1b3abb	c675e64e-80e2-4c5d-8190-c9d6fda1da2d	2026-04-10	58	1	0
36abcd0e-a031-4602-b0f5-df3c25b06a7f	1d6b2ebc-c39b-46e5-b3cd-5cfdac2213c7	2026-05-09	36	1	1
ec9f755c-726d-4887-b96e-a416fa2b4e21	1d6b2ebc-c39b-46e5-b3cd-5cfdac2213c7	2026-05-08	25	0	1
9def8b50-ce81-478d-9a68-e817fefdd246	1d6b2ebc-c39b-46e5-b3cd-5cfdac2213c7	2026-05-07	33	2	1
9ba7777c-3c14-4469-aa1e-fbfbab2f5f0f	1d6b2ebc-c39b-46e5-b3cd-5cfdac2213c7	2026-05-06	23	1	0
6fef7219-a8c9-4d8a-b130-3f63150dd607	1d6b2ebc-c39b-46e5-b3cd-5cfdac2213c7	2026-05-05	25	0	1
025b7af2-7c99-441b-8ade-6d5169fa6360	1d6b2ebc-c39b-46e5-b3cd-5cfdac2213c7	2026-05-04	23	0	1
c7c90717-cb49-4132-bcd5-8095ea0630b9	1d6b2ebc-c39b-46e5-b3cd-5cfdac2213c7	2026-05-03	22	0	0
e795cc50-bbe4-4d87-ba83-2418c7bb2b3c	1d6b2ebc-c39b-46e5-b3cd-5cfdac2213c7	2026-05-02	23	2	1
b7e39818-37de-4834-be26-0c33d936c9af	1d6b2ebc-c39b-46e5-b3cd-5cfdac2213c7	2026-05-01	14	0	0
3b5af32f-e3d1-4268-b8bd-80b43e0aa689	1d6b2ebc-c39b-46e5-b3cd-5cfdac2213c7	2026-04-30	25	2	1
06a5f8fb-e044-4e45-bf9f-55e6e0d1d7ac	1d6b2ebc-c39b-46e5-b3cd-5cfdac2213c7	2026-04-29	26	1	2
9675bf94-7f3d-4751-bbd3-c8169104debc	1d6b2ebc-c39b-46e5-b3cd-5cfdac2213c7	2026-04-28	13	1	0
597ac581-43f8-4b22-9c6c-0219a93f99a1	1d6b2ebc-c39b-46e5-b3cd-5cfdac2213c7	2026-04-27	15	0	1
883a41bf-a558-4cd9-bb07-bc899c13a1ad	1d6b2ebc-c39b-46e5-b3cd-5cfdac2213c7	2026-04-26	29	0	1
254df70f-7f3f-4ae0-83af-648f36a0b156	1d6b2ebc-c39b-46e5-b3cd-5cfdac2213c7	2026-04-25	29	2	0
101ae611-cf35-47cc-927c-abb309090bba	1d6b2ebc-c39b-46e5-b3cd-5cfdac2213c7	2026-04-24	15	1	1
2bf00621-7dd9-484a-9d85-becc12cee836	1d6b2ebc-c39b-46e5-b3cd-5cfdac2213c7	2026-04-23	20	0	0
4d26bd61-0216-4404-8433-3c67ca1b2cce	1d6b2ebc-c39b-46e5-b3cd-5cfdac2213c7	2026-04-22	11	2	1
789fe017-99ca-442c-b861-f607e2d857f5	1d6b2ebc-c39b-46e5-b3cd-5cfdac2213c7	2026-04-21	11	0	1
a74e474b-aba0-4d2c-b2df-cdac12bf465b	1d6b2ebc-c39b-46e5-b3cd-5cfdac2213c7	2026-04-20	14	0	1
c9110476-7fce-49d3-8529-d5b0367f0da8	1d6b2ebc-c39b-46e5-b3cd-5cfdac2213c7	2026-04-19	19	0	1
b5ffcc33-1cde-4bfe-ace9-53fc23237ec3	1d6b2ebc-c39b-46e5-b3cd-5cfdac2213c7	2026-04-18	12	0	0
14819d81-083a-4684-83de-e2f99bea5f8d	1d6b2ebc-c39b-46e5-b3cd-5cfdac2213c7	2026-04-17	15	2	2
223db339-6858-4ade-8f41-54792f7d169a	1d6b2ebc-c39b-46e5-b3cd-5cfdac2213c7	2026-04-16	12	2	1
c1161b9b-5ccd-4f57-98fa-ea341f665df2	1d6b2ebc-c39b-46e5-b3cd-5cfdac2213c7	2026-04-15	26	2	0
1a610bbe-4d5b-44a6-b6a5-0a3485b1f28d	1d6b2ebc-c39b-46e5-b3cd-5cfdac2213c7	2026-04-14	26	0	1
b1b09b26-cd0a-499c-bc55-0acbc4aaf711	1d6b2ebc-c39b-46e5-b3cd-5cfdac2213c7	2026-04-13	12	0	0
6922d7af-d5bb-40b4-b3f1-dd6f96701dc1	1d6b2ebc-c39b-46e5-b3cd-5cfdac2213c7	2026-04-12	18	2	0
549b9efa-0e1e-4fc8-8f95-296a5b2c81b4	1d6b2ebc-c39b-46e5-b3cd-5cfdac2213c7	2026-04-11	24	0	2
c46a9ee2-17e4-4762-88f2-ae55fd90e0ce	1d6b2ebc-c39b-46e5-b3cd-5cfdac2213c7	2026-04-10	27	0	2
263bbebf-ba0a-42b3-9f0f-07cb59bfa63f	56572e8e-5fb3-440f-ba77-af00c6d3fa1f	2026-05-09	37	1	1
f9f244ae-7492-4704-b200-4174c136b1d8	56572e8e-5fb3-440f-ba77-af00c6d3fa1f	2026-05-08	31	1	1
3496f443-d2cd-4fbf-ab8a-0da614d2aaf6	56572e8e-5fb3-440f-ba77-af00c6d3fa1f	2026-05-07	33	2	1
a83ead88-b46c-4058-bab4-c41356d360c2	56572e8e-5fb3-440f-ba77-af00c6d3fa1f	2026-05-06	38	0	2
2cbf4880-1720-4963-8579-42a191ba80e9	56572e8e-5fb3-440f-ba77-af00c6d3fa1f	2026-05-05	35	2	0
9431367f-c5d5-4be1-951d-7e7bea16e38d	56572e8e-5fb3-440f-ba77-af00c6d3fa1f	2026-05-04	40	1	1
d6cd1b90-86e4-44d1-9fe5-9c4bc369477b	56572e8e-5fb3-440f-ba77-af00c6d3fa1f	2026-05-03	44	1	1
20567033-e78c-4e19-8905-b4b6dd42b6c4	56572e8e-5fb3-440f-ba77-af00c6d3fa1f	2026-05-02	23	2	0
13607617-eb5c-4a5f-b510-57f315906b6d	56572e8e-5fb3-440f-ba77-af00c6d3fa1f	2026-05-01	33	1	1
4a03820e-232d-4c13-90ee-3e07a92e9ccf	56572e8e-5fb3-440f-ba77-af00c6d3fa1f	2026-04-30	23	2	0
cda2436e-41c1-45cd-bc1a-cc42988a200c	56572e8e-5fb3-440f-ba77-af00c6d3fa1f	2026-04-29	39	0	2
2065c726-dc2f-4f30-b914-a35e41f62101	56572e8e-5fb3-440f-ba77-af00c6d3fa1f	2026-04-28	35	1	1
af8210ab-763a-436f-9565-502e6f8d380b	56572e8e-5fb3-440f-ba77-af00c6d3fa1f	2026-04-27	28	0	1
63337da4-6fe8-4c15-95cd-000a92538367	56572e8e-5fb3-440f-ba77-af00c6d3fa1f	2026-04-26	36	2	2
527c2a89-c523-4502-9f57-c53fa441bebc	56572e8e-5fb3-440f-ba77-af00c6d3fa1f	2026-04-25	35	2	1
e5d7341c-0312-406f-b11c-372d770e0e9e	56572e8e-5fb3-440f-ba77-af00c6d3fa1f	2026-04-24	37	1	1
edc68d66-8976-49f3-b7f4-0ba9288ca0a8	56572e8e-5fb3-440f-ba77-af00c6d3fa1f	2026-04-23	32	1	1
53d11495-a8a1-401d-8a70-78b48d39d1fd	56572e8e-5fb3-440f-ba77-af00c6d3fa1f	2026-04-22	39	1	1
483cb2fd-2a1c-4785-bc8e-86713847e070	56572e8e-5fb3-440f-ba77-af00c6d3fa1f	2026-04-21	40	2	0
ba094218-b1fe-4023-be4e-8c40d09dac47	56572e8e-5fb3-440f-ba77-af00c6d3fa1f	2026-04-20	23	0	2
b56b7cb2-bba9-4e7a-8dad-7d97eeb48690	56572e8e-5fb3-440f-ba77-af00c6d3fa1f	2026-04-19	39	2	1
9b3b31bc-1268-4a1b-84e4-0c50834c379e	56572e8e-5fb3-440f-ba77-af00c6d3fa1f	2026-04-18	36	2	0
32526ded-33f7-411a-912e-b22577a2aa33	56572e8e-5fb3-440f-ba77-af00c6d3fa1f	2026-04-17	24	2	1
a8e0c6f1-39af-4a98-800b-b40e472328b9	56572e8e-5fb3-440f-ba77-af00c6d3fa1f	2026-04-16	40	2	2
d43083a3-1be1-49a4-b588-0f78ac936fdb	56572e8e-5fb3-440f-ba77-af00c6d3fa1f	2026-04-15	29	1	0
af70a6ba-ae6c-4066-928e-d958ef38aa25	56572e8e-5fb3-440f-ba77-af00c6d3fa1f	2026-04-14	38	2	1
73a0d998-823f-4fce-96ef-5c2a30793e12	56572e8e-5fb3-440f-ba77-af00c6d3fa1f	2026-04-13	28	0	1
cd62f9bf-30f6-416d-a49b-4c79d02e9b02	56572e8e-5fb3-440f-ba77-af00c6d3fa1f	2026-04-12	21	1	1
73e6da1f-9a02-47bc-be6f-413c901af8d5	56572e8e-5fb3-440f-ba77-af00c6d3fa1f	2026-04-11	35	0	1
553e1791-4699-42e8-bcfe-dd9639ac951f	56572e8e-5fb3-440f-ba77-af00c6d3fa1f	2026-04-10	33	1	0
5f717fa1-d6ea-4a6f-bcd0-ee6b209247d3	e48c5831-b619-4000-80a2-6e03aaa98c97	2026-05-09	28	2	2
cf4b4f97-34b8-4410-a9fb-59379f8d5dda	e48c5831-b619-4000-80a2-6e03aaa98c97	2026-05-08	33	2	1
09576551-d3e0-442f-82de-ffc1f1560dcb	e48c5831-b619-4000-80a2-6e03aaa98c97	2026-05-07	27	1	0
832816b6-fe1e-4a63-9a71-7ca53f16e4f4	e48c5831-b619-4000-80a2-6e03aaa98c97	2026-05-06	36	2	0
63904199-97f4-4a1f-a6bf-389d9f8c72a5	e48c5831-b619-4000-80a2-6e03aaa98c97	2026-05-05	40	2	1
09c7c410-e83f-412e-a881-3f14dcc13d5d	e48c5831-b619-4000-80a2-6e03aaa98c97	2026-05-04	33	1	2
a2631b87-9692-4d3d-bc7e-111bd7ee4b15	e48c5831-b619-4000-80a2-6e03aaa98c97	2026-05-03	22	2	1
5d470a05-d917-495d-bf88-cdced9a9e73e	e48c5831-b619-4000-80a2-6e03aaa98c97	2026-05-02	19	1	2
0b06ea92-e9c9-4414-9107-524c283cb084	e48c5831-b619-4000-80a2-6e03aaa98c97	2026-05-01	16	2	0
4ce4e099-cd2d-47e0-8a37-1f7b10cd447a	e48c5831-b619-4000-80a2-6e03aaa98c97	2026-04-30	19	0	1
1486059e-a311-45c8-88c2-6c0584761e27	e48c5831-b619-4000-80a2-6e03aaa98c97	2026-04-29	27	0	1
f0e729d2-6459-4b43-8300-284f017f2fca	e48c5831-b619-4000-80a2-6e03aaa98c97	2026-04-28	15	2	0
120e1c3e-c7cb-4a45-8b76-75b619033677	e48c5831-b619-4000-80a2-6e03aaa98c97	2026-04-27	27	1	1
0ce32289-7d56-4078-9aec-301c0f859c5c	e48c5831-b619-4000-80a2-6e03aaa98c97	2026-04-26	24	1	1
e92e3cd4-b723-4872-8588-bffac6f1986a	e48c5831-b619-4000-80a2-6e03aaa98c97	2026-04-25	26	0	1
048e81d3-3e88-43b0-a5c4-3fdd8966dbec	e48c5831-b619-4000-80a2-6e03aaa98c97	2026-04-24	14	2	2
af026709-37ad-4f5c-bd19-b78cc8601aec	e48c5831-b619-4000-80a2-6e03aaa98c97	2026-04-23	23	0	1
2f7a2086-aa03-4cc0-b105-b6649c58477a	e48c5831-b619-4000-80a2-6e03aaa98c97	2026-04-22	20	1	0
4b56755b-37bb-4b21-b1ce-05f315cdcea2	e48c5831-b619-4000-80a2-6e03aaa98c97	2026-04-21	25	2	1
021d9e4a-5a9c-4394-ab8a-04f46a4adfd6	e48c5831-b619-4000-80a2-6e03aaa98c97	2026-04-20	29	1	1
0fdaa19d-261f-4336-9ab0-fb7ea52fff7b	e48c5831-b619-4000-80a2-6e03aaa98c97	2026-04-19	25	2	2
135c6141-0719-4479-8146-3d3e416c1926	e48c5831-b619-4000-80a2-6e03aaa98c97	2026-04-18	25	2	2
237b6a04-8792-4ef7-bb44-14acdaf86207	e48c5831-b619-4000-80a2-6e03aaa98c97	2026-04-17	28	2	0
f79dccd2-6ab5-4929-86ff-b53bbbfa4e80	e48c5831-b619-4000-80a2-6e03aaa98c97	2026-04-16	18	2	2
dbbf8d9a-c784-4b69-8d67-3e9940139049	e48c5831-b619-4000-80a2-6e03aaa98c97	2026-04-15	25	2	1
2d3993bb-b0ec-41c8-af77-13f2177caa3e	e48c5831-b619-4000-80a2-6e03aaa98c97	2026-04-14	16	1	1
b1b3b4c6-d62c-4197-affc-4eaf8c9e6e34	e48c5831-b619-4000-80a2-6e03aaa98c97	2026-04-13	14	0	2
b91700c4-330e-48d7-9aa2-b4fd63d6fa9b	e48c5831-b619-4000-80a2-6e03aaa98c97	2026-04-12	19	2	0
1abd6a71-7e08-4f4c-96ac-071a4f7b7100	e48c5831-b619-4000-80a2-6e03aaa98c97	2026-04-11	16	0	2
5497207d-59f5-41e6-981d-98eb3505506c	e48c5831-b619-4000-80a2-6e03aaa98c97	2026-04-10	10	1	2
d3e55a4c-b763-43c2-924f-e171af30d6c4	d6b750c1-3b36-4e6b-9707-3731faab57b3	2026-05-09	30	2	1
ce52b3b4-82e4-41f8-8070-8b0f0cc69a0b	d6b750c1-3b36-4e6b-9707-3731faab57b3	2026-05-08	33	1	0
17054442-7138-4ea5-aca0-228676dece85	d6b750c1-3b36-4e6b-9707-3731faab57b3	2026-05-07	38	0	0
2a37fe09-9480-4ddd-b40a-892734a61f2e	d6b750c1-3b36-4e6b-9707-3731faab57b3	2026-05-06	27	2	1
0469fcb8-ff4c-4178-9956-36a49e69cf0f	d6b750c1-3b36-4e6b-9707-3731faab57b3	2026-05-05	41	2	0
7c00d1b7-9cc1-4ddc-a593-1a9e695c1b00	d6b750c1-3b36-4e6b-9707-3731faab57b3	2026-05-04	43	2	1
b69225b1-af3a-4479-bc6d-c14e350283ed	d6b750c1-3b36-4e6b-9707-3731faab57b3	2026-05-03	27	2	1
35becaaf-414e-4e58-ad96-4ed560620618	d6b750c1-3b36-4e6b-9707-3731faab57b3	2026-05-02	27	1	1
a165b457-fa8f-4d43-9877-e73ad7135c79	d6b750c1-3b36-4e6b-9707-3731faab57b3	2026-05-01	19	2	1
6932e158-b5dc-410e-8f5b-765b3c176c43	d6b750c1-3b36-4e6b-9707-3731faab57b3	2026-04-30	16	2	1
0d3b6733-76ad-4739-89c5-c765443d9e60	d6b750c1-3b36-4e6b-9707-3731faab57b3	2026-04-29	28	0	0
cf4dd94d-7300-42a0-a5ad-5844a6f6d3e3	d6b750c1-3b36-4e6b-9707-3731faab57b3	2026-04-28	23	1	1
c6fe54db-4636-433f-b907-54af85627987	d6b750c1-3b36-4e6b-9707-3731faab57b3	2026-04-27	20	2	0
cf938bb2-d038-440f-a7d3-a750c1c43b0b	d6b750c1-3b36-4e6b-9707-3731faab57b3	2026-04-26	27	0	0
a02aeec0-1a1b-4d31-a0d6-371e66466228	d6b750c1-3b36-4e6b-9707-3731faab57b3	2026-04-25	20	0	0
d7fac25c-3e9a-46e0-90a6-8a1836696336	d6b750c1-3b36-4e6b-9707-3731faab57b3	2026-04-24	34	1	1
dc6622e5-d4ca-4d9c-a216-b44fdf6d7056	d6b750c1-3b36-4e6b-9707-3731faab57b3	2026-04-23	21	2	0
a2fdadb5-cc3e-416a-8f3a-a680a1b31093	d6b750c1-3b36-4e6b-9707-3731faab57b3	2026-04-22	29	0	1
f90e7166-c199-4889-ba84-e13c84616d14	d6b750c1-3b36-4e6b-9707-3731faab57b3	2026-04-21	20	1	1
e1cc5ce5-9226-4227-9208-af082618d103	d6b750c1-3b36-4e6b-9707-3731faab57b3	2026-04-20	24	0	1
0d333892-0705-413a-aaa7-f7677dfd935a	d6b750c1-3b36-4e6b-9707-3731faab57b3	2026-04-19	30	0	1
815826d0-4678-41d8-b467-6434adefa2af	d6b750c1-3b36-4e6b-9707-3731faab57b3	2026-04-18	34	2	1
7755c39b-3190-4653-ba25-261cae9ffa5b	d6b750c1-3b36-4e6b-9707-3731faab57b3	2026-04-17	32	1	1
ce446d59-902c-436e-81cc-9ed267af21f7	d6b750c1-3b36-4e6b-9707-3731faab57b3	2026-04-16	19	1	0
bdecebd5-db36-46c1-8e7c-2787161daa51	d6b750c1-3b36-4e6b-9707-3731faab57b3	2026-04-15	16	1	0
1947b7db-c5b2-4371-8f57-dc1a9ea8add8	d6b750c1-3b36-4e6b-9707-3731faab57b3	2026-04-14	24	1	0
40619dcb-7154-4a80-9782-5fdd50d59856	d6b750c1-3b36-4e6b-9707-3731faab57b3	2026-04-13	31	2	1
795dbfef-93cb-4f16-8cca-145bb7a16c0a	d6b750c1-3b36-4e6b-9707-3731faab57b3	2026-04-12	33	2	1
fe8fd43c-e7e6-439a-88fd-1843238498f8	d6b750c1-3b36-4e6b-9707-3731faab57b3	2026-04-11	23	1	1
2129d793-7290-469c-bce5-c0608803c023	d6b750c1-3b36-4e6b-9707-3731faab57b3	2026-04-10	32	2	1
37778e93-5665-4067-985e-9f90ce8c439f	33504139-3147-4fc7-828d-08ef67bbf186	2026-05-09	37	0	0
7f0ce96c-19f4-4d94-85a8-af31e3b3139e	33504139-3147-4fc7-828d-08ef67bbf186	2026-05-08	30	2	1
1b0df316-94a8-40f9-b643-5875077e8d2c	33504139-3147-4fc7-828d-08ef67bbf186	2026-05-07	39	0	0
55b59144-87fa-4d08-a572-27782816632c	33504139-3147-4fc7-828d-08ef67bbf186	2026-05-06	25	0	0
c3231b99-23ae-47d2-9a6e-b1517c1c3ccd	33504139-3147-4fc7-828d-08ef67bbf186	2026-05-05	36	0	1
e0f9873c-e804-4b24-be3a-92ceb786a150	33504139-3147-4fc7-828d-08ef67bbf186	2026-05-04	42	1	0
6e32134a-a2b3-4087-accb-a44574201e63	33504139-3147-4fc7-828d-08ef67bbf186	2026-05-03	43	0	1
fd82f3af-c861-4d57-b49c-7ac25cc11e8a	33504139-3147-4fc7-828d-08ef67bbf186	2026-05-02	25	1	0
c63afe50-db77-40af-a808-73a04d19ccb4	33504139-3147-4fc7-828d-08ef67bbf186	2026-05-01	21	1	1
dea30067-0a9a-4207-b1a3-43d8cb968ad7	33504139-3147-4fc7-828d-08ef67bbf186	2026-04-30	33	2	1
73f86591-75d2-4b6c-ba87-a81c76e854ab	33504139-3147-4fc7-828d-08ef67bbf186	2026-04-29	33	1	0
588245c7-0622-46ed-bc8f-9076a65d3ffe	33504139-3147-4fc7-828d-08ef67bbf186	2026-04-28	27	2	1
52a63a66-c25b-4b6b-ade7-9d17302cec4f	33504139-3147-4fc7-828d-08ef67bbf186	2026-04-27	19	0	0
c03600f9-facc-40c6-a0e5-dd345399f6af	33504139-3147-4fc7-828d-08ef67bbf186	2026-04-26	26	0	1
61516fe5-27d0-44bb-87f9-2941dcdab93b	33504139-3147-4fc7-828d-08ef67bbf186	2026-04-25	27	2	1
37f1c998-b1ab-40f5-b49b-dac145f82a25	33504139-3147-4fc7-828d-08ef67bbf186	2026-04-24	20	2	1
ded709b5-ed59-4588-a20f-c753f6fa83b2	33504139-3147-4fc7-828d-08ef67bbf186	2026-04-23	24	1	1
9da2fdd7-bca1-42e9-bfc9-412e3f50e02e	33504139-3147-4fc7-828d-08ef67bbf186	2026-04-22	31	1	0
75a5f6d0-7ddf-4ad7-ae51-a992f7a2c69e	33504139-3147-4fc7-828d-08ef67bbf186	2026-04-21	30	0	1
374fb5c5-cd37-43c1-883f-90bcd342250c	33504139-3147-4fc7-828d-08ef67bbf186	2026-04-20	27	2	1
647fb0ad-793a-4560-b2c1-67872bcaefcc	33504139-3147-4fc7-828d-08ef67bbf186	2026-04-19	18	0	1
8d731aff-1276-4cb8-95f7-c5252523ec40	33504139-3147-4fc7-828d-08ef67bbf186	2026-04-18	33	2	1
ff20a28d-448b-41ee-a55d-13ef4c94278e	33504139-3147-4fc7-828d-08ef67bbf186	2026-04-17	25	1	1
40638a46-038a-48df-bc71-bb0d024d88aa	33504139-3147-4fc7-828d-08ef67bbf186	2026-04-16	27	0	1
1c43177e-8990-4204-a918-537d9110f805	33504139-3147-4fc7-828d-08ef67bbf186	2026-04-15	27	2	0
99200e7c-26ef-4276-96d0-79a74a2d3bed	33504139-3147-4fc7-828d-08ef67bbf186	2026-04-14	19	1	1
38130445-83bf-4e7c-b74a-68034032e03f	33504139-3147-4fc7-828d-08ef67bbf186	2026-04-13	29	2	1
6aedad05-0462-49f7-959f-2fafc4d908e7	33504139-3147-4fc7-828d-08ef67bbf186	2026-04-12	35	0	0
513fd914-fed4-4a36-99ac-d8ee10b7f489	33504139-3147-4fc7-828d-08ef67bbf186	2026-04-11	20	2	1
9ecfe15b-2a87-4375-887c-b5cd593f73ff	33504139-3147-4fc7-828d-08ef67bbf186	2026-04-10	30	0	0
9043e2ad-59c7-4c25-8c13-accade70653e	97dc8ee5-49ff-440b-89de-91e4fdb97d70	2026-05-09	43	2	2
4773d9a8-a1a7-4d9e-967e-c7157b13c9a6	97dc8ee5-49ff-440b-89de-91e4fdb97d70	2026-05-08	38	2	0
fd59a220-2631-44d2-9568-4d67e6a85f30	97dc8ee5-49ff-440b-89de-91e4fdb97d70	2026-05-07	41	1	2
12fcc906-ed36-4649-8a5c-29f4419b82aa	97dc8ee5-49ff-440b-89de-91e4fdb97d70	2026-05-06	43	2	1
b06b5845-9e86-4b7c-8aa0-84d18ac8a539	97dc8ee5-49ff-440b-89de-91e4fdb97d70	2026-05-05	41	2	1
f71d47ea-e7c0-4bd4-ac10-c3d87d033f22	97dc8ee5-49ff-440b-89de-91e4fdb97d70	2026-05-04	37	0	0
39e872ce-4c3a-48a3-8211-89c9ef7ca9cb	97dc8ee5-49ff-440b-89de-91e4fdb97d70	2026-05-03	41	1	1
9f81eba0-6c04-4c93-8bee-d22359c0994a	97dc8ee5-49ff-440b-89de-91e4fdb97d70	2026-05-02	19	2	0
8a0c052a-cd7a-44a1-827c-462e859ef0b2	97dc8ee5-49ff-440b-89de-91e4fdb97d70	2026-05-01	15	2	1
cbc9275a-3b83-4cbb-9b82-a132aef78e9f	97dc8ee5-49ff-440b-89de-91e4fdb97d70	2026-04-30	16	1	1
5c0c53f5-241e-4e1c-9e53-e6f12190d08d	97dc8ee5-49ff-440b-89de-91e4fdb97d70	2026-04-29	21	0	1
15f80ba4-6cff-4abd-85c4-cefe1e8e5d80	97dc8ee5-49ff-440b-89de-91e4fdb97d70	2026-04-28	17	0	2
41ab3f6f-b283-4125-9c71-1bc6223a7156	97dc8ee5-49ff-440b-89de-91e4fdb97d70	2026-04-27	30	0	0
8c9a0cf2-3385-4521-8a24-dd182015e95e	97dc8ee5-49ff-440b-89de-91e4fdb97d70	2026-04-26	20	1	1
10016811-5ec7-4a04-800c-1325979edfcb	97dc8ee5-49ff-440b-89de-91e4fdb97d70	2026-04-25	17	2	1
f2aaaf10-2e9a-42e1-8dda-f32118828546	97dc8ee5-49ff-440b-89de-91e4fdb97d70	2026-04-24	31	1	1
c7e7ca99-fd9d-4d08-8288-b8eea229a9cb	97dc8ee5-49ff-440b-89de-91e4fdb97d70	2026-04-23	16	2	0
1b2861db-15e1-49ee-9979-34a99d9bbb92	97dc8ee5-49ff-440b-89de-91e4fdb97d70	2026-04-22	27	2	0
944d76a2-7c1a-4fee-ab88-674ff0723fbe	97dc8ee5-49ff-440b-89de-91e4fdb97d70	2026-04-21	17	0	1
49a38420-84be-4bde-9010-453e97d80c40	97dc8ee5-49ff-440b-89de-91e4fdb97d70	2026-04-20	15	0	1
6c77bac1-b395-4b9a-850c-af8ee296a20f	97dc8ee5-49ff-440b-89de-91e4fdb97d70	2026-04-19	20	1	0
99743e09-b748-4eac-8e54-0858cde961a6	97dc8ee5-49ff-440b-89de-91e4fdb97d70	2026-04-18	23	2	1
f93bff13-fceb-4b63-8d5a-56ba7c56c8bb	97dc8ee5-49ff-440b-89de-91e4fdb97d70	2026-04-17	31	0	0
50b3efc5-1b0d-4ef8-ba28-a05c64ec4499	97dc8ee5-49ff-440b-89de-91e4fdb97d70	2026-04-16	35	1	0
287849b7-0534-4b7b-9178-404666deaad3	97dc8ee5-49ff-440b-89de-91e4fdb97d70	2026-04-15	20	1	1
7aa901e8-ee43-402f-94f0-9c002c5196af	97dc8ee5-49ff-440b-89de-91e4fdb97d70	2026-04-14	16	1	1
ee1f501c-3903-4fd7-9c7a-319d249fdbb0	97dc8ee5-49ff-440b-89de-91e4fdb97d70	2026-04-13	22	2	1
6cd92484-960a-4040-8489-f8c16836367f	97dc8ee5-49ff-440b-89de-91e4fdb97d70	2026-04-12	33	2	2
36f5296c-4875-48d0-b18b-5dd4a90ad8e8	97dc8ee5-49ff-440b-89de-91e4fdb97d70	2026-04-11	21	2	1
20cbbf22-61ed-4b74-bb7a-ed7ea760a417	97dc8ee5-49ff-440b-89de-91e4fdb97d70	2026-04-10	21	0	0
f2996f18-1580-415c-865a-7dad751603c9	af89edb0-1427-41f4-abea-036d209f318d	2026-05-09	30	2	2
15f702e1-c5cf-435e-aba6-7873b98f43bd	af89edb0-1427-41f4-abea-036d209f318d	2026-05-08	29	2	1
c89cf41e-903d-4894-8ee9-4b77f7f3d386	af89edb0-1427-41f4-abea-036d209f318d	2026-05-07	25	2	0
9e99c0ee-1575-49fc-9877-12fdfd9e731e	af89edb0-1427-41f4-abea-036d209f318d	2026-05-06	37	1	1
fcb6253d-8484-4d95-8faf-dd25dd5b6fe0	af89edb0-1427-41f4-abea-036d209f318d	2026-05-05	39	2	1
27f8d99f-e272-444f-9148-c1a2d5c5a512	af89edb0-1427-41f4-abea-036d209f318d	2026-05-04	36	0	1
b248e257-3f47-43c7-8206-40fbacab507f	af89edb0-1427-41f4-abea-036d209f318d	2026-05-03	23	1	1
f489c49a-1b82-42d7-b84d-f46594a873d7	af89edb0-1427-41f4-abea-036d209f318d	2026-05-02	26	1	1
66c0ed6b-056b-49ec-9bf1-7638a29cbd75	af89edb0-1427-41f4-abea-036d209f318d	2026-05-01	10	2	0
e8a96580-2fdd-4c7d-8795-4e4ac6b642d0	af89edb0-1427-41f4-abea-036d209f318d	2026-04-30	30	0	1
442e0db5-edec-448a-acd7-ac9038affce6	af89edb0-1427-41f4-abea-036d209f318d	2026-04-29	22	2	0
a9198872-762b-4194-8676-30d1f75fdeef	af89edb0-1427-41f4-abea-036d209f318d	2026-04-28	13	1	1
af848d3c-1c1c-4552-bfc5-99581613acc1	af89edb0-1427-41f4-abea-036d209f318d	2026-04-27	25	1	1
db770b97-da52-4997-90ef-566952534fbf	af89edb0-1427-41f4-abea-036d209f318d	2026-04-26	30	1	0
d895d129-2610-4cd6-a326-688d23dd668f	af89edb0-1427-41f4-abea-036d209f318d	2026-04-25	23	1	1
12c6fd80-336f-4624-aa4f-77db0632c189	af89edb0-1427-41f4-abea-036d209f318d	2026-04-24	20	0	0
733c1b3e-d7df-4250-9606-fb781dcb0c20	af89edb0-1427-41f4-abea-036d209f318d	2026-04-23	18	1	1
350152de-cc25-44dd-9525-1c6f82aff88c	af89edb0-1427-41f4-abea-036d209f318d	2026-04-22	11	2	2
f546f112-876e-4255-97b4-23c4ea7e2575	af89edb0-1427-41f4-abea-036d209f318d	2026-04-21	17	0	0
341b0151-653a-4bb1-90d8-5b0122b183eb	af89edb0-1427-41f4-abea-036d209f318d	2026-04-20	29	1	1
307610b0-28f5-4c50-8ea4-f8ddbed7712b	af89edb0-1427-41f4-abea-036d209f318d	2026-04-19	15	1	2
fa14130c-7ed6-499c-8aa2-31b5985df18e	af89edb0-1427-41f4-abea-036d209f318d	2026-04-18	15	2	2
cc3ba9d2-45d1-4d68-866b-49742017cc3f	af89edb0-1427-41f4-abea-036d209f318d	2026-04-17	18	0	1
6a4b52a5-992d-4a17-b424-e8c8a06b7565	af89edb0-1427-41f4-abea-036d209f318d	2026-04-16	19	1	1
54242096-9729-4858-b277-a8559de3c51f	af89edb0-1427-41f4-abea-036d209f318d	2026-04-15	16	0	2
92df6367-31e7-4484-9ff3-22cb1808f146	af89edb0-1427-41f4-abea-036d209f318d	2026-04-14	23	2	1
ed458294-b9c6-4851-b2a0-87d3799bf663	af89edb0-1427-41f4-abea-036d209f318d	2026-04-13	28	1	0
8face210-2ab8-47a9-a60f-576413e30972	af89edb0-1427-41f4-abea-036d209f318d	2026-04-12	27	0	0
87ad8e6d-0669-4203-b772-906d68a0ef48	af89edb0-1427-41f4-abea-036d209f318d	2026-04-11	28	2	0
f0449492-1b45-45e1-9aef-abcbc38dc9e1	af89edb0-1427-41f4-abea-036d209f318d	2026-04-10	24	0	0
8e4f8ed6-da52-459f-b86f-f0a13bb26e1f	28619579-63d6-462c-90a2-5f92edba9ef3	2026-05-09	48	1	1
3c67bbd8-6421-4d23-b2d1-711c07ac3e76	28619579-63d6-462c-90a2-5f92edba9ef3	2026-05-08	52	0	0
8de4c5cd-2279-4a8b-9279-5a92a43ec65a	28619579-63d6-462c-90a2-5f92edba9ef3	2026-05-07	59	2	0
31a98366-093b-48f8-a321-20434c1b34f1	28619579-63d6-462c-90a2-5f92edba9ef3	2026-05-06	49	2	0
d54eb4e4-b0de-4435-8d97-794d2c55ba7e	28619579-63d6-462c-90a2-5f92edba9ef3	2026-05-05	47	0	2
3de9e125-0aab-4397-b7db-2d8bf27eae7a	28619579-63d6-462c-90a2-5f92edba9ef3	2026-05-04	65	1	1
47dae05b-c904-4782-919d-d18833eab0a9	28619579-63d6-462c-90a2-5f92edba9ef3	2026-05-03	64	1	0
93587044-7927-4f25-be52-a3776c0d9b21	28619579-63d6-462c-90a2-5f92edba9ef3	2026-05-02	51	0	2
36c33971-b056-4f66-97ca-23b568864dae	28619579-63d6-462c-90a2-5f92edba9ef3	2026-05-01	48	0	2
7146831a-257c-4e7e-8d8d-0e1782bd4080	28619579-63d6-462c-90a2-5f92edba9ef3	2026-04-30	41	2	0
46496122-65df-4b7e-bf51-24ddba62ac92	28619579-63d6-462c-90a2-5f92edba9ef3	2026-04-29	46	2	1
13b1286a-bdd4-42f8-bd9e-c25e435ca821	28619579-63d6-462c-90a2-5f92edba9ef3	2026-04-28	54	1	0
fb1a68a0-9fb0-4c34-a8ba-1b83e3c4503e	28619579-63d6-462c-90a2-5f92edba9ef3	2026-04-27	50	0	1
1de64699-7c51-45b3-9cd3-314bea118864	28619579-63d6-462c-90a2-5f92edba9ef3	2026-04-26	52	0	2
0fbf7a9f-c186-42fe-897e-e083c360c3b0	28619579-63d6-462c-90a2-5f92edba9ef3	2026-04-25	40	0	1
fdf2813f-7463-4e16-9ff4-8d5bdafa2eb9	28619579-63d6-462c-90a2-5f92edba9ef3	2026-04-24	43	1	0
663dd180-22fa-4232-a000-3d03317b5359	28619579-63d6-462c-90a2-5f92edba9ef3	2026-04-23	44	2	1
63c58b0e-ec20-4599-ab6e-0425a67f62f0	28619579-63d6-462c-90a2-5f92edba9ef3	2026-04-22	47	0	0
c6a50713-5ee4-44d2-9c99-8c7b17add380	28619579-63d6-462c-90a2-5f92edba9ef3	2026-04-21	55	2	2
7432fae8-3bcb-4f20-95cd-99d82edabc1d	28619579-63d6-462c-90a2-5f92edba9ef3	2026-04-20	44	0	1
aac0f1cb-f2b4-4975-b277-9a03d7077421	28619579-63d6-462c-90a2-5f92edba9ef3	2026-04-19	45	2	2
6742eacb-f5da-445b-8a93-12725b462219	28619579-63d6-462c-90a2-5f92edba9ef3	2026-04-18	43	0	1
99037c8c-22da-4e9c-ba4d-5d371756ac4f	28619579-63d6-462c-90a2-5f92edba9ef3	2026-04-17	40	2	2
3477c351-a5a5-49ea-9a70-4eac9ffc039d	28619579-63d6-462c-90a2-5f92edba9ef3	2026-04-16	36	2	1
bd8d43b8-3af3-4421-9f79-11b96a140940	28619579-63d6-462c-90a2-5f92edba9ef3	2026-04-15	36	0	0
c233f2dd-a4d3-47b1-b9f1-9761489a1108	28619579-63d6-462c-90a2-5f92edba9ef3	2026-04-14	42	0	0
80a62196-6ae2-4d91-baa9-0427c2192b41	28619579-63d6-462c-90a2-5f92edba9ef3	2026-04-13	48	1	2
3a3feaf9-75c9-46e2-94aa-082a357b1ae0	28619579-63d6-462c-90a2-5f92edba9ef3	2026-04-12	41	1	0
d8147841-a74b-4add-893e-264eaf11134c	28619579-63d6-462c-90a2-5f92edba9ef3	2026-04-11	45	1	1
c847af27-5e33-434e-9bc2-f2ea660a9918	28619579-63d6-462c-90a2-5f92edba9ef3	2026-04-10	36	2	0
1bf13654-cfc9-4794-affb-1f81df1e52b8	a91ba2b6-ca6d-4010-b0da-818993e3e65b	2026-05-09	30	1	1
2c59aab9-6b40-4f3f-8538-a89aeb152ba3	a91ba2b6-ca6d-4010-b0da-818993e3e65b	2026-05-08	35	0	2
4485d5aa-2b77-44be-9324-5100581fc067	a91ba2b6-ca6d-4010-b0da-818993e3e65b	2026-05-07	29	1	1
5a822f39-e6c5-416f-bb31-78aeb4815909	a91ba2b6-ca6d-4010-b0da-818993e3e65b	2026-05-06	42	2	0
577b300e-c539-4fc6-8d13-1be97a1590f7	a91ba2b6-ca6d-4010-b0da-818993e3e65b	2026-05-05	35	1	0
f28cd013-c626-428f-aac7-8631702fbabe	a91ba2b6-ca6d-4010-b0da-818993e3e65b	2026-05-04	44	0	0
2e85906d-365e-472f-a188-ff34f9503020	a91ba2b6-ca6d-4010-b0da-818993e3e65b	2026-05-03	33	1	0
bdd3a030-18bc-4d06-8537-0c98bdef858f	a91ba2b6-ca6d-4010-b0da-818993e3e65b	2026-05-02	28	1	1
d2d252a8-5103-4df4-88cd-63375fabe942	a91ba2b6-ca6d-4010-b0da-818993e3e65b	2026-05-01	21	2	0
7f70f967-af81-400c-8474-2ab8a1ae4189	a91ba2b6-ca6d-4010-b0da-818993e3e65b	2026-04-30	24	0	1
da2367d3-4927-4a85-a31e-5cd1bdab4066	a91ba2b6-ca6d-4010-b0da-818993e3e65b	2026-04-29	17	2	1
5b2021e2-d946-498c-9ebf-e120c16d39df	a91ba2b6-ca6d-4010-b0da-818993e3e65b	2026-04-28	28	0	2
9d9a09c9-0214-4485-8cb7-96af7dd840a3	a91ba2b6-ca6d-4010-b0da-818993e3e65b	2026-04-27	32	1	0
3135b5cf-54d3-4482-9c67-c95ec5f4cb4e	a91ba2b6-ca6d-4010-b0da-818993e3e65b	2026-04-26	32	0	1
3d3c5773-6287-4e59-affc-3143ea5f5bba	a91ba2b6-ca6d-4010-b0da-818993e3e65b	2026-04-25	33	0	0
f15b3e69-6271-451a-854a-8d4f008c3a67	a91ba2b6-ca6d-4010-b0da-818993e3e65b	2026-04-24	17	2	0
fca4bb33-5312-4130-873d-5b9e459aad7a	a91ba2b6-ca6d-4010-b0da-818993e3e65b	2026-04-23	32	1	1
acc8c486-9597-405a-b2ba-fb4c33b82a53	a91ba2b6-ca6d-4010-b0da-818993e3e65b	2026-04-22	16	1	2
6c31bbde-59e6-4bc0-8ce1-7c42de85c216	a91ba2b6-ca6d-4010-b0da-818993e3e65b	2026-04-21	15	1	1
5cdca14e-50c5-46c3-9f00-d022b6de7c5e	a91ba2b6-ca6d-4010-b0da-818993e3e65b	2026-04-20	35	0	0
fce32678-f9f1-4f33-82e8-4653452f5ccf	a91ba2b6-ca6d-4010-b0da-818993e3e65b	2026-04-19	19	0	0
a9adc6fa-4e7e-47ec-8351-ea2c4e05b379	a91ba2b6-ca6d-4010-b0da-818993e3e65b	2026-04-18	35	0	0
11ed105d-efa8-4d5d-ba6c-9bf767ceb9cf	a91ba2b6-ca6d-4010-b0da-818993e3e65b	2026-04-17	27	1	1
fca71f85-eee9-4614-8f6b-d7310751290d	a91ba2b6-ca6d-4010-b0da-818993e3e65b	2026-04-16	32	1	0
f4143926-4fa5-4bae-a939-99bfdc8c28d3	a91ba2b6-ca6d-4010-b0da-818993e3e65b	2026-04-15	16	2	0
af7065a5-e00e-4452-b09d-317d555f3269	a91ba2b6-ca6d-4010-b0da-818993e3e65b	2026-04-14	25	0	1
9c102c9c-3ea0-4c0a-b372-b824f112d051	a91ba2b6-ca6d-4010-b0da-818993e3e65b	2026-04-13	16	1	2
319b86a8-4222-4e1d-ac6a-7368370aeaec	a91ba2b6-ca6d-4010-b0da-818993e3e65b	2026-04-12	30	0	1
5a0587ed-39a9-4640-bff8-0ae21a6b38ca	a91ba2b6-ca6d-4010-b0da-818993e3e65b	2026-04-11	25	0	0
aa1c6228-68f2-41a9-b4df-bc2af575f456	a91ba2b6-ca6d-4010-b0da-818993e3e65b	2026-04-10	27	2	0
bf1e6e88-5f2d-414c-bb11-4a3d2ea9188e	a80c9f1b-5c75-4d7d-878d-94afbf6e0ab0	2026-05-09	37	1	0
829f6745-493b-4c72-9b75-e9bdbfac1da0	a80c9f1b-5c75-4d7d-878d-94afbf6e0ab0	2026-05-08	35	0	0
a2802238-3851-4fad-8669-36b23d67f8f8	a80c9f1b-5c75-4d7d-878d-94afbf6e0ab0	2026-05-07	32	1	0
bc04507d-2fcf-44d7-86c5-93337f081ef3	a80c9f1b-5c75-4d7d-878d-94afbf6e0ab0	2026-05-06	43	1	0
698be0ab-0fd4-45ec-baeb-885c1a1166d8	a80c9f1b-5c75-4d7d-878d-94afbf6e0ab0	2026-05-05	44	1	0
826139ad-52fe-4059-b4a4-36349fb35320	a80c9f1b-5c75-4d7d-878d-94afbf6e0ab0	2026-05-04	42	1	1
11efc21d-4278-4e63-88ea-ce7a54b7d4e5	a80c9f1b-5c75-4d7d-878d-94afbf6e0ab0	2026-05-03	34	2	1
c4091b9d-75b5-41ff-9e9f-93333a5968ec	a80c9f1b-5c75-4d7d-878d-94afbf6e0ab0	2026-05-02	27	0	0
ea02209f-e255-4266-8cce-a4231802d1b0	a80c9f1b-5c75-4d7d-878d-94afbf6e0ab0	2026-05-01	18	1	0
d16ac96a-7aa2-4279-8516-c8596d01c779	a80c9f1b-5c75-4d7d-878d-94afbf6e0ab0	2026-04-30	32	2	1
b68d7cb7-fd09-463e-958d-c0f489cd8f90	a80c9f1b-5c75-4d7d-878d-94afbf6e0ab0	2026-04-29	19	2	1
079c871c-44f4-447e-87a3-5ddc21afc154	a80c9f1b-5c75-4d7d-878d-94afbf6e0ab0	2026-04-28	22	1	1
11ed6a21-c0ca-4ef1-a277-6928f5c1ea30	a80c9f1b-5c75-4d7d-878d-94afbf6e0ab0	2026-04-27	22	2	1
766be741-38a4-4e18-9665-397e3d90a301	a80c9f1b-5c75-4d7d-878d-94afbf6e0ab0	2026-04-26	30	2	0
2286dbd0-586d-415d-85b3-26ae673b916d	a80c9f1b-5c75-4d7d-878d-94afbf6e0ab0	2026-04-25	21	0	1
d7163cd5-671a-4b22-971b-39a8fced4050	a80c9f1b-5c75-4d7d-878d-94afbf6e0ab0	2026-04-24	19	2	1
8818bd65-5928-427f-a3b7-ea1df66ab140	a80c9f1b-5c75-4d7d-878d-94afbf6e0ab0	2026-04-23	31	0	0
79492507-5085-4349-a6fb-3467cd9ced19	a80c9f1b-5c75-4d7d-878d-94afbf6e0ab0	2026-04-22	21	1	2
8c3ae1f9-759b-4bcc-b4c0-b9809392ab6b	a80c9f1b-5c75-4d7d-878d-94afbf6e0ab0	2026-04-21	19	0	0
ed1ad1fd-14ef-49cc-a243-70d7b8f3f1ff	a80c9f1b-5c75-4d7d-878d-94afbf6e0ab0	2026-04-20	19	0	0
12069074-61ad-4911-a3da-bd05b7c1ad15	a80c9f1b-5c75-4d7d-878d-94afbf6e0ab0	2026-04-19	26	0	1
50788759-b518-42f2-b63f-a07f93e16c00	a80c9f1b-5c75-4d7d-878d-94afbf6e0ab0	2026-04-18	23	1	1
26ad142b-b6ed-444b-81ca-343c8e8d6db5	a80c9f1b-5c75-4d7d-878d-94afbf6e0ab0	2026-04-17	29	2	1
4c0970b4-4746-49b1-a2cd-9a41dc501533	a80c9f1b-5c75-4d7d-878d-94afbf6e0ab0	2026-04-16	28	2	1
033b4f1f-38c9-412b-b9bc-1ea4f6a45db7	a80c9f1b-5c75-4d7d-878d-94afbf6e0ab0	2026-04-15	22	2	1
f8e5d099-223c-4831-bef1-b123fff0be1b	a80c9f1b-5c75-4d7d-878d-94afbf6e0ab0	2026-04-14	32	1	1
da8d9a3a-a38c-48d3-9e9f-f988320dce02	a80c9f1b-5c75-4d7d-878d-94afbf6e0ab0	2026-04-13	21	0	0
e24c9697-efb6-4080-a741-fd67a859ce3e	a80c9f1b-5c75-4d7d-878d-94afbf6e0ab0	2026-04-12	25	2	0
97607f01-3ade-4f7f-88f4-cb2495384be2	a80c9f1b-5c75-4d7d-878d-94afbf6e0ab0	2026-04-11	21	1	1
598981f4-b51d-429c-9ce1-13c75e77d81a	a80c9f1b-5c75-4d7d-878d-94afbf6e0ab0	2026-04-10	26	2	0
baa50579-e41b-4107-9534-e00d827d32aa	6e4196b7-5f63-44b5-9f53-de594e2777c6	2026-05-09	30	2	1
65473f62-478b-4746-9c35-060f69e147fd	6e4196b7-5f63-44b5-9f53-de594e2777c6	2026-05-08	44	0	1
c67ed7de-1bfa-4c4b-8ee3-1278089d6cac	6e4196b7-5f63-44b5-9f53-de594e2777c6	2026-05-07	44	2	0
9117fd0c-b54f-438a-b547-4b49c1746075	6e4196b7-5f63-44b5-9f53-de594e2777c6	2026-05-06	37	0	1
8ab5dd91-e882-4eff-af07-5eecdcf0ac47	6e4196b7-5f63-44b5-9f53-de594e2777c6	2026-05-05	31	0	1
b64e0b3e-ba1e-4f60-8201-a05107c6d895	6e4196b7-5f63-44b5-9f53-de594e2777c6	2026-05-04	32	1	0
a3c68779-5e55-4437-9888-bcb24e8e6553	6e4196b7-5f63-44b5-9f53-de594e2777c6	2026-05-03	32	0	0
7e515ea9-4749-4872-8ec4-4312ac3b2e8d	6e4196b7-5f63-44b5-9f53-de594e2777c6	2026-05-02	23	2	1
c7941719-c097-4a5e-9f84-baac52ef589a	6e4196b7-5f63-44b5-9f53-de594e2777c6	2026-05-01	19	1	0
97a0bd2d-48d6-40da-a857-2b2f206e29b4	6e4196b7-5f63-44b5-9f53-de594e2777c6	2026-04-30	31	2	0
41cd7050-b098-4609-9b62-f76ff522abce	6e4196b7-5f63-44b5-9f53-de594e2777c6	2026-04-29	29	1	1
e3751f0a-b8ed-4a0e-85e0-e252320a906f	6e4196b7-5f63-44b5-9f53-de594e2777c6	2026-04-28	31	2	1
529b7ce0-1e15-4017-b000-bbe88f202c01	6e4196b7-5f63-44b5-9f53-de594e2777c6	2026-04-27	23	2	0
a9b3f713-97b7-4b80-91a2-e9655050ffd1	6e4196b7-5f63-44b5-9f53-de594e2777c6	2026-04-26	31	0	0
f86b1384-25a6-44cb-962a-dca8dae6c0eb	6e4196b7-5f63-44b5-9f53-de594e2777c6	2026-04-25	21	2	0
cd35bff1-9f70-4b95-9f09-52424de3920a	6e4196b7-5f63-44b5-9f53-de594e2777c6	2026-04-24	22	2	1
31b9a7b0-eee2-4961-b3c8-d99056add9ef	6e4196b7-5f63-44b5-9f53-de594e2777c6	2026-04-23	27	2	0
9d796096-10b9-49b8-8620-e99de28b0b03	6e4196b7-5f63-44b5-9f53-de594e2777c6	2026-04-22	29	0	1
0370abbc-a3b0-44ea-b2e6-0cbe9435dbec	6e4196b7-5f63-44b5-9f53-de594e2777c6	2026-04-21	21	0	1
78b67851-5f0e-40f2-aadd-26a2e3388b94	6e4196b7-5f63-44b5-9f53-de594e2777c6	2026-04-20	16	0	2
5a201e5a-b6ab-4148-a65a-2b1f1dc502a6	6e4196b7-5f63-44b5-9f53-de594e2777c6	2026-04-19	24	0	1
09955a3c-3eac-4bf2-8611-3c17600fd800	6e4196b7-5f63-44b5-9f53-de594e2777c6	2026-04-18	16	2	1
0b5558de-5604-4f62-aa0d-64e920a68b87	6e4196b7-5f63-44b5-9f53-de594e2777c6	2026-04-17	27	2	1
a8b2d3ed-4c2f-496b-a36c-678e456820ec	6e4196b7-5f63-44b5-9f53-de594e2777c6	2026-04-16	22	1	1
0dedf2ab-c5c1-407f-8c52-5d3b2bdf6fbb	6e4196b7-5f63-44b5-9f53-de594e2777c6	2026-04-15	20	0	1
0e26ad05-4879-42fd-b9b0-a876d29fe935	6e4196b7-5f63-44b5-9f53-de594e2777c6	2026-04-14	30	1	1
4042a227-5c86-4b5b-9b0a-8680320e016e	6e4196b7-5f63-44b5-9f53-de594e2777c6	2026-04-13	32	1	1
5eb982cf-692c-4321-aa70-be37dcd75cbc	6e4196b7-5f63-44b5-9f53-de594e2777c6	2026-04-12	22	2	0
a89308f3-33bd-481d-b47a-6e5eb26a0985	6e4196b7-5f63-44b5-9f53-de594e2777c6	2026-04-11	31	2	0
a1ec1627-663d-486b-ba51-50a1e52bdaa2	6e4196b7-5f63-44b5-9f53-de594e2777c6	2026-04-10	27	2	0
b7911709-d716-4bea-b619-6713764e43fa	2324d1f8-952e-4bcf-9893-a9e0a1ffe515	2026-05-09	42	0	2
c4e14cb8-fea4-4f8b-8e63-4ab5be4f1f48	2324d1f8-952e-4bcf-9893-a9e0a1ffe515	2026-05-08	47	0	1
eb60696a-3420-430c-83d1-0a81985da444	2324d1f8-952e-4bcf-9893-a9e0a1ffe515	2026-05-07	42	2	1
bdba8376-528f-4fb6-88c3-a60561d21ec6	2324d1f8-952e-4bcf-9893-a9e0a1ffe515	2026-05-06	37	2	1
22a00b1f-b24d-4cf9-b47e-fee4034fbe35	2324d1f8-952e-4bcf-9893-a9e0a1ffe515	2026-05-05	35	0	1
9266fa58-1133-45ec-b53d-309b8121a62b	2324d1f8-952e-4bcf-9893-a9e0a1ffe515	2026-05-04	49	2	0
70bea6f9-2176-4a40-92cf-65b70df10276	2324d1f8-952e-4bcf-9893-a9e0a1ffe515	2026-05-03	45	2	2
8d78e393-2ce8-4a62-82c3-0072ec0975b0	2324d1f8-952e-4bcf-9893-a9e0a1ffe515	2026-05-02	26	1	1
800082fe-6802-42a8-9d2c-fe56760d8c24	2324d1f8-952e-4bcf-9893-a9e0a1ffe515	2026-05-01	33	2	0
8c2e241d-e131-4aac-92d7-93b1b838a664	2324d1f8-952e-4bcf-9893-a9e0a1ffe515	2026-04-30	34	0	1
d0da7ac8-24f4-4569-ad89-9d2796201d6a	2324d1f8-952e-4bcf-9893-a9e0a1ffe515	2026-04-29	24	0	1
fc780d1d-bc1a-4ca8-8685-639b3a09b239	2324d1f8-952e-4bcf-9893-a9e0a1ffe515	2026-04-28	33	2	1
256746dd-6772-47b4-b2bc-d65237922833	2324d1f8-952e-4bcf-9893-a9e0a1ffe515	2026-04-27	29	0	2
ae90df59-08bf-41f5-b76f-2775cac9e9d1	2324d1f8-952e-4bcf-9893-a9e0a1ffe515	2026-04-26	30	0	1
ee97be49-f789-44d2-9b68-4ddb162cc372	2324d1f8-952e-4bcf-9893-a9e0a1ffe515	2026-04-25	36	0	2
f22bd8eb-1018-4473-82b4-752b0ae3ea66	2324d1f8-952e-4bcf-9893-a9e0a1ffe515	2026-04-24	33	2	1
89542d99-a5af-4d52-8641-351b031e6874	2324d1f8-952e-4bcf-9893-a9e0a1ffe515	2026-04-23	36	1	1
aee41d10-ad37-4e94-80df-13c2acb853f3	2324d1f8-952e-4bcf-9893-a9e0a1ffe515	2026-04-22	39	0	1
637b9b5d-ef5a-4e50-8f9d-5416facef6e5	2324d1f8-952e-4bcf-9893-a9e0a1ffe515	2026-04-21	29	2	0
59ee83c6-61e0-4bad-8b0f-963f9f8f4c90	2324d1f8-952e-4bcf-9893-a9e0a1ffe515	2026-04-20	24	2	1
33be0518-cc8d-4f5c-bd25-720525f0130b	2324d1f8-952e-4bcf-9893-a9e0a1ffe515	2026-04-19	22	1	1
752c7af0-92b1-4aa5-97f2-0b8018fa9818	2324d1f8-952e-4bcf-9893-a9e0a1ffe515	2026-04-18	24	2	1
f713e09d-f3d8-4567-b3e2-d76009734444	2324d1f8-952e-4bcf-9893-a9e0a1ffe515	2026-04-17	22	0	2
cf33781c-6e3a-477f-ba15-0092c46afd15	2324d1f8-952e-4bcf-9893-a9e0a1ffe515	2026-04-16	35	1	0
bb6ae8e6-4618-4948-9e28-a5f0fb007a99	2324d1f8-952e-4bcf-9893-a9e0a1ffe515	2026-04-15	28	0	1
7a6f501b-ea06-4d16-961e-0b2e2f2c3091	2324d1f8-952e-4bcf-9893-a9e0a1ffe515	2026-04-14	22	0	0
394d1c87-6840-427f-9602-e54f9163e078	2324d1f8-952e-4bcf-9893-a9e0a1ffe515	2026-04-13	26	2	0
e75f19bd-b39f-4cfc-86b9-3ed58ff1b7bc	2324d1f8-952e-4bcf-9893-a9e0a1ffe515	2026-04-12	23	0	0
9bdc0afd-da12-43cd-baa7-56a185911b1f	2324d1f8-952e-4bcf-9893-a9e0a1ffe515	2026-04-11	36	1	2
0708cc8d-8295-4407-b6e4-1e26bac6ad5c	2324d1f8-952e-4bcf-9893-a9e0a1ffe515	2026-04-10	28	1	0
9a187ee3-ae5d-42d4-b1d7-3e9990ddbc69	2324d1f8-952e-4bcf-9893-a9e0a1ffe515	2026-09-17	1	0	0
728d1e25-0b8a-41b4-863e-4716ec8ca957	6e4196b7-5f63-44b5-9f53-de594e2777c6	2026-09-21	2	0	0
3c75ecc6-e074-4565-b136-9d596f80b431	28619579-63d6-462c-90a2-5f92edba9ef3	2026-09-21	2	0	0
475adc48-8f67-4bc9-8d5c-fac695e6ff91	33504139-3147-4fc7-828d-08ef67bbf186	2026-09-21	4	0	0
00329b6f-6767-45f9-a157-6a51b809d07a	a80c9f1b-5c75-4d7d-878d-94afbf6e0ab0	2026-09-21	2	0	0
733d524e-0214-4845-9122-f79b0a1d78d3	d6b750c1-3b36-4e6b-9707-3731faab57b3	2026-09-21	3	0	0
9e2dc422-bf72-402b-85ca-1eaa5e2db40e	c675e64e-80e2-4c5d-8190-c9d6fda1da2d	2026-09-21	2	0	0
fe75cc34-38af-40d7-90a9-7920f6bbb3df	28619579-63d6-462c-90a2-5f92edba9ef3	2026-09-22	2	0	0
20eb40f1-27b4-474a-8fba-e5c7663a4ce8	d6b750c1-3b36-4e6b-9707-3731faab57b3	2026-09-22	2	0	0
\.


--
-- Data for Name: listing_images; Type: TABLE DATA; Schema: public; Owner: automarket
--

COPY public.listing_images (id, listing_id, storage_key, url, display_order, created_at) FROM stdin;
94a3208e-6452-4774-9b80-abe2f67f0e0d	e34bc7f3-2c05-4501-a0a2-8485e2b2f6ae	seed/bmw-320d-1.jpg	https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800	0	2026-05-09 09:26:25.972172+00
aef41a7c-4b70-42d3-912f-bcafb40a1790	e34bc7f3-2c05-4501-a0a2-8485e2b2f6ae	seed/bmw-320d-2.jpg	https://images.unsplash.com/photo-1520050206757-275d0e4e3cec?w=800	1	2026-05-09 09:26:25.972172+00
8f12eed0-d38b-42de-be4b-f6e2070ffdd3	e34bc7f3-2c05-4501-a0a2-8485e2b2f6ae	seed/bmw-320d-3.jpg	https://images.unsplash.com/photo-1507136566006-cfc505b114fc?w=800	2	2026-05-09 09:26:25.972172+00
a15cbbf4-643f-4038-9754-22a89dbeeb0b	c809a9af-3a5b-49aa-a416-ba7f9666b0fd	seed/golf-1.jpg	https://images.unsplash.com/photo-1619405399517-d7fce0f13302?w=800	0	2026-05-09 09:26:25.972172+00
b0c45edb-d62a-42c3-ad0b-e49e35cc4557	c809a9af-3a5b-49aa-a416-ba7f9666b0fd	seed/golf-2.jpg	https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800	1	2026-05-09 09:26:25.972172+00
19f2c1f4-f7bd-4b71-95b7-b64d72ac2fd7	3a35b1fd-a6b1-4891-bb7e-da394a9dec6b	seed/merc-1.jpg	https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=800	0	2026-05-09 09:26:25.972172+00
4ced4bbb-5bd3-4a4d-9eef-62c4b2133b23	3a35b1fd-a6b1-4891-bb7e-da394a9dec6b	seed/merc-2.jpg	https://images.unsplash.com/photo-1609521263047-f8f205293f24?w=800	1	2026-05-09 09:26:25.972172+00
d0502a46-ba29-465d-977e-e95a10dcf471	3a35b1fd-a6b1-4891-bb7e-da394a9dec6b	seed/merc-3.jpg	https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=800	2	2026-05-09 09:26:25.972172+00
0f600cc3-6524-4958-92a7-b728c654a585	94336ae8-266f-4a34-a56f-c025c093fac9	seed/rav4-1.jpg	https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=800	0	2026-05-09 09:26:25.972172+00
e9286a97-30f5-4941-b57b-aeff3391b5aa	94336ae8-266f-4a34-a56f-c025c093fac9	seed/rav4-2.jpg	https://images.unsplash.com/photo-1625231334401-5b5411724ab9?w=800	1	2026-05-09 09:26:25.972172+00
dfa0b440-f4e5-4bf6-8b92-9ef213d6e3f3	c675e64e-80e2-4c5d-8190-c9d6fda1da2d	seed/audi-1.jpg	https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?w=800	0	2026-05-09 09:26:25.972172+00
0cee9fc8-0fc4-4a18-a01a-f3918732fa7a	c675e64e-80e2-4c5d-8190-c9d6fda1da2d	seed/audi-2.jpg	https://images.unsplash.com/photo-1603584173870-7f23fdae1b7a?w=800	1	2026-05-09 09:26:25.972172+00
23757df4-1daf-4882-87d6-90495b8537cd	194361d9-248a-4326-a562-9bc80edf87b0	seed/octavia-1.jpg	https://images.unsplash.com/photo-1549399542-7e3f8b79c341?w=800	0	2026-05-09 09:26:25.972172+00
9419b09f-1656-4c5d-af48-709aa7c03c46	194361d9-248a-4326-a562-9bc80edf87b0	seed/octavia-2.jpg	https://images.unsplash.com/photo-1502877338535-766e1452684a?w=800	1	2026-05-09 09:26:25.972172+00
c62f1275-6ac5-44b3-ace6-b273dc5a894c	28619579-63d6-462c-90a2-5f92edba9ef3	seed/tesla-1.jpg	https://images.unsplash.com/photo-1560958089-b8a1929cea89?w=800	0	2026-05-09 09:26:25.972172+00
4897082e-3af8-4e9c-96a4-eb5c43e22f5d	28619579-63d6-462c-90a2-5f92edba9ef3	seed/tesla-2.jpg	https://images.unsplash.com/photo-1536700503339-1e4b06520771?w=800	1	2026-05-09 09:26:25.972172+00
e3dff8b4-04ff-4599-91f9-51110ce91c8c	28619579-63d6-462c-90a2-5f92edba9ef3	seed/tesla-3.jpg	https://images.unsplash.com/photo-1554744512-d6c603f27c54?w=800	2	2026-05-09 09:26:25.972172+00
b309a416-cad4-4193-af32-8aaf4ea8d33e	83c23c7b-9dcd-486d-bf37-61aea2b92f14	seed/corsa-1.jpg	https://images.unsplash.com/photo-1609521263047-f8f205293f24?w=800	0	2026-05-09 09:26:25.972172+00
df001cc0-c9a2-4f7d-89d3-c4abda9d8bdc	1d6b2ebc-c39b-46e5-b3cd-5cfdac2213c7	seed/ranger-1.jpg	https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=800	0	2026-05-09 09:26:25.972172+00
637f8ea3-7f10-4734-92b0-03f4f8e8a5f6	1d6b2ebc-c39b-46e5-b3cd-5cfdac2213c7	seed/ranger-2.jpg	https://images.unsplash.com/photo-1544636331-e26879cd4d9b?w=800	1	2026-05-09 09:26:25.972172+00
a3495fbc-6ff8-48af-9d3b-3001e74ac051	2324d1f8-952e-4bcf-9893-a9e0a1ffe515	seed/sandero-1.jpg	https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?w=800	0	2026-05-09 09:26:25.972172+00
e4f579c1-19fb-478c-ac75-643982e077ae	2324d1f8-952e-4bcf-9893-a9e0a1ffe515	seed/sandero-2.jpg	https://images.unsplash.com/photo-1494976388531-d1058494ceb8?w=800	1	2026-05-09 09:26:25.972172+00
4486b834-0e45-4e9b-a05e-2dce401bdb2c	07b5061a-9441-4c07-9628-aa49767f8451	seed/cayenne-1.jpg	https://images.unsplash.com/photo-1503736334956-4c8f8e92946d?w=800	0	2026-05-09 09:26:25.972172+00
80e6709f-439a-44b5-a63d-f8e9262620c5	07b5061a-9441-4c07-9628-aa49767f8451	seed/cayenne-2.jpg	https://images.unsplash.com/photo-1614162692292-7ac56d7f373e?w=800	1	2026-05-09 09:26:25.972172+00
247ffd4f-fa30-4185-8eda-57311fa7dc9e	07b5061a-9441-4c07-9628-aa49767f8451	seed/cayenne-3.jpg	https://images.unsplash.com/photo-1580274455191-1c62238fa333?w=800	2	2026-05-09 09:26:25.972172+00
b4863447-2052-4493-ae94-f47b7e2dd704	56572e8e-5fb3-440f-ba77-af00c6d3fa1f	seed/clio-1.jpg	https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=800	0	2026-05-09 09:26:25.972172+00
465051b7-6639-4d7d-96ca-88c00dfc6482	56572e8e-5fb3-440f-ba77-af00c6d3fa1f	seed/clio-2.jpg	https://images.unsplash.com/photo-1583267746897-2cf415887172?w=800	1	2026-05-09 09:26:25.972172+00
7bb9a5f5-9b14-4a64-ab08-f563cfef20ab	a91ba2b6-ca6d-4010-b0da-818993e3e65b	seed/tucson-1.jpg	https://images.unsplash.com/photo-1611016186353-652a19d4e502?w=800	0	2026-05-09 09:26:25.972172+00
c7b397e2-16b8-4c39-9894-e998052d38b4	a91ba2b6-ca6d-4010-b0da-818993e3e65b	seed/tucson-2.jpg	https://images.unsplash.com/photo-1619682817481-e994891cd1f5?w=800	1	2026-05-09 09:26:25.972172+00
cadefaa4-7d79-4f71-9c31-5524a0763ad0	a80c9f1b-5c75-4d7d-878d-94afbf6e0ab0	seed/fiat500-1.jpg	https://images.unsplash.com/photo-1595787142240-aedb81e0e090?w=800	0	2026-05-09 09:26:25.972172+00
8e51af20-cd04-4439-8267-ef33335593d6	a80c9f1b-5c75-4d7d-878d-94afbf6e0ab0	seed/fiat500-2.jpg	https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=800	1	2026-05-09 09:26:25.972172+00
b00e4a88-8fc8-4928-b850-4229b8ba913a	e48c5831-b619-4000-80a2-6e03aaa98c97	seed/xc60-1.jpg	https://images.unsplash.com/photo-1606016159991-dfe4f2746ad5?w=800	0	2026-05-09 09:26:25.972172+00
23155c0b-8dc2-4397-bd71-281185b313b6	e48c5831-b619-4000-80a2-6e03aaa98c97	seed/xc60-2.jpg	https://images.unsplash.com/photo-1606016159991-dfe4f2746ad5?w=800	1	2026-05-09 09:26:25.972172+00
b5647a21-825d-49db-b14b-5f158f813615	8be5f9cd-9806-454d-94a4-8e795d93054c	seed/3008-1.jpg	https://images.unsplash.com/photo-1542362567-b07e54358753?w=800	0	2026-05-09 09:26:25.972172+00
fd90c931-aaa1-49d6-82ca-1ce76ef7a449	8be5f9cd-9806-454d-94a4-8e795d93054c	seed/3008-2.jpg	https://images.unsplash.com/photo-1494905998402-395d579af36f?w=800	1	2026-05-09 09:26:25.972172+00
c99deef5-ec69-4b04-a10e-d2eb03178d8f	6e4196b7-5f63-44b5-9f53-de594e2777c6	seed/sportage-1.jpg	https://images.unsplash.com/photo-1605559424843-9e4c228bf1c2?w=800	0	2026-05-09 09:26:25.972172+00
62321bde-c2d7-4bb0-9902-2bb915f36bd4	6e4196b7-5f63-44b5-9f53-de594e2777c6	seed/sportage-2.jpg	https://images.unsplash.com/photo-1550355291-bbee04a92027?w=800	1	2026-05-09 09:26:25.972172+00
84057e14-1bcb-40e1-98d8-9ecc75621846	d6b750c1-3b36-4e6b-9707-3731faab57b3	seed/leon-1.jpg	https://images.unsplash.com/photo-1570356528233-b442cf2de345?w=800	0	2026-05-09 09:26:25.972172+00
b408b5f6-dd37-4b70-a33e-7babb65b7c50	d6b750c1-3b36-4e6b-9707-3731faab57b3	seed/leon-2.jpg	https://images.unsplash.com/photo-1489824904134-891ab64532f1?w=800	1	2026-05-09 09:26:25.972172+00
432758e1-eac2-4394-8c9f-e5c945bab91a	33504139-3147-4fc7-828d-08ef67bbf186	seed/qashqai-1.jpg	https://images.unsplash.com/photo-1609521263047-f8f205293f24?w=800	0	2026-05-09 09:26:25.972172+00
7284df17-5a52-4e13-87c4-47b0b7dbe0da	33504139-3147-4fc7-828d-08ef67bbf186	seed/qashqai-2.jpg	https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=800	1	2026-05-09 09:26:25.972172+00
a23e7cdc-136d-4d14-be4c-84b29b5f5fc4	9f36339c-9535-41b0-8c96-74c747bee0f4	seed/cx5-1.jpg	https://images.unsplash.com/photo-1616422285623-13ff0162193c?w=800	0	2026-05-09 09:26:25.972172+00
1be4a38a-cc49-4d3c-ae04-d1c98edc55b1	9f36339c-9535-41b0-8c96-74c747bee0f4	seed/cx5-2.jpg	https://images.unsplash.com/photo-1583121274602-3e2820c69888?w=800	1	2026-05-09 09:26:25.972172+00
0f4f0a0e-943a-41cb-a561-a279fb3ab20d	eaee3c3f-1c28-4401-9e33-cb5900ad7179	seed/civic-1.jpg	https://images.unsplash.com/photo-1590362891991-f776e747a588?w=800	0	2026-05-09 09:26:25.972172+00
cc26751d-b0d9-4ecd-afd9-204769e114e5	3aa34d57-aac7-4d3c-a64b-34f5bfbd4c25	seed/giulia-1.jpg	https://images.unsplash.com/photo-1573950940509-d924ee3fd345?w=800	0	2026-05-09 09:26:25.972172+00
2edcf0b8-523c-4210-a203-8f9a73a33c99	3aa34d57-aac7-4d3c-a64b-34f5bfbd4c25	seed/giulia-2.jpg	https://images.unsplash.com/photo-1547744152-14d985cb937f?w=800	1	2026-05-09 09:26:25.972172+00
e0a14a2b-5a56-437b-9648-cf7f6cf9a98e	97dc8ee5-49ff-440b-89de-91e4fdb97d70	seed/mini-1.jpg	https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=800	0	2026-05-09 09:26:25.972172+00
fd2a0cfa-4b7b-48f6-b922-5a59993c8233	97dc8ee5-49ff-440b-89de-91e4fdb97d70	seed/mini-2.jpg	https://images.unsplash.com/photo-1617531653332-bd46c24f2068?w=800	1	2026-05-09 09:26:25.972172+00
b5df70ae-c265-44dd-94e9-bdbf588b4615	af89edb0-1427-41f4-abea-036d209f318d	seed/disco-1.jpg	https://images.unsplash.com/photo-1519245659620-e859806a8d7b?w=800	0	2026-05-09 09:26:25.972172+00
7df4dc63-7765-4c9d-aa47-93159e0c7085	af89edb0-1427-41f4-abea-036d209f318d	seed/disco-2.jpg	https://images.unsplash.com/photo-1606016159991-dfe4f2746ad5?w=800	1	2026-05-09 09:26:25.972172+00
abc34006-21fc-4010-9ce5-653a36a9eac4	452110da-c7c3-4812-88fc-98df81c9100a	seed/jimny-1.jpg	https://images.unsplash.com/photo-1559416523-140ddc3d238c?w=800	0	2026-05-09 09:26:25.972172+00
8110fc61-c89d-4bea-8f6e-43f52407ece9	15a1a9b0-b89a-4608-aac8-43281faa1158	listings/15a1a9b0-b89a-4608-aac8-43281faa1158/2e8ecbf2-85a4-424a-9bc6-74f3c8308990.png	http://localhost:8080/uploads/listings/15a1a9b0-b89a-4608-aac8-43281faa1158/2e8ecbf2-85a4-424a-9bc6-74f3c8308990.png	0	2026-05-18 21:41:59.615642+00
d24d23f5-18f1-4dea-b7e3-2ffcba0a3bb4	15a1a9b0-b89a-4608-aac8-43281faa1158	listings/15a1a9b0-b89a-4608-aac8-43281faa1158/1acbd759-2089-47be-ae5c-a6f0a7412688.png	http://localhost:8080/uploads/listings/15a1a9b0-b89a-4608-aac8-43281faa1158/1acbd759-2089-47be-ae5c-a6f0a7412688.png	1	2026-05-18 21:41:59.694344+00
4e52ccaa-5b1d-4102-8d68-3cea433eacf7	15a1a9b0-b89a-4608-aac8-43281faa1158	listings/15a1a9b0-b89a-4608-aac8-43281faa1158/2c8977c0-a8a3-40c8-9c4d-182b02852786.png	http://localhost:8080/uploads/listings/15a1a9b0-b89a-4608-aac8-43281faa1158/2c8977c0-a8a3-40c8-9c4d-182b02852786.png	2	2026-05-18 21:41:59.764208+00
\.


--
-- Data for Name: listing_user_view; Type: TABLE DATA; Schema: public; Owner: automarket
--

COPY public.listing_user_view (id, email, name, phone, city_name, plan, created_at, deleted_at) FROM stdin;
b487c11a-1041-49b4-a94f-b41fab5bb7bb	admin@automarket.mk	Admin User	+389 70 000 002	Skopje	FREE	2026-05-09 09:26:25.899871+00	\N
7204b7eb-a53b-4d49-8e7e-d8bb4f3bea8a	superadmin@automarket.mk	Super Admin	+389 70 000 001	Skopje	FREE	2026-05-09 09:26:25.899871+00	\N
923a0bc7-5008-4228-aaee-01126af673f0	marko.petrovski@gmail.com	Marko Petrovski	+389 71 234 567	Skopje	FREE	2026-03-25 09:26:25.972172+00	\N
4de9f430-653d-44b4-9993-ab276dddf190	kostoskidaniel13@gmail.com	Daniel Kostoski	+38978896322	Bitola	FREE	2026-09-17 22:59:30.926133+00	\N
1231c400-0c5d-445d-8fd4-cfd562e46bf5	moderator@automarket.mk	Moderator User	+389 70 000 003	Bitola	FREE	2026-05-09 09:26:25.899871+00	\N
85538ad0-0bc5-4539-8e9d-158cec1003b7	ana.stojanova@yahoo.com	Ana Stojanova	+389 72 345 678	Bitola	PREMIUM	2026-04-01 09:26:25.972172+00	\N
740483d6-9239-470c-a813-31cfed5182a6	igor.nikolov@hotmail.com	Igor Nikolov	+389 70 456 789	Kumanovo	FREE	2026-04-09 09:26:25.972172+00	\N
0f3f2825-d73c-4d57-8d52-ff5072c3fdf6	stefan.trajkov@gmail.com	Stefan Trajkov	+389 76 678 901	Prilep	PREMIUM	2026-04-17 09:26:25.972172+00	\N
3fb5443b-e25b-43e5-a677-0cd7b6c77f62	premium@automarket.mk	Premium User	+389 70 000 005	Tetovo	PREMIUM	2026-05-09 09:26:25.899871+00	\N
d4269afa-baac-4de1-8a0d-f8a186bff526	maja.kostadinova@gmail.com	Maja Kostadinova	+389 77 789 012	Tetovo	FREE	2026-04-21 09:26:25.972172+00	\N
292e621c-f44a-49e8-a92a-6455ea65629e	aleksandar.ristov@gmail.com	Aleksandar Ristov	+389 78 890 123	Veles	FREE	2026-04-24 09:26:25.972172+00	\N
d81ec3ca-9c3c-4354-9386-3f7d8a91efe4	dejan.milosevski@gmail.com	Dejan Milosevski	+389 72 234 567	Štip	FREE	2026-05-06 09:26:25.972172+00	\N
8d11d611-807e-408b-ba9b-fc6eb4b84b86	user@automarket.mk	Regular User	+389 70 000 004	Ohrid	FREE	2026-05-09 09:26:25.899871+00	\N
75d8dafb-2d53-48e6-97ea-483d7534c0a0	elena.dimova@gmail.com	Elena Dimova	+389 75 567 890	Ohrid	FREE	2026-04-14 09:26:25.972172+00	\N
b1ba0660-e3df-4b8c-b2a9-4414d104189e	nikola.andonov@gmail.com	Nikola Andonov	+389 70 012 345	Gostivar	FREE	2026-05-01 09:26:25.972172+00	\N
2fccfa32-7dee-4274-90a6-2294531c0710	ivana.georgievska@gmail.com	Ivana Georgievska	+389 79 901 234	Strumica	FREE	2026-04-27 09:26:25.972172+00	\N
b18ee252-3735-4afb-9f52-804477425db6	tamara.mitrevska@gmail.com	Tamara Mitrevska	+389 71 123 456	Kavadarci	FREE	2026-05-04 09:26:25.972172+00	\N
c87953f6-a443-4fb7-9c6c-788ccefc95ca	kristina.ilievska@gmail.com	Kristina Ilievska	+389 73 345 678	Kočani	FREE	2026-05-08 09:26:25.972172+00	\N
53598466-cec5-4763-a545-109c21d7fc9f	kostoskidaniel14@gmail.com	Daniel Kostoski	+38978896322	\N	FREE	2026-09-22 16:58:40.246624+00	\N
\.


--
-- Data for Name: listings; Type: TABLE DATA; Schema: public; Owner: automarket
--

COPY public.listings (id, title, slug, description, price, condition_type_id, approved, featured, featured_until, seller_id, car_brand_id, car_model, registration_year, kilometers, fuel_type_id, body_type_id, transmission_type_id, num_doors, num_seats, kilowatts, attributes, created_at, updated_at, created_by, deleted_at, search_vector) FROM stdin;
e34bc7f3-2c05-4501-a0a2-8485e2b2f6ae	BMW 320d M Sport 2021	bmw-320d-m-sport-2021	Excellent condition BMW 320d with M Sport package. Full service history, one owner. LED headlights, navigation, heated seats, parking sensors. Recently serviced with new brake pads and tires. Non-smoker vehicle, always garaged.	28500.00	4c5a38fd-b5a4-4c24-885a-f9e1c9b3dc7a	t	t	2026-06-08 09:26:25.972172+00	3fb5443b-e25b-43e5-a677-0cd7b6c77f62	f9d1f607-79e0-43ab-b7e7-572de70378ce	320d M Sport	2021	45000	adf641a5-9326-431b-9a3f-6189f29da1b3	5bba7a9c-deaa-43c0-8764-21cf79df49ea	d73a5f86-d91e-4757-baba-613ad7a4b687	4	5	140	{}	2026-04-27 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	premium@automarket.mk	\N	'2021':5 '320d':2,9,40 'alway':38 'bmw':1,8 'brake':30 'condit':7 'excel':6 'full':14 'garag':39 'headlight':20 'heat':22 'histori':16 'led':19 'm':3,11,41 'navig':21 'new':29 'non':35 'non-smok':34 'one':17 'owner':18 'packag':13 'pad':31 'park':24 'recent':26 'seat':23 'sensor':25 'servic':15,27 'smoker':36 'sport':4,12,42 'tire':33 'vehicl':37
c809a9af-3a5b-49aa-a416-ba7f9666b0fd	Volkswagen Golf 8 1.5 TSI	volkswagen-golf-8-1-5-tsi	Well-maintained Golf 8 with low mileage. Features include adaptive cruise control, digital cockpit, Apple CarPlay/Android Auto, and lane assist. Non-smoker, garage kept. Perfect condition, no scratches.	22000.00	4c5a38fd-b5a4-4c24-885a-f9e1c9b3dc7a	t	f	\N	8d11d611-807e-408b-ba9b-fc6eb4b84b86	0ea35b4e-0c92-4451-8cd5-a13267005c2c	Golf 8 1.5 TSI	2022	32000	fa54edc7-e3ea-40fc-853e-7b176eef8801	f0c38b3b-be37-4d6e-98bb-13cdcc67e27c	21d2727a-e827-4451-8cdf-967620bbbf07	4	5	110	{}	2026-04-19 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	user@automarket.mk	\N	'1.5':4,38 '8':3,10,37 'adapt':16 'appl':21 'assist':26 'auto':23 'carplay/android':22 'cockpit':20 'condit':33 'control':18 'cruis':17 'digit':19 'featur':14 'garag':30 'golf':2,9,36 'includ':15 'kept':31 'lane':25 'low':12 'maintain':8 'mileag':13 'non':28 'non-smok':27 'perfect':32 'scratch':35 'smoker':29 'tsi':5,39 'volkswagen':1 'well':7 'well-maintain':6
3a35b1fd-a6b1-4891-bb7e-da394a9dec6b	Mercedes-Benz C220d AMG Line	mercedes-benz-c220d-amg-line	Stunning Mercedes C-Class with AMG Line exterior and interior. Burmester sound system, panoramic roof, 360 camera, multibeam LED. Immaculate condition. Full dealer service history.	35000.00	4c5a38fd-b5a4-4c24-885a-f9e1c9b3dc7a	t	f	\N	3fb5443b-e25b-43e5-a677-0cd7b6c77f62	a106b6a1-b645-4408-a85e-71e19bc34c3c	C220d AMG Line	2022	28000	adf641a5-9326-431b-9a3f-6189f29da1b3	5bba7a9c-deaa-43c0-8764-21cf79df49ea	d73a5f86-d91e-4757-baba-613ad7a4b687	4	5	147	{}	2026-04-21 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	premium@automarket.mk	\N	'360':23 'amg':5,13,34 'benz':3 'burmest':18 'c':10 'c-class':9 'c220d':4,33 'camera':24 'class':11 'condit':28 'dealer':30 'exterior':15 'full':29 'histori':32 'immacul':27 'interior':17 'led':26 'line':6,14,35 'merced':2,8 'mercedes-benz':1 'multibeam':25 'panoram':21 'roof':22 'servic':31 'sound':19 'stun':7 'system':20
94336ae8-266f-4a34-a56f-c025c093fac9	Toyota RAV4 2.5 Hybrid AWD	toyota-rav4-2-5-hybrid-awd	Reliable Toyota RAV4 Hybrid with all-wheel drive. Great fuel economy, spacious interior, Toyota Safety Sense suite. Perfect family SUV with plenty of cargo space. One owner from new.	31000.00	4c5a38fd-b5a4-4c24-885a-f9e1c9b3dc7a	t	f	\N	923a0bc7-5008-4228-aaee-01126af673f0	e1f40c06-d33a-47f0-b772-869fcca3a800	RAV4 2.5 Hybrid	2021	52000	28d4ba18-300c-4532-92d6-63d74469b43a	d31ffe0a-0b23-4b68-aecc-4cd6f2cc93b4	d06fc11b-bfe4-4c21-a9c1-7f7ebdd08619	4	5	160	{}	2026-04-14 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	marko.petrovski@gmail.com	\N	'2.5':3,37 'all-wheel':11 'awd':5 'cargo':30 'drive':14 'economi':17 'famili':25 'fuel':16 'great':15 'hybrid':4,9,38 'interior':19 'new':35 'one':32 'owner':33 'perfect':24 'plenti':28 'rav4':2,8,36 'reliabl':6 'safeti':21 'sens':22 'space':31 'spacious':18 'suit':23 'suv':26 'toyota':1,7,20 'wheel':13
c675e64e-80e2-4c5d-8190-c9d6fda1da2d	Audi A3 Sportback 35 TFSI S-Line	audi-a3-sportback-35-tfsi	Sporty Audi A3 Sportback with S-line package. Virtual cockpit, MMI navigation, Bang & Olufsen sound, sport suspension. Very economical yet fun to drive. Just had major service.	26500.00	4c5a38fd-b5a4-4c24-885a-f9e1c9b3dc7a	t	t	2026-05-29 09:26:25.972172+00	85538ad0-0bc5-4539-8e9d-158cec1003b7	7e093505-fcdc-4ff2-9d18-c7f507f0768f	A3 Sportback 35 TFSI	2022	25000	fa54edc7-e3ea-40fc-853e-7b176eef8801	f0c38b3b-be37-4d6e-98bb-13cdcc67e27c	d73a5f86-d91e-4757-baba-613ad7a4b687	4	5	110	{}	2026-04-25 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	ana.stojanova@yahoo.com	\N	'35':4,39 'a3':2,11,37 'audi':1,10 'bang':22 'cockpit':19 'drive':32 'econom':28 'fun':30 'line':8,16 'major':35 'mmi':20 'navig':21 'olufsen':23 'packag':17 's-line':6,14 'servic':36 'sound':24 'sport':25 'sportback':3,12,38 'sporti':9 'suspens':26 'tfsi':5,40 'virtual':18 'yet':29
194361d9-248a-4326-a562-9bc80edf87b0	Skoda Octavia Combi 2.0 TDI	skoda-octavia-combi-2-0-tdi	Practical and spacious Skoda Octavia estate. Massive boot, comfortable ride, great on motorways. Columbus navigation, heated seats, parking assist. Ideal family car.	19500.00	4c5a38fd-b5a4-4c24-885a-f9e1c9b3dc7a	t	f	\N	1231c400-0c5d-445d-8fd4-cfd562e46bf5	2574c3e4-c3f4-4404-a909-dea12fb44e73	Octavia Combi 2.0 TDI	2020	78000	adf641a5-9326-431b-9a3f-6189f29da1b3	\N	c31be232-96a8-4921-a7e5-5d7814462ca7	4	5	110	{}	2026-04-09 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	moderator@automarket.mk	\N	'2.0':4,30 'assist':24 'boot':13 'car':27 'columbus':19 'combi':3,29 'comfort':14 'estat':11 'famili':26 'great':16 'heat':21 'ideal':25 'massiv':12 'motorway':18 'navig':20 'octavia':2,10,28 'park':23 'practic':6 'ride':15 'seat':22 'skoda':1,9 'spacious':8 'tdi':5,31
28619579-63d6-462c-90a2-5f92edba9ef3	Tesla Model 3 Long Range 2023	tesla-model-3-long-range-2023	Tesla Model 3 Long Range with autopilot. 580 km range, supercharger access, premium white interior. Over-the-air updates, sentry mode, dashcam. Battery health at 97%. The future of driving.	42000.00	4c5a38fd-b5a4-4c24-885a-f9e1c9b3dc7a	t	t	2026-05-23 09:26:25.972172+00	0f3f2825-d73c-4d57-8d52-ff5072c3fdf6	4555b586-1cf6-42e2-b2a3-e74ce5f381f3	Model 3 Long Range	2023	15000	2278fa3f-7b85-4ccf-83fa-432be624f4b3	5bba7a9c-deaa-43c0-8764-21cf79df49ea	d73a5f86-d91e-4757-baba-613ad7a4b687	4	5	258	{}	2026-05-02 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	stefan.trajkov@gmail.com	\N	'2023':6 '3':3,9,39 '580':14 '97':33 'access':18 'air':25 'autopilot':13 'batteri':30 'dashcam':29 'drive':37 'futur':35 'health':31 'interior':21 'km':15 'long':4,10,40 'mode':28 'model':2,8,38 'over-the-air':22 'premium':19 'rang':5,11,16,41 'sentri':27 'supercharg':17 'tesla':1,7 'updat':26 'white':20
83c23c7b-9dcd-486d-bf37-61aea2b92f14	Opel Corsa 1.2 Turbo 2023	opel-corsa-1-2-turbo-2023	Brand new shape Opel Corsa with turbo engine. Perfect city car with low running costs. Touchscreen infotainment, rear parking sensors, LED lights. Great first car.	16500.00	4c5a38fd-b5a4-4c24-885a-f9e1c9b3dc7a	f	f	\N	75d8dafb-2d53-48e6-97ea-483d7534c0a0	a7a69696-c77a-4110-8b29-4850b12b8b09	Corsa 1.2 Turbo	2023	8000	fa54edc7-e3ea-40fc-853e-7b176eef8801	f0c38b3b-be37-4d6e-98bb-13cdcc67e27c	21d2727a-e827-4451-8cdf-967620bbbf07	4	5	74	{}	2026-05-07 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	elena.dimova@gmail.com	\N	'1.2':3,32 '2023':5 'brand':6 'car':16,30 'citi':15 'corsa':2,10,31 'cost':20 'engin':13 'first':29 'great':28 'infotain':22 'led':26 'light':27 'low':18 'new':7 'opel':1,9 'park':24 'perfect':14 'rear':23 'run':19 'sensor':25 'shape':8 'touchscreen':21 'turbo':4,12,33
1d6b2ebc-c39b-46e5-b3cd-5cfdac2213c7	Ford Ranger Wildtrak 2.0 EcoBlue	ford-ranger-wildtrak-2-0-ecoblue	Tough and capable Ford Ranger Wildtrak. 4x4, diff lock, roll bar, bed liner, tonneau cover. SYNC 3 navigation, heated seats, reversing camera. Ready for work and play.	38000.00	4c5a38fd-b5a4-4c24-885a-f9e1c9b3dc7a	t	f	\N	740483d6-9239-470c-a813-31cfed5182a6	78ca100d-0f50-44e0-8e69-f630ff57725a	Ranger Wildtrak 2.0	2022	35000	adf641a5-9326-431b-9a3f-6189f29da1b3	b9d08bd8-7b72-41f4-ae11-9432d181c57a	d73a5f86-d91e-4757-baba-613ad7a4b687	4	5	156	{}	2026-04-17 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	igor.nikolov@hotmail.com	\N	'2.0':4,35 '3':22 '4x4':12 'bar':16 'bed':17 'camera':27 'capabl':8 'cover':20 'diff':13 'ecoblu':5 'ford':1,9 'heat':24 'liner':18 'lock':14 'navig':23 'play':32 'ranger':2,10,33 'readi':28 'revers':26 'roll':15 'seat':25 'sync':21 'tonneau':19 'tough':6 'wildtrak':3,11,34 'work':30
2324d1f8-952e-4bcf-9893-a9e0a1ffe515	Dacia Sandero Stepway TCe 90	dacia-sandero-stepway-tce-90	Affordable and practical Dacia Sandero Stepway. Raised ride height, roof rails, 8-inch touchscreen with Apple CarPlay. Best value for money on the market. Low insurance group.	12500.00	dfff3d12-d89c-41c7-b13e-250236f0ca6e	t	f	\N	8d11d611-807e-408b-ba9b-fc6eb4b84b86	4a5f3e54-23b7-436a-8d07-26589437fa3f	Sandero Stepway TCe 90	2024	0	fa54edc7-e3ea-40fc-853e-7b176eef8801	f0c38b3b-be37-4d6e-98bb-13cdcc67e27c	21d2727a-e827-4451-8cdf-967620bbbf07	4	5	67	{}	2026-04-29 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	user@automarket.mk	\N	'8':17 '90':5,36 'afford':6 'appl':21 'best':23 'carplay':22 'dacia':1,9 'group':32 'height':14 'inch':18 'insur':31 'low':30 'market':29 'money':26 'practic':8 'rail':16 'rais':12 'ride':13 'roof':15 'sandero':2,10,33 'stepway':3,11,34 'tce':4,35 'touchscreen':19 'valu':24
07b5061a-9441-4c07-9628-aa49767f8451	Porsche Cayenne S 2.9 V6 Biturbo	porsche-cayenne-s-2-9-v6-biturbo	Stunning Porsche Cayenne S in Carrara White. Full leather interior, panoramic roof, BOSE surround, air suspension, Sport Chrono package. Every option ticked. Full Porsche service history.	72000.00	4c5a38fd-b5a4-4c24-885a-f9e1c9b3dc7a	t	t	2026-06-03 09:26:25.972172+00	0f3f2825-d73c-4d57-8d52-ff5072c3fdf6	a7619f40-df18-4390-96f8-0b797147a31e	Cayenne S 2.9 V6	2021	38000	fa54edc7-e3ea-40fc-853e-7b176eef8801	d31ffe0a-0b23-4b68-aecc-4cd6f2cc93b4	d73a5f86-d91e-4757-baba-613ad7a4b687	4	5	324	{}	2026-05-04 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	stefan.trajkov@gmail.com	\N	'2.9':4,35 'air':21 'biturbo':6 'bose':19 'carrara':12 'cayenn':2,9,33 'chrono':24 'everi':26 'full':14,29 'histori':32 'interior':16 'leather':15 'option':27 'packag':25 'panoram':17 'porsch':1,8,30 'roof':18 'servic':31 'sport':23 'stun':7 'surround':20 'suspens':22 'tick':28 'v6':5,36 'white':13
56572e8e-5fb3-440f-ba77-af00c6d3fa1f	Renault Clio 1.0 TCe Intens	renault-clio-1-0-tce-intens	Stylish Renault Clio in Diamond Black. 9.3 inch touchscreen, digital instrument cluster, wireless charging, 360 camera. Extremely low fuel consumption. Lady owner, immaculate.	14800.00	4c5a38fd-b5a4-4c24-885a-f9e1c9b3dc7a	t	f	\N	d4269afa-baac-4de1-8a0d-f8a186bff526	5da38a3d-9370-4dff-a2f4-e521b360d878	Clio 1.0 TCe Intens	2022	19000	fa54edc7-e3ea-40fc-853e-7b176eef8801	f0c38b3b-be37-4d6e-98bb-13cdcc67e27c	21d2727a-e827-4451-8cdf-967620bbbf07	4	5	74	{}	2026-04-23 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	maja.kostadinova@gmail.com	\N	'1.0':3,30 '360':20 '9.3':12 'black':11 'camera':21 'charg':19 'clio':2,8,29 'cluster':17 'consumpt':25 'diamond':10 'digit':15 'extrem':22 'fuel':24 'immacul':28 'inch':13 'instrument':16 'inten':5,32 'ladi':26 'low':23 'owner':27 'renault':1,7 'stylish':6 'tce':4,31 'touchscreen':14 'wireless':18
a91ba2b6-ca6d-4010-b0da-818993e3e65b	Hyundai Tucson 1.6 T-GDI Hybrid	hyundai-tucson-1-6-tgdi-hybrid	New generation Hyundai Tucson with hybrid powertrain. Striking design, 10.25 inch screens, Krell premium audio, blind spot cameras. 5 year warranty remaining. Like new condition.	29500.00	a6b7528e-344e-4c38-8c73-b7e5efb6ca4a	t	f	\N	923a0bc7-5008-4228-aaee-01126af673f0	13852180-f597-4c3c-97a3-126842197b74	Tucson 1.6 T-GDI Hybrid	2023	12000	28d4ba18-300c-4532-92d6-63d74469b43a	d31ffe0a-0b23-4b68-aecc-4cd6f2cc93b4	d73a5f86-d91e-4757-baba-613ad7a4b687	4	5	169	{}	2026-04-30 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	marko.petrovski@gmail.com	\N	'1.6':3,34 '10.25':17 '5':26 'audio':22 'blind':23 'camera':25 'condit':32 'design':16 'gdi':6,37 'generat':9 'hybrid':7,13,38 'hyundai':1,10 'inch':18 'krell':20 'like':30 'new':8,31 'powertrain':14 'premium':21 'remain':29 'screen':19 'spot':24 'strike':15 't-gdi':4,35 'tucson':2,11,33 'warranti':28 'year':27
a80c9f1b-5c75-4d7d-878d-94afbf6e0ab0	Fiat 500e La Prima 42 kWh	fiat-500e-la-prima-42kwh	Adorable electric Fiat 500 in Celestial Blue. Top spec La Prima with glass roof, leather seats, Level 2 autonomous driving, Harman Kardon audio. 320 km range. Perfect city EV.	24000.00	4c5a38fd-b5a4-4c24-885a-f9e1c9b3dc7a	t	f	\N	2fccfa32-7dee-4274-90a6-2294531c0710	d327be90-7163-4cec-a458-120f09effe20	500e La Prima 42 kWh	2023	9500	2278fa3f-7b85-4ccf-83fa-432be624f4b3	7ff49846-674f-46c2-b5a0-a0ec99fc0964	d73a5f86-d91e-4757-baba-613ad7a4b687	2	4	87	{}	2026-04-28 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	ivana.georgievska@gmail.com	\N	'2':24 '320':30 '42':5,39 '500':10 '500e':2,36 'ador':7 'audio':29 'autonom':25 'blue':13 'celesti':12 'citi':34 'drive':26 'electr':8 'ev':35 'fiat':1,9 'glass':19 'harman':27 'kardon':28 'km':31 'kwh':6,40 'la':3,16,37 'leather':21 'level':23 'perfect':33 'prima':4,17,38 'rang':32 'roof':20 'seat':22 'spec':15 'top':14
e48c5831-b619-4000-80a2-6e03aaa98c97	Volvo XC60 B5 Inscription AWD	volvo-xc60-b5-inscription-awd	Premium Volvo XC60 in Crystal White. Inscription trim with Orrefors crystal gear knob, Bowers & Wilkins audio, 360 camera, pilot assist. Swedish luxury at its finest. Full Volvo history.	41000.00	4c5a38fd-b5a4-4c24-885a-f9e1c9b3dc7a	t	f	\N	85538ad0-0bc5-4539-8e9d-158cec1003b7	3d357720-f5ac-4d7c-96a2-8652662077c3	XC60 B5 Inscription	2022	31000	adf641a5-9326-431b-9a3f-6189f29da1b3	d31ffe0a-0b23-4b68-aecc-4cd6f2cc93b4	d73a5f86-d91e-4757-baba-613ad7a4b687	4	5	173	{}	2026-04-20 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	ana.stojanova@yahoo.com	\N	'360':22 'assist':25 'audio':21 'awd':5 'b5':3,35 'bower':19 'camera':23 'crystal':10,16 'finest':30 'full':31 'gear':17 'histori':33 'inscript':4,12,36 'knob':18 'luxuri':27 'orrefor':15 'pilot':24 'premium':6 'swedish':26 'trim':13 'volvo':1,7,32 'white':11 'wilkin':20 'xc60':2,8,34
8be5f9cd-9806-454d-94a4-8e795d93054c	Peugeot 3008 1.5 BlueHDi GT	peugeot-3008-1-5-bluehdi-gt	Eye-catching Peugeot 3008 GT with i-Cockpit. Focal premium audio, grip control, night vision, full LED. French design meets practicality. Very economical diesel engine.	23500.00	4c5a38fd-b5a4-4c24-885a-f9e1c9b3dc7a	t	f	\N	292e621c-f44a-49e8-a92a-6455ea65629e	bea4e9fb-6dc2-4ff9-a7a0-0e6a66cb163f	3008 1.5 BlueHDi GT	2021	55000	adf641a5-9326-431b-9a3f-6189f29da1b3	d31ffe0a-0b23-4b68-aecc-4cd6f2cc93b4	d73a5f86-d91e-4757-baba-613ad7a4b687	4	5	96	{}	2026-04-11 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	aleksandar.ristov@gmail.com	\N	'1.5':3,34 '3008':2,10,33 'audio':18 'bluehdi':4,35 'catch':8 'cockpit':15 'control':20 'design':26 'diesel':31 'econom':30 'engin':32 'eye':7 'eye-catch':6 'focal':16 'french':25 'full':23 'grip':19 'gt':5,11,36 'i-cockpit':13 'led':24 'meet':27 'night':21 'peugeot':1,9 'practic':28 'premium':17 'vision':22
6e4196b7-5f63-44b5-9f53-de594e2777c6	Kia Sportage 1.6 T-GDI GT-Line	kia-sportage-1-6-tgdi-gt-line	Head-turning new Kia Sportage with curved dual screen dashboard. Harman Kardon audio, ventilated seats, smart park assist, heads-up display. 7 year Kia warranty. Incredible value.	27000.00	a6b7528e-344e-4c38-8c73-b7e5efb6ca4a	t	f	\N	b1ba0660-e3df-4b8c-b2a9-4414d104189e	2e75408a-3e83-499e-ba15-e968790db482	Sportage 1.6 T-GDI	2023	18000	fa54edc7-e3ea-40fc-853e-7b176eef8801	d31ffe0a-0b23-4b68-aecc-4cd6f2cc93b4	d73a5f86-d91e-4757-baba-613ad7a4b687	4	5	132	{}	2026-05-03 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	nikola.andonov@gmail.com	\N	'1.6':3,40 '7':33 'assist':28 'audio':23 'curv':17 'dashboard':20 'display':32 'dual':18 'gdi':6,43 'gt':8 'gt-line':7 'harman':21 'head':11,30 'head-turn':10 'heads-up':29 'incred':37 'kardon':22 'kia':1,14,35 'line':9 'new':13 'park':27 'screen':19 'seat':25 'smart':26 'sportag':2,15,39 't-gdi':4,41 'turn':12 'valu':38 'ventil':24 'warranti':36 'year':34
d6b750c1-3b36-4e6b-9707-3731faab57b3	Seat Leon FR 1.5 eTSI 150	seat-leon-fr-1-5-etsi-150	Dynamic Seat Leon FR with mild hybrid tech. Virtual cockpit, BeatsAudio, dynamic chassis control, full LED matrix headlights. Same platform as Golf 8 but more exciting styling.	21500.00	4c5a38fd-b5a4-4c24-885a-f9e1c9b3dc7a	t	f	\N	d81ec3ca-9c3c-4354-9386-3f7d8a91efe4	02719acd-69f9-4837-aaca-ddbefee8cea4	Leon FR 1.5 eTSI	2022	29000	28d4ba18-300c-4532-92d6-63d74469b43a	f0c38b3b-be37-4d6e-98bb-13cdcc67e27c	c31be232-96a8-4921-a7e5-5d7814462ca7	4	5	110	{}	2026-05-05 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	dejan.milosevski@gmail.com	\N	'1.5':4,36 '150':6 '8':29 'beatsaudio':17 'chassi':19 'cockpit':16 'control':20 'dynam':7,18 'etsi':5,37 'excit':32 'fr':3,10,35 'full':21 'golf':28 'headlight':24 'hybrid':13 'led':22 'leon':2,9,34 'matrix':23 'mild':12 'platform':26 'seat':1,8 'style':33 'tech':14 'virtual':15
33504139-3147-4fc7-828d-08ef67bbf186	Nissan Qashqai 1.3 DIG-T Tekna+	nissan-qashqai-1-3-digt-tekna-plus	Top spec Nissan Qashqai Tekna+ with ProPILOT assist, around view monitor, quilted leather, powered tailgate. Massaging driver seat. The original crossover, perfected.	25000.00	4c5a38fd-b5a4-4c24-885a-f9e1c9b3dc7a	t	f	\N	b18ee252-3735-4afb-9f52-804477425db6	85835ed2-3306-410f-a5c1-31ad140287ae	Qashqai 1.3 DIG-T	2022	22000	fa54edc7-e3ea-40fc-853e-7b176eef8801	d31ffe0a-0b23-4b68-aecc-4cd6f2cc93b4	d06fc11b-bfe4-4c21-a9c1-7f7ebdd08619	4	5	116	{}	2026-05-01 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	tamara.mitrevska@gmail.com	\N	'1.3':3,31 'around':16 'assist':15 'crossov':28 'dig':5,33 'dig-t':4,32 'driver':24 'leather':20 'massag':23 'monitor':18 'nissan':1,10 'origin':27 'perfect':29 'power':21 'propilot':14 'qashqai':2,11,30 'quilt':19 'seat':25 'spec':9 'tailgat':22 'tekna':7,12 'top':8 'view':17
9f36339c-9535-41b0-8c96-74c747bee0f4	Mazda CX-5 2.2 Skyactiv-D AWD	mazda-cx5-2-2-skyactiv-d-awd	Beautifully crafted Mazda CX-5 with Soul Red Crystal paint. Nappa leather, BOSE audio, head-up display, 360 view. Japanese precision engineering. Drives like a premium car at half the price.	26000.00	4c5a38fd-b5a4-4c24-885a-f9e1c9b3dc7a	t	f	\N	740483d6-9239-470c-a813-31cfed5182a6	4389c283-1841-4387-80af-3b0278484052	CX-5 2.2 Skyactiv-D	2021	42000	adf641a5-9326-431b-9a3f-6189f29da1b3	d31ffe0a-0b23-4b68-aecc-4cd6f2cc93b4	d73a5f86-d91e-4757-baba-613ad7a4b687	4	5	135	{}	2026-04-24 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	igor.nikolov@hotmail.com	\N	'-5':3,13,42 '2.2':4,43 '360':27 'audio':22 'awd':8 'beauti':9 'bose':21 'car':36 'craft':10 'crystal':17 'cx':2,12,41 'd':7,46 'display':26 'drive':32 'engin':31 'half':38 'head':24 'head-up':23 'japanes':29 'leather':20 'like':33 'mazda':1,11 'nappa':19 'paint':18 'precis':30 'premium':35 'price':40 'red':16 'skyactiv':6,45 'skyactiv-d':5,44 'soul':15 'view':28
eaee3c3f-1c28-4401-9e33-cb5900ad7179	Honda Civic 2.0 e:HEV Advance	honda-civic-2-0-ehev-advance	Sleek 11th generation Honda Civic hybrid. 184 PS combined output, 4.7L/100km fuel economy, BOSE premium audio, Honda SENSING suite. The thinking person's hatchback.	28000.00	4c5a38fd-b5a4-4c24-885a-f9e1c9b3dc7a	f	f	\N	c87953f6-a443-4fb7-9c6c-788ccefc95ca	7f178758-c66a-4143-926a-bcebd5d50731	Civic 2.0 e:HEV	2023	11000	28d4ba18-300c-4532-92d6-63d74469b43a	f0c38b3b-be37-4d6e-98bb-13cdcc67e27c	d06fc11b-bfe4-4c21-a9c1-7f7ebdd08619	4	5	135	{}	2026-05-08 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	kristina.ilievska@gmail.com	\N	'11th':8 '184':13 '2.0':3,33 '4.7':17 'advanc':6 'audio':23 'bose':21 'civic':2,11,32 'combin':15 'e':4,34 'economi':20 'fuel':19 'generat':9 'hatchback':31 'hev':5,35 'honda':1,10,24 'hybrid':12 'l/100km':18 'output':16 'person':29 'premium':22 'ps':14 'sens':25 'sleek':7 'suit':26 'think':28
3aa34d57-aac7-4d3c-a64b-34f5bfbd4c25	Alfa Romeo Giulia 2.2 JTDm Veloce	alfa-romeo-giulia-2-2-jtdm-veloce	Drop-dead gorgeous Alfa Romeo Giulia in Misano Blue. Veloce trim with sport seats, carbon fibre trim, limited slip diff, adaptive dampers. Italian passion meets German engineering. A true driver's car.	27500.00	4c5a38fd-b5a4-4c24-885a-f9e1c9b3dc7a	t	f	\N	85538ad0-0bc5-4539-8e9d-158cec1003b7	eda7aa3c-32cf-43c5-830a-ebe7093ec6a8	Giulia 2.2 JTDm Veloce	2021	40000	adf641a5-9326-431b-9a3f-6189f29da1b3	5bba7a9c-deaa-43c0-8764-21cf79df49ea	d73a5f86-d91e-4757-baba-613ad7a4b687	4	5	154	{}	2026-04-18 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	ana.stojanova@yahoo.com	\N	'2.2':4,41 'adapt':28 'alfa':1,11 'blue':16 'car':39 'carbon':22 'damper':29 'dead':9 'diff':27 'driver':37 'drop':8 'drop-dead':7 'engin':34 'fibr':23 'german':33 'giulia':3,13,40 'gorgeous':10 'italian':30 'jtdm':5,42 'limit':25 'meet':32 'misano':15 'passion':31 'romeo':2,12 'seat':21 'slip':26 'sport':20 'trim':18,24 'true':36 'veloc':6,17,43
97dc8ee5-49ff-440b-89de-91e4fdb97d70	Mini Cooper S 2.0 John Cooper Works Trim	mini-cooper-s-jcw-trim	Fun and characterful Mini Cooper S with JCW body kit, sport exhaust, and Chili Red roof. Harman Kardon audio, heads-up display, driving modes. Go-kart handling in the city!	23000.00	4c5a38fd-b5a4-4c24-885a-f9e1c9b3dc7a	t	f	\N	d4269afa-baac-4de1-8a0d-f8a186bff526	1d4db490-81b3-4ac6-9061-1eb33ebe4817	Cooper S 2.0 JCW	2022	21000	fa54edc7-e3ea-40fc-853e-7b176eef8801	f0c38b3b-be37-4d6e-98bb-13cdcc67e27c	d73a5f86-d91e-4757-baba-613ad7a4b687	2	4	141	{}	2026-04-26 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	maja.kostadinova@gmail.com	\N	'2.0':4,43 'audio':27 'bodi':17 'charact':11 'chili':22 'citi':40 'cooper':2,6,13,41 'display':31 'drive':32 'exhaust':20 'fun':9 'go':35 'go-kart':34 'handl':37 'harman':25 'head':29 'heads-up':28 'jcw':16,44 'john':5 'kardon':26 'kart':36 'kit':18 'mini':1,12 'mode':33 'red':23 'roof':24 'sport':19 'trim':8 'work':7
af89edb0-1427-41f4-abea-036d209f318d	Land Rover Discovery Sport 2.0 D200 R-Dynamic	land-rover-discovery-sport-d200	Capable Land Rover Discovery Sport with 7 seats. Terrain Response 2, wade sensing, ClearSight mirror, meridian audio. British off-road heritage with urban sophistication. Perfect for families who love adventure.	37500.00	4c5a38fd-b5a4-4c24-885a-f9e1c9b3dc7a	t	f	\N	923a0bc7-5008-4228-aaee-01126af673f0	61567359-0d60-4cdf-9641-e98c57139140	Discovery Sport D200	2022	33000	adf641a5-9326-431b-9a3f-6189f29da1b3	d31ffe0a-0b23-4b68-aecc-4cd6f2cc93b4	d73a5f86-d91e-4757-baba-613ad7a4b687	4	7	150	{}	2026-04-22 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	marko.petrovski@gmail.com	\N	'2':20 '2.0':5 '7':16 'adventur':40 'audio':26 'british':27 'capabl':10 'clearsight':23 'd200':6,43 'discoveri':3,13,41 'dynam':9 'famili':37 'heritag':31 'land':1,11 'love':39 'meridian':25 'mirror':24 'off-road':28 'perfect':35 'r':8 'r-dynam':7 'respons':19 'road':30 'rover':2,12 'seat':17 'sens':22 'sophist':34 'sport':4,14,42 'terrain':18 'urban':33 'wade':21
452110da-c7c3-4812-88fc-98df81c9100a	Suzuki Jimny 1.5 AllGrip Pro	suzuki-jimny-1-5-allgrip-pro	Iconic Suzuki Jimny in Kinetic Yellow. Part-time 4WD with low range, ladder frame chassis, 210mm ground clearance. Tiny but mighty. Rare find — these sell out instantly!	22500.00	dfff3d12-d89c-41c7-b13e-250236f0ca6e	f	f	\N	b1ba0660-e3df-4b8c-b2a9-4414d104189e	e6fe7931-ee59-4bd5-b39a-25106c5f1476	Jimny 1.5 AllGrip	2024	500	fa54edc7-e3ea-40fc-853e-7b176eef8801	d31ffe0a-0b23-4b68-aecc-4cd6f2cc93b4	21d2727a-e827-4451-8cdf-967620bbbf07	2	4	75	{}	2026-05-09 03:26:25.972172+00	2026-05-09 09:26:25.972172+00	nikola.andonov@gmail.com	\N	'1.5':3,35 '210mm':22 '4wd':15 'allgrip':4,36 'chassi':21 'clearanc':24 'find':29 'frame':20 'ground':23 'icon':6 'instant':33 'jimni':2,8,34 'kinet':10 'ladder':19 'low':17 'mighti':27 'part':13 'part-tim':12 'pro':5 'rang':18 'rare':28 'sell':31 'suzuki':1,7 'time':14 'tini':25 'yellow':11
7a3bc970-06a6-426f-83cd-b7018bdffc87	BMW 525i E60 2006 - SOLD	bmw-525i-e60-2006-sold	Classic E60 BMW 5 Series. Was a great car. Sold to a happy buyer from Skopje.	5500.00	4c5a38fd-b5a4-4c24-885a-f9e1c9b3dc7a	t	f	\N	292e621c-f44a-49e8-a92a-6455ea65629e	f9d1f607-79e0-43ab-b7e7-572de70378ce	525i E60	2006	245000	fa54edc7-e3ea-40fc-853e-7b176eef8801	5bba7a9c-deaa-43c0-8764-21cf79df49ea	d73a5f86-d91e-4757-baba-613ad7a4b687	4	5	141	{}	2026-03-30 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	aleksandar.ristov@gmail.com	2026-05-04 09:26:25.972172+00	'2006':4 '5':9 '525i':2,22 'bmw':1,8 'buyer':19 'car':14 'classic':6 'e60':3,7,23 'great':13 'happi':18 'seri':10 'skopj':21 'sold':5,15
15a1a9b0-b89a-4608-aac8-43281faa1158	Testaaaaaaaaaaaaa	testaaaaaaaaaaaaa-16-2015	Testaaaaaaaaaaaaaaaaaaaaaaaa	5555.00	4c5a38fd-b5a4-4c24-885a-f9e1c9b3dc7a	f	f	\N	b487c11a-1041-49b4-a94f-b41fab5bb7bb	7e093505-fcdc-4ff2-9d18-c7f507f0768f	16	2015	2222	adf641a5-9326-431b-9a3f-6189f29da1b3	8fd1493d-ba36-4e78-ae14-d8fefc440971	21d2727a-e827-4451-8cdf-967620bbbf07	\N	\N	222	{}	2026-05-18 21:41:59.333497+00	2026-05-18 21:41:59.333497+00	admin@automarket.mk	\N	'16':3 'testaaaaaaaaaaaaa':1 'testaaaaaaaaaaaaaaaaaaaaaaaa':2
\.


--
-- Data for Name: outbox; Type: TABLE DATA; Schema: public; Owner: automarket
--

COPY public.outbox (id, source_service, topic, event_key, event_type, payload, created_at, published_at, attempts, last_error) FROM stdin;
7b263c0c-1134-4f59-8c2c-89de9e2a7ce9	inquiry-service	automarket.inquiry-events	b256f67f-c345-4e85-b65e-b92eba57c086	inquiry.sent	{"eventId":"7b263c0c-1134-4f59-8c2c-89de9e2a7ce9","eventType":"inquiry.sent","timestamp":"2026-09-21T18:45:43.948846182Z","payload":{"inquiryId":"b256f67f-c345-4e85-b65e-b92eba57c086","listingId":"d6b750c1-3b36-4e6b-9707-3731faab57b3","listingTitle":"Seat Leon FR 1.5 eTSI 150","senderId":"4de9f430-653d-44b4-9993-ab276dddf190","senderName":"Daniel Kostoski","senderEmail":"kostoskidaniel13@gmail.com","sellerId":"d81ec3ca-9c3c-4354-9386-3f7d8a91efe4","sellerEmail":"dejan.milosevski@gmail.com","message":"is it available?"}}	2026-09-21 18:45:44.056414+00	2026-09-21 18:45:46.619817+00	0	\N
d24805ef-7bff-46ac-9c1e-86a326a57b14	inquiry-service	automarket.inquiry-events	76f00dcb-bbca-46f0-8e99-4abe145ec0ca	inquiry.sent	{"eventId":"d24805ef-7bff-46ac-9c1e-86a326a57b14","eventType":"inquiry.sent","timestamp":"2026-09-21T19:12:34.654822847Z","payload":{"inquiryId":"76f00dcb-bbca-46f0-8e99-4abe145ec0ca","listingId":"e48c5831-b619-4000-80a2-6e03aaa98c97","listingTitle":"Volvo XC60 B5 Inscription AWD","senderId":"4de9f430-653d-44b4-9993-ab276dddf190","senderName":"Daniel Kostoski","senderEmail":"kostoskidaniel13@gmail.com","sellerId":"85538ad0-0bc5-4539-8e9d-158cec1003b7","sellerEmail":"ana.stojanova@yahoo.com","message":"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"}}	2026-09-21 19:12:34.67289+00	2026-09-21 19:12:35.195883+00	0	\N
113f6624-c50e-4a79-b507-1d7007e77168	inquiry-service	automarket.inquiry-events	11b91bcb-6876-4ac5-9c22-17b99a0b34ae	inquiry.sent	{"eventId":"113f6624-c50e-4a79-b507-1d7007e77168","eventType":"inquiry.sent","timestamp":"2026-09-21T19:12:45.267692200Z","payload":{"inquiryId":"11b91bcb-6876-4ac5-9c22-17b99a0b34ae","listingId":"c675e64e-80e2-4c5d-8190-c9d6fda1da2d","listingTitle":"Audi A3 Sportback 35 TFSI S-Line","senderId":"4de9f430-653d-44b4-9993-ab276dddf190","senderName":"Daniel Kostoski","senderEmail":"kostoskidaniel13@gmail.com","sellerId":"85538ad0-0bc5-4539-8e9d-158cec1003b7","sellerEmail":"ana.stojanova@yahoo.com","message":"TEEEEEEEEEEEEEEEEEEEEEST"}}	2026-09-21 19:12:45.269279+00	2026-09-21 19:12:46.189188+00	0	\N
3786354e-081d-4e18-8d3c-23ce54a3cb9f	auth-service	automarket.user-events	53598466-cec5-4763-a545-109c21d7fc9f	user.registered	{"eventId":"3786354e-081d-4e18-8d3c-23ce54a3cb9f","eventType":"user.registered","timestamp":"2026-09-22T16:58:40.278861405Z","payload":{"userId":"53598466-cec5-4763-a545-109c21d7fc9f","email":"kostoskidaniel14@gmail.com","name":"Daniel Kostoski","phone":"+38978896322","cityName":null,"plan":"FREE","createdAt":"2026-09-22T16:58:40.246623962Z"}}	2026-09-22 16:58:40.301379+00	2026-09-22 16:58:42.133191+00	0	\N
c5425cd9-9204-46aa-9882-120ad494f3e2	inquiry-service	automarket.inquiry-events	ff8e9e6f-c5fa-4e73-bf25-994d63c58e22	inquiry.sent	{"eventId":"c5425cd9-9204-46aa-9882-120ad494f3e2","eventType":"inquiry.sent","timestamp":"2026-09-22T16:59:29.717416028Z","payload":{"inquiryId":"ff8e9e6f-c5fa-4e73-bf25-994d63c58e22","listingId":"d6b750c1-3b36-4e6b-9707-3731faab57b3","listingTitle":"Seat Leon FR 1.5 eTSI 150","senderId":"53598466-cec5-4763-a545-109c21d7fc9f","senderName":"Daniel Kostoski","senderEmail":"kostoskidaniel14@gmail.com","sellerId":"d81ec3ca-9c3c-4354-9386-3f7d8a91efe4","sellerEmail":"dejan.milosevski@gmail.com","message":"Test poraka 2"}}	2026-09-22 16:59:29.863996+00	2026-09-22 16:59:31.335134+00	0	\N
\.


--
-- Data for Name: payment_user_view; Type: TABLE DATA; Schema: public; Owner: automarket
--

COPY public.payment_user_view (id, email, name) FROM stdin;
923a0bc7-5008-4228-aaee-01126af673f0	marko.petrovski@gmail.com	Marko Petrovski
85538ad0-0bc5-4539-8e9d-158cec1003b7	ana.stojanova@yahoo.com	Ana Stojanova
740483d6-9239-470c-a813-31cfed5182a6	igor.nikolov@hotmail.com	Igor Nikolov
75d8dafb-2d53-48e6-97ea-483d7534c0a0	elena.dimova@gmail.com	Elena Dimova
0f3f2825-d73c-4d57-8d52-ff5072c3fdf6	stefan.trajkov@gmail.com	Stefan Trajkov
d4269afa-baac-4de1-8a0d-f8a186bff526	maja.kostadinova@gmail.com	Maja Kostadinova
292e621c-f44a-49e8-a92a-6455ea65629e	aleksandar.ristov@gmail.com	Aleksandar Ristov
2fccfa32-7dee-4274-90a6-2294531c0710	ivana.georgievska@gmail.com	Ivana Georgievska
b1ba0660-e3df-4b8c-b2a9-4414d104189e	nikola.andonov@gmail.com	Nikola Andonov
b18ee252-3735-4afb-9f52-804477425db6	tamara.mitrevska@gmail.com	Tamara Mitrevska
d81ec3ca-9c3c-4354-9386-3f7d8a91efe4	dejan.milosevski@gmail.com	Dejan Milosevski
c87953f6-a443-4fb7-9c6c-788ccefc95ca	kristina.ilievska@gmail.com	Kristina Ilievska
7204b7eb-a53b-4d49-8e7e-d8bb4f3bea8a	superadmin@automarket.mk	Super Admin
b487c11a-1041-49b4-a94f-b41fab5bb7bb	admin@automarket.mk	Admin User
1231c400-0c5d-445d-8fd4-cfd562e46bf5	moderator@automarket.mk	Moderator User
8d11d611-807e-408b-ba9b-fc6eb4b84b86	user@automarket.mk	Regular User
3fb5443b-e25b-43e5-a677-0cd7b6c77f62	premium@automarket.mk	Premium User
4de9f430-653d-44b4-9993-ab276dddf190	kostoskidaniel13@gmail.com	Daniel Kostoski
53598466-cec5-4763-a545-109c21d7fc9f	kostoskidaniel14@gmail.com	Daniel Kostoski
\.


--
-- Data for Name: processed_event; Type: TABLE DATA; Schema: public; Owner: automarket
--

COPY public.processed_event (event_id, consumer_group, event_type, processed_at) FROM stdin;
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: public; Owner: automarket
--

COPY public.refresh_tokens (id, token, user_id, expires_at, revoked, created_at) FROM stdin;
40948279-bcce-4e65-a840-acfaa45f2157	2a9c9089-72a4-4ea5-b47a-218b76f23f48	7204b7eb-a53b-4d49-8e7e-d8bb4f3bea8a	2026-06-08 14:30:28.560281+00	f	2026-05-09 14:30:28.560933+00
7f307d12-08d5-4260-bd8b-3eb2d2817820	76921f0b-1d4f-4022-a093-688f828f2b96	7204b7eb-a53b-4d49-8e7e-d8bb4f3bea8a	2026-06-08 14:30:28.560246+00	f	2026-05-09 14:30:28.560935+00
4e46e3c8-f14d-49b1-913e-9e90091a051a	977298f9-e6d7-455d-93f0-6c264b75f6fc	7204b7eb-a53b-4d49-8e7e-d8bb4f3bea8a	2026-06-08 09:26:45.718626+00	t	2026-05-09 09:26:45.71864+00
e2a87758-2f98-4173-bba1-16da0834e159	14f2cc56-de76-43ee-bfb4-d9ea72ac77d4	b487c11a-1041-49b4-a94f-b41fab5bb7bb	2026-06-17 21:22:48.832542+00	t	2026-05-18 21:22:48.832557+00
0c02065d-b87e-4407-860d-0cccc5c97ff2	6949230e-fb07-4959-83d8-ebdf8f7dd7f1	b487c11a-1041-49b4-a94f-b41fab5bb7bb	2026-06-17 21:24:30.309249+00	t	2026-05-18 21:24:30.309258+00
b0484a62-534d-4f3d-83a4-923e970feb0f	cb3a07bd-adfb-40c2-bea5-e48e96f6e40b	b487c11a-1041-49b4-a94f-b41fab5bb7bb	2026-06-17 21:41:20.52292+00	t	2026-05-18 21:41:20.52294+00
5f7e67f1-c5ec-4361-ad18-4a222c0285e3	e4ed6921-3737-41b7-8b40-cc10acae0d53	b487c11a-1041-49b4-a94f-b41fab5bb7bb	2026-06-18 18:09:30.84852+00	t	2026-05-19 18:09:30.848536+00
6a893651-cf3e-4b6d-90c2-f593b590f201	85ac53d5-2436-46ac-a436-4655e3d53f27	b487c11a-1041-49b4-a94f-b41fab5bb7bb	2026-06-18 18:37:28.031603+00	t	2026-05-19 18:37:28.031629+00
cfd1cf4f-6111-47f2-8383-03bad8c400c3	5b176ddc-9762-4a55-8fe0-cc1271299b97	b487c11a-1041-49b4-a94f-b41fab5bb7bb	2026-06-18 18:43:11.803424+00	f	2026-05-19 18:43:11.80343+00
2501899c-8a83-464a-bf44-1eee4368a921	b276e168-3939-494d-9bf7-0f838709c721	4de9f430-653d-44b4-9993-ab276dddf190	2026-10-17 22:59:32.535167+00	t	2026-09-17 22:59:32.535188+00
0fff9a24-f834-4453-aa62-1eddd28960fd	da787ae6-eead-4c36-b8ce-a506fe61db0d	4de9f430-653d-44b4-9993-ab276dddf190	2026-10-17 23:17:26.855984+00	t	2026-09-17 23:17:26.856484+00
30d90c26-28d5-4ea1-a0cf-47bd5d767710	43712252-bbfb-4663-a115-ea3844aca017	4de9f430-653d-44b4-9993-ab276dddf190	2026-10-21 18:30:43.038423+00	t	2026-09-21 18:30:43.038462+00
af1ff218-88f4-40f7-97cf-498a891c83ad	7ab923b7-0228-416e-8762-b62a15318f9c	4de9f430-653d-44b4-9993-ab276dddf190	2026-10-21 19:01:31.491886+00	t	2026-09-21 19:01:31.492003+00
9e5c21eb-a703-41e2-9921-ed992ee77343	38234627-4ac6-4753-adf4-d4223c6881d7	4de9f430-653d-44b4-9993-ab276dddf190	2026-10-21 19:11:31.833152+00	t	2026-09-21 19:11:31.83316+00
e0ee5942-5e5c-4887-95c2-6a4ae3287353	0127c0e4-272d-49c4-93e7-4c276b39852d	4de9f430-653d-44b4-9993-ab276dddf190	2026-10-21 19:12:49.656327+00	t	2026-09-21 19:12:49.656337+00
c33054f8-7a81-4b55-93e8-3d1654f655bb	8ef0130d-5f11-4ee6-8706-3df56d1dc46b	4de9f430-653d-44b4-9993-ab276dddf190	2026-10-22 16:58:25.221249+00	f	2026-09-22 16:58:25.221288+00
5d6b8080-13c9-4641-a1a4-135c72420caa	d06cbb19-8077-44b5-919e-8b5c7d8e3474	53598466-cec5-4763-a545-109c21d7fc9f	2026-10-22 16:58:40.462765+00	f	2026-09-22 16:58:40.462771+00
46320bf2-6669-4bce-95d7-4fdc2bc4e245	e9d66b1e-a278-4037-952d-7ba793120af3	d81ec3ca-9c3c-4354-9386-3f7d8a91efe4	2026-10-22 16:59:59.210692+00	t	2026-09-22 16:59:59.210699+00
70338f1e-e1c0-42c1-9637-14f93f83615c	7a9bc394-5480-4e51-b289-3878de994672	d81ec3ca-9c3c-4354-9386-3f7d8a91efe4	2026-10-22 17:00:06.529041+00	t	2026-09-22 17:00:06.529049+00
e355b974-7aa5-4b3f-b9ae-df427ab199e5	2b1fbde7-57ae-4ab4-a725-f4f840463a4b	d81ec3ca-9c3c-4354-9386-3f7d8a91efe4	2026-10-22 17:00:42.921987+00	f	2026-09-22 17:00:42.921996+00
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: automarket
--

COPY public.roles (id, name) FROM stdin;
008093cb-85ab-4d4b-89d5-a55e2aa60e8f	ROLE_USER
05c90a5f-3395-486a-aa63-e1a506275b35	ROLE_MODERATOR
e1967ce3-3952-4724-8622-30d99c469a38	ROLE_ADMIN
19c2edff-90a3-4dd4-a048-58d0704a5ac4	ROLE_SUPERADMIN
\.


--
-- Data for Name: subscriptions; Type: TABLE DATA; Schema: public; Owner: automarket
--

COPY public.subscriptions (id, user_id, plan, status, stripe_subscription_id, stripe_customer_id, current_period_start, current_period_end, created_at, updated_at, created_by) FROM stdin;
820557a9-75df-44ef-9c3d-fcc32d10a57f	3fb5443b-e25b-43e5-a677-0cd7b6c77f62	PREMIUM	ACTIVE	\N	\N	2026-04-24 09:26:25.972172+00	2026-05-24 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	\N
932a3279-01d5-4eff-92f1-6716be7302f5	85538ad0-0bc5-4539-8e9d-158cec1003b7	PREMIUM	ACTIVE	\N	\N	2026-04-29 09:26:25.972172+00	2026-05-29 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	\N
d127ad6c-389f-4e86-8cb4-939ac82cade0	0f3f2825-d73c-4d57-8d52-ff5072c3fdf6	PREMIUM	ACTIVE	\N	\N	2026-05-04 09:26:25.972172+00	2026-06-03 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	\N
\.


--
-- Data for Name: transmission_types; Type: TABLE DATA; Schema: public; Owner: automarket
--

COPY public.transmission_types (id, name) FROM stdin;
21d2727a-e827-4451-8cdf-967620bbbf07	Manual
d73a5f86-d91e-4757-baba-613ad7a4b687	Automatic
1a013a4c-4399-4d67-aa89-5c45f599737a	Semi-Automatic
d06fc11b-bfe4-4c21-a9c1-7f7ebdd08619	CVT
c31be232-96a8-4921-a7e5-5d7814462ca7	Dual-Clutch (DCT)
\.


--
-- Data for Name: user_roles; Type: TABLE DATA; Schema: public; Owner: automarket
--

COPY public.user_roles (user_id, role_id) FROM stdin;
7204b7eb-a53b-4d49-8e7e-d8bb4f3bea8a	008093cb-85ab-4d4b-89d5-a55e2aa60e8f
7204b7eb-a53b-4d49-8e7e-d8bb4f3bea8a	19c2edff-90a3-4dd4-a048-58d0704a5ac4
b487c11a-1041-49b4-a94f-b41fab5bb7bb	008093cb-85ab-4d4b-89d5-a55e2aa60e8f
b487c11a-1041-49b4-a94f-b41fab5bb7bb	e1967ce3-3952-4724-8622-30d99c469a38
1231c400-0c5d-445d-8fd4-cfd562e46bf5	008093cb-85ab-4d4b-89d5-a55e2aa60e8f
1231c400-0c5d-445d-8fd4-cfd562e46bf5	05c90a5f-3395-486a-aa63-e1a506275b35
8d11d611-807e-408b-ba9b-fc6eb4b84b86	008093cb-85ab-4d4b-89d5-a55e2aa60e8f
3fb5443b-e25b-43e5-a677-0cd7b6c77f62	008093cb-85ab-4d4b-89d5-a55e2aa60e8f
923a0bc7-5008-4228-aaee-01126af673f0	008093cb-85ab-4d4b-89d5-a55e2aa60e8f
85538ad0-0bc5-4539-8e9d-158cec1003b7	008093cb-85ab-4d4b-89d5-a55e2aa60e8f
740483d6-9239-470c-a813-31cfed5182a6	008093cb-85ab-4d4b-89d5-a55e2aa60e8f
75d8dafb-2d53-48e6-97ea-483d7534c0a0	008093cb-85ab-4d4b-89d5-a55e2aa60e8f
0f3f2825-d73c-4d57-8d52-ff5072c3fdf6	008093cb-85ab-4d4b-89d5-a55e2aa60e8f
d4269afa-baac-4de1-8a0d-f8a186bff526	008093cb-85ab-4d4b-89d5-a55e2aa60e8f
292e621c-f44a-49e8-a92a-6455ea65629e	008093cb-85ab-4d4b-89d5-a55e2aa60e8f
2fccfa32-7dee-4274-90a6-2294531c0710	008093cb-85ab-4d4b-89d5-a55e2aa60e8f
b1ba0660-e3df-4b8c-b2a9-4414d104189e	008093cb-85ab-4d4b-89d5-a55e2aa60e8f
b18ee252-3735-4afb-9f52-804477425db6	008093cb-85ab-4d4b-89d5-a55e2aa60e8f
d81ec3ca-9c3c-4354-9386-3f7d8a91efe4	008093cb-85ab-4d4b-89d5-a55e2aa60e8f
c87953f6-a443-4fb7-9c6c-788ccefc95ca	008093cb-85ab-4d4b-89d5-a55e2aa60e8f
4de9f430-653d-44b4-9993-ab276dddf190	008093cb-85ab-4d4b-89d5-a55e2aa60e8f
53598466-cec5-4763-a545-109c21d7fc9f	008093cb-85ab-4d4b-89d5-a55e2aa60e8f
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: automarket
--

COPY public.users (id, email, password_hash, name, phone, city_id, plan, created_at, updated_at, created_by, deleted_at, enabled) FROM stdin;
923a0bc7-5008-4228-aaee-01126af673f0	marko.petrovski@gmail.com	$2b$12$beMhOs0f3Moc.tF/9Cc1l.szxM1.9wDd9oUt0Aj8DPMGZVWH7rWNa	Marko Petrovski	+389 71 234 567	2034be85-bde5-44a3-9e81-17d2dfedc4b4	FREE	2026-03-25 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	\N	\N	t
85538ad0-0bc5-4539-8e9d-158cec1003b7	ana.stojanova@yahoo.com	$2b$12$beMhOs0f3Moc.tF/9Cc1l.szxM1.9wDd9oUt0Aj8DPMGZVWH7rWNa	Ana Stojanova	+389 72 345 678	e6d535d5-3205-4b59-a5e7-3d80e7e4d1be	PREMIUM	2026-04-01 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	\N	\N	t
740483d6-9239-470c-a813-31cfed5182a6	igor.nikolov@hotmail.com	$2b$12$beMhOs0f3Moc.tF/9Cc1l.szxM1.9wDd9oUt0Aj8DPMGZVWH7rWNa	Igor Nikolov	+389 70 456 789	a58c42f7-5c1f-4b13-a13a-315ff36dc90b	FREE	2026-04-09 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	\N	\N	t
75d8dafb-2d53-48e6-97ea-483d7534c0a0	elena.dimova@gmail.com	$2b$12$beMhOs0f3Moc.tF/9Cc1l.szxM1.9wDd9oUt0Aj8DPMGZVWH7rWNa	Elena Dimova	+389 75 567 890	e9849a12-2ad6-480b-bf87-3429d2565beb	FREE	2026-04-14 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	\N	\N	t
0f3f2825-d73c-4d57-8d52-ff5072c3fdf6	stefan.trajkov@gmail.com	$2b$12$beMhOs0f3Moc.tF/9Cc1l.szxM1.9wDd9oUt0Aj8DPMGZVWH7rWNa	Stefan Trajkov	+389 76 678 901	f2755650-1329-4531-b414-fadf55c26557	PREMIUM	2026-04-17 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	\N	\N	t
d4269afa-baac-4de1-8a0d-f8a186bff526	maja.kostadinova@gmail.com	$2b$12$beMhOs0f3Moc.tF/9Cc1l.szxM1.9wDd9oUt0Aj8DPMGZVWH7rWNa	Maja Kostadinova	+389 77 789 012	ac265a4a-2d9d-4ff7-b5aa-d15e41a96901	FREE	2026-04-21 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	\N	\N	t
292e621c-f44a-49e8-a92a-6455ea65629e	aleksandar.ristov@gmail.com	$2b$12$beMhOs0f3Moc.tF/9Cc1l.szxM1.9wDd9oUt0Aj8DPMGZVWH7rWNa	Aleksandar Ristov	+389 78 890 123	32139dc4-d6be-40bb-bdcd-714a5603cbf8	FREE	2026-04-24 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	\N	\N	t
2fccfa32-7dee-4274-90a6-2294531c0710	ivana.georgievska@gmail.com	$2b$12$beMhOs0f3Moc.tF/9Cc1l.szxM1.9wDd9oUt0Aj8DPMGZVWH7rWNa	Ivana Georgievska	+389 79 901 234	51105815-266b-4651-a989-f3932d378c59	FREE	2026-04-27 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	\N	\N	t
b1ba0660-e3df-4b8c-b2a9-4414d104189e	nikola.andonov@gmail.com	$2b$12$beMhOs0f3Moc.tF/9Cc1l.szxM1.9wDd9oUt0Aj8DPMGZVWH7rWNa	Nikola Andonov	+389 70 012 345	30c4c444-11e9-455f-8ad2-63cb5c514096	FREE	2026-05-01 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	\N	\N	t
b18ee252-3735-4afb-9f52-804477425db6	tamara.mitrevska@gmail.com	$2b$12$beMhOs0f3Moc.tF/9Cc1l.szxM1.9wDd9oUt0Aj8DPMGZVWH7rWNa	Tamara Mitrevska	+389 71 123 456	8f92562d-b87f-43f8-beca-ce45ecf73630	FREE	2026-05-04 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	\N	\N	t
d81ec3ca-9c3c-4354-9386-3f7d8a91efe4	dejan.milosevski@gmail.com	$2b$12$beMhOs0f3Moc.tF/9Cc1l.szxM1.9wDd9oUt0Aj8DPMGZVWH7rWNa	Dejan Milosevski	+389 72 234 567	769f0050-b84e-4666-9f91-1bd47d1f0489	FREE	2026-05-06 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	\N	\N	t
c87953f6-a443-4fb7-9c6c-788ccefc95ca	kristina.ilievska@gmail.com	$2b$12$beMhOs0f3Moc.tF/9Cc1l.szxM1.9wDd9oUt0Aj8DPMGZVWH7rWNa	Kristina Ilievska	+389 73 345 678	d3f48f67-003d-471f-b93f-a89452865b34	FREE	2026-05-08 09:26:25.972172+00	2026-05-09 09:26:25.972172+00	\N	\N	t
7204b7eb-a53b-4d49-8e7e-d8bb4f3bea8a	superadmin@automarket.mk	$2b$12$Ct9XdbcsSoVkpkonkYkTFedblgV.p6EG3CD8g/1CDUJg7mH5RomDa	Super Admin	+389 70 000 001	2034be85-bde5-44a3-9e81-17d2dfedc4b4	FREE	2026-05-09 09:26:25.899871+00	2026-05-09 09:26:25.899871+00	\N	\N	t
b487c11a-1041-49b4-a94f-b41fab5bb7bb	admin@automarket.mk	$2b$12$jk0MghvCRZm3nYMoFOifUurPiFRTo4WZWuo04od7TEL5rj8KNmm/.	Admin User	+389 70 000 002	2034be85-bde5-44a3-9e81-17d2dfedc4b4	FREE	2026-05-09 09:26:25.899871+00	2026-05-09 09:26:25.899871+00	\N	\N	t
1231c400-0c5d-445d-8fd4-cfd562e46bf5	moderator@automarket.mk	$2b$12$P0cJrgdMUy70dLVIV4Q3cuqjEuEkGqjgtpnNdsV3YYUwlO18gqOJ2	Moderator User	+389 70 000 003	e6d535d5-3205-4b59-a5e7-3d80e7e4d1be	FREE	2026-05-09 09:26:25.899871+00	2026-05-09 09:26:25.899871+00	\N	\N	t
8d11d611-807e-408b-ba9b-fc6eb4b84b86	user@automarket.mk	$2b$12$D3bTw/GGM0C6sner3gcOUetV0mAcWVN/9iDbproquixuJ4fHIxGV6	Regular User	+389 70 000 004	e9849a12-2ad6-480b-bf87-3429d2565beb	FREE	2026-05-09 09:26:25.899871+00	2026-05-09 09:26:25.899871+00	\N	\N	t
3fb5443b-e25b-43e5-a677-0cd7b6c77f62	premium@automarket.mk	$2b$12$kyMGKTtlVQeQPdIYHvFRbeSl5GNf4iV/AcsitunD2TkXyjC.oTZRC	Premium User	+389 70 000 005	ac265a4a-2d9d-4ff7-b5aa-d15e41a96901	PREMIUM	2026-05-09 09:26:25.899871+00	2026-05-09 09:26:25.899871+00	\N	\N	t
4de9f430-653d-44b4-9993-ab276dddf190	kostoskidaniel13@gmail.com	$2a$12$SWgb1fAk9ADXbMV7XBGMmuWkqtMjN08YsbRSNTQ2Dx3QNtDhbsFBa	Daniel Kostoski	+38978896322	e6d535d5-3205-4b59-a5e7-3d80e7e4d1be	FREE	2026-09-17 22:59:30.926133+00	2026-09-17 22:59:30.926133+00	anonymousUser	\N	t
53598466-cec5-4763-a545-109c21d7fc9f	kostoskidaniel14@gmail.com	$2a$12$bXPh3kDvwjvCWV66tKYRfuOwHjuaHaGnzwI2NpJYZr06KOaPX0X6.	Daniel Kostoski	+38978896322	\N	FREE	2026-09-22 16:58:40.246624+00	2026-09-22 16:58:40.246624+00	anonymousUser	\N	t
\.


--
-- Name: auth_city_view auth_city_view_pkey; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.auth_city_view
    ADD CONSTRAINT auth_city_view_pkey PRIMARY KEY (id);


--
-- Name: auth_listing_view auth_listing_view_pkey; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.auth_listing_view
    ADD CONSTRAINT auth_listing_view_pkey PRIMARY KEY (listing_id);


--
-- Name: blog_author_view blog_author_view_pkey; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.blog_author_view
    ADD CONSTRAINT blog_author_view_pkey PRIMARY KEY (id);


--
-- Name: blogs blogs_pkey; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.blogs
    ADD CONSTRAINT blogs_pkey PRIMARY KEY (id);


--
-- Name: body_types body_types_name_key; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.body_types
    ADD CONSTRAINT body_types_name_key UNIQUE (name);


--
-- Name: body_types body_types_pkey; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.body_types
    ADD CONSTRAINT body_types_pkey PRIMARY KEY (id);


--
-- Name: car_brands car_brands_name_key; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.car_brands
    ADD CONSTRAINT car_brands_name_key UNIQUE (name);


--
-- Name: car_brands car_brands_pkey; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.car_brands
    ADD CONSTRAINT car_brands_pkey PRIMARY KEY (id);


--
-- Name: cities cities_name_key; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT cities_name_key UNIQUE (name);


--
-- Name: cities cities_pkey; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (id);


--
-- Name: condition_types condition_types_name_key; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.condition_types
    ADD CONSTRAINT condition_types_name_key UNIQUE (name);


--
-- Name: condition_types condition_types_pkey; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.condition_types
    ADD CONSTRAINT condition_types_pkey PRIMARY KEY (id);


--
-- Name: favorites favorites_pkey; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_pkey PRIMARY KEY (id);


--
-- Name: favorites favorites_user_id_listing_id_key; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_user_id_listing_id_key UNIQUE (user_id, listing_id);


--
-- Name: flyway_history_auth flyway_history_auth_pk; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.flyway_history_auth
    ADD CONSTRAINT flyway_history_auth_pk PRIMARY KEY (installed_rank);


--
-- Name: flyway_history_blog flyway_history_blog_pk; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.flyway_history_blog
    ADD CONSTRAINT flyway_history_blog_pk PRIMARY KEY (installed_rank);


--
-- Name: flyway_history_inquiry flyway_history_inquiry_pk; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.flyway_history_inquiry
    ADD CONSTRAINT flyway_history_inquiry_pk PRIMARY KEY (installed_rank);


--
-- Name: flyway_history_listing flyway_history_listing_pk; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.flyway_history_listing
    ADD CONSTRAINT flyway_history_listing_pk PRIMARY KEY (installed_rank);


--
-- Name: flyway_history_payment flyway_history_payment_pk; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.flyway_history_payment
    ADD CONSTRAINT flyway_history_payment_pk PRIMARY KEY (installed_rank);


--
-- Name: flyway_schema_history flyway_schema_history_pk; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.flyway_schema_history
    ADD CONSTRAINT flyway_schema_history_pk PRIMARY KEY (installed_rank);


--
-- Name: fuel_types fuel_types_name_key; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.fuel_types
    ADD CONSTRAINT fuel_types_name_key UNIQUE (name);


--
-- Name: fuel_types fuel_types_pkey; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.fuel_types
    ADD CONSTRAINT fuel_types_pkey PRIMARY KEY (id);


--
-- Name: inquiries inquiries_pkey; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.inquiries
    ADD CONSTRAINT inquiries_pkey PRIMARY KEY (id);


--
-- Name: inquiry_listing_view inquiry_listing_view_pkey; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.inquiry_listing_view
    ADD CONSTRAINT inquiry_listing_view_pkey PRIMARY KEY (id);


--
-- Name: inquiry_user_view inquiry_user_view_pkey; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.inquiry_user_view
    ADD CONSTRAINT inquiry_user_view_pkey PRIMARY KEY (id);


--
-- Name: listing_analytics listing_analytics_listing_id_date_key; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.listing_analytics
    ADD CONSTRAINT listing_analytics_listing_id_date_key UNIQUE (listing_id, date);


--
-- Name: listing_analytics listing_analytics_pkey; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.listing_analytics
    ADD CONSTRAINT listing_analytics_pkey PRIMARY KEY (id);


--
-- Name: listing_images listing_images_pkey; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.listing_images
    ADD CONSTRAINT listing_images_pkey PRIMARY KEY (id);


--
-- Name: listing_user_view listing_user_view_pkey; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.listing_user_view
    ADD CONSTRAINT listing_user_view_pkey PRIMARY KEY (id);


--
-- Name: listings listings_pkey; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.listings
    ADD CONSTRAINT listings_pkey PRIMARY KEY (id);


--
-- Name: listings listings_slug_key; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.listings
    ADD CONSTRAINT listings_slug_key UNIQUE (slug);


--
-- Name: outbox outbox_pkey; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.outbox
    ADD CONSTRAINT outbox_pkey PRIMARY KEY (id);


--
-- Name: payment_user_view payment_user_view_pkey; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.payment_user_view
    ADD CONSTRAINT payment_user_view_pkey PRIMARY KEY (id);


--
-- Name: processed_event processed_event_pkey; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.processed_event
    ADD CONSTRAINT processed_event_pkey PRIMARY KEY (event_id, consumer_group);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_key; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_key UNIQUE (token);


--
-- Name: roles roles_name_key; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key UNIQUE (name);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);


--
-- Name: subscriptions subscriptions_user_id_key; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_user_id_key UNIQUE (user_id);


--
-- Name: transmission_types transmission_types_name_key; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.transmission_types
    ADD CONSTRAINT transmission_types_name_key UNIQUE (name);


--
-- Name: transmission_types transmission_types_pkey; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.transmission_types
    ADD CONSTRAINT transmission_types_pkey PRIMARY KEY (id);


--
-- Name: favorites uki9yqqgg83yv72ftta12j4nfws; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT uki9yqqgg83yv72ftta12j4nfws UNIQUE (user_id, listing_id);


--
-- Name: listing_analytics uknwlf3anaiwxvxwle35kith8s7; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.listing_analytics
    ADD CONSTRAINT uknwlf3anaiwxvxwle35kith8s7 UNIQUE (listing_id, date);


--
-- Name: blogs uq_blogs_slug; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.blogs
    ADD CONSTRAINT uq_blogs_slug UNIQUE (slug);


--
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (user_id, role_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: flyway_history_auth_s_idx; Type: INDEX; Schema: public; Owner: automarket
--

CREATE INDEX flyway_history_auth_s_idx ON public.flyway_history_auth USING btree (success);


--
-- Name: flyway_history_blog_s_idx; Type: INDEX; Schema: public; Owner: automarket
--

CREATE INDEX flyway_history_blog_s_idx ON public.flyway_history_blog USING btree (success);


--
-- Name: flyway_history_inquiry_s_idx; Type: INDEX; Schema: public; Owner: automarket
--

CREATE INDEX flyway_history_inquiry_s_idx ON public.flyway_history_inquiry USING btree (success);


--
-- Name: flyway_history_listing_s_idx; Type: INDEX; Schema: public; Owner: automarket
--

CREATE INDEX flyway_history_listing_s_idx ON public.flyway_history_listing USING btree (success);


--
-- Name: flyway_history_payment_s_idx; Type: INDEX; Schema: public; Owner: automarket
--

CREATE INDEX flyway_history_payment_s_idx ON public.flyway_history_payment USING btree (success);


--
-- Name: flyway_schema_history_s_idx; Type: INDEX; Schema: public; Owner: automarket
--

CREATE INDEX flyway_schema_history_s_idx ON public.flyway_schema_history USING btree (success);


--
-- Name: idx_analytics_listing; Type: INDEX; Schema: public; Owner: automarket
--

CREATE INDEX idx_analytics_listing ON public.listing_analytics USING btree (listing_id, date DESC);


--
-- Name: idx_auth_listing_view_seller; Type: INDEX; Schema: public; Owner: automarket
--

CREATE INDEX idx_auth_listing_view_seller ON public.auth_listing_view USING btree (seller_id, approved);


--
-- Name: idx_blog_author_view_email; Type: INDEX; Schema: public; Owner: automarket
--

CREATE INDEX idx_blog_author_view_email ON public.blog_author_view USING btree (email);


--
-- Name: idx_blogs_created_at; Type: INDEX; Schema: public; Owner: automarket
--

CREATE INDEX idx_blogs_created_at ON public.blogs USING btree (created_at DESC);


--
-- Name: idx_blogs_published; Type: INDEX; Schema: public; Owner: automarket
--

CREATE INDEX idx_blogs_published ON public.blogs USING btree (published);


--
-- Name: idx_blogs_slug; Type: INDEX; Schema: public; Owner: automarket
--

CREATE INDEX idx_blogs_slug ON public.blogs USING btree (slug);


--
-- Name: idx_favorites_listing; Type: INDEX; Schema: public; Owner: automarket
--

CREATE INDEX idx_favorites_listing ON public.favorites USING btree (listing_id);


--
-- Name: idx_favorites_user; Type: INDEX; Schema: public; Owner: automarket
--

CREATE INDEX idx_favorites_user ON public.favorites USING btree (user_id, created_at DESC);


--
-- Name: idx_inquiries_listing; Type: INDEX; Schema: public; Owner: automarket
--

CREATE INDEX idx_inquiries_listing ON public.inquiries USING btree (listing_id);


--
-- Name: idx_inquiries_listing_id; Type: INDEX; Schema: public; Owner: automarket
--

CREATE INDEX idx_inquiries_listing_id ON public.inquiries USING btree (listing_id);


--
-- Name: idx_inquiries_sender; Type: INDEX; Schema: public; Owner: automarket
--

CREATE INDEX idx_inquiries_sender ON public.inquiries USING btree (sender_id);


--
-- Name: idx_inquiries_sender_id; Type: INDEX; Schema: public; Owner: automarket
--

CREATE INDEX idx_inquiries_sender_id ON public.inquiries USING btree (sender_id);


--
-- Name: idx_inquiry_listing_view_seller; Type: INDEX; Schema: public; Owner: automarket
--

CREATE INDEX idx_inquiry_listing_view_seller ON public.inquiry_listing_view USING btree (seller_id);


--
-- Name: idx_inquiry_user_view_email; Type: INDEX; Schema: public; Owner: automarket
--

CREATE INDEX idx_inquiry_user_view_email ON public.inquiry_user_view USING btree (email);


--
-- Name: idx_listing_images_listing; Type: INDEX; Schema: public; Owner: automarket
--

CREATE INDEX idx_listing_images_listing ON public.listing_images USING btree (listing_id, display_order);


--
-- Name: idx_listing_user_view_email; Type: INDEX; Schema: public; Owner: automarket
--

CREATE INDEX idx_listing_user_view_email ON public.listing_user_view USING btree (email);


--
-- Name: idx_listings_approved; Type: INDEX; Schema: public; Owner: automarket
--

CREATE INDEX idx_listings_approved ON public.listings USING btree (approved) WHERE (deleted_at IS NULL);


--
-- Name: idx_listings_attributes; Type: INDEX; Schema: public; Owner: automarket
--

CREATE INDEX idx_listings_attributes ON public.listings USING gin (attributes);


--
-- Name: idx_listings_brand; Type: INDEX; Schema: public; Owner: automarket
--

CREATE INDEX idx_listings_brand ON public.listings USING btree (car_brand_id) WHERE (deleted_at IS NULL);


--
-- Name: idx_listings_city; Type: INDEX; Schema: public; Owner: automarket
--

CREATE INDEX idx_listings_city ON public.listings USING btree (seller_id) WHERE (deleted_at IS NULL);


--
-- Name: idx_listings_deleted; Type: INDEX; Schema: public; Owner: automarket
--

CREATE INDEX idx_listings_deleted ON public.listings USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: idx_listings_featured; Type: INDEX; Schema: public; Owner: automarket
--

CREATE INDEX idx_listings_featured ON public.listings USING btree (featured, featured_until) WHERE (deleted_at IS NULL);


--
-- Name: idx_listings_price; Type: INDEX; Schema: public; Owner: automarket
--

CREATE INDEX idx_listings_price ON public.listings USING btree (price) WHERE ((deleted_at IS NULL) AND (approved = true));


--
-- Name: idx_listings_search; Type: INDEX; Schema: public; Owner: automarket
--

CREATE INDEX idx_listings_search ON public.listings USING gin (search_vector);


--
-- Name: idx_listings_seller; Type: INDEX; Schema: public; Owner: automarket
--

CREATE INDEX idx_listings_seller ON public.listings USING btree (seller_id);


--
-- Name: idx_listings_seller_id; Type: INDEX; Schema: public; Owner: automarket
--

CREATE INDEX idx_listings_seller_id ON public.listings USING btree (seller_id);


--
-- Name: idx_listings_slug; Type: INDEX; Schema: public; Owner: automarket
--

CREATE INDEX idx_listings_slug ON public.listings USING btree (slug);


--
-- Name: idx_listings_year; Type: INDEX; Schema: public; Owner: automarket
--

CREATE INDEX idx_listings_year ON public.listings USING btree (registration_year) WHERE (deleted_at IS NULL);


--
-- Name: idx_outbox_pending; Type: INDEX; Schema: public; Owner: automarket
--

CREATE INDEX idx_outbox_pending ON public.outbox USING btree (source_service, published_at, created_at);


--
-- Name: idx_payment_user_view_email; Type: INDEX; Schema: public; Owner: automarket
--

CREATE INDEX idx_payment_user_view_email ON public.payment_user_view USING btree (email);


--
-- Name: idx_refresh_tokens_token; Type: INDEX; Schema: public; Owner: automarket
--

CREATE INDEX idx_refresh_tokens_token ON public.refresh_tokens USING btree (token);


--
-- Name: idx_refresh_tokens_user_id; Type: INDEX; Schema: public; Owner: automarket
--

CREATE INDEX idx_refresh_tokens_user_id ON public.refresh_tokens USING btree (user_id);


--
-- Name: idx_subscriptions_stripe; Type: INDEX; Schema: public; Owner: automarket
--

CREATE INDEX idx_subscriptions_stripe ON public.subscriptions USING btree (stripe_subscription_id);


--
-- Name: idx_subscriptions_user; Type: INDEX; Schema: public; Owner: automarket
--

CREATE INDEX idx_subscriptions_user ON public.subscriptions USING btree (user_id);


--
-- Name: idx_users_deleted; Type: INDEX; Schema: public; Owner: automarket
--

CREATE INDEX idx_users_deleted ON public.users USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: automarket
--

CREATE INDEX idx_users_email ON public.users USING btree (email);


--
-- Name: listings listings_search_vector_trigger; Type: TRIGGER; Schema: public; Owner: automarket
--

CREATE TRIGGER listings_search_vector_trigger BEFORE INSERT OR UPDATE OF title, description, car_model ON public.listings FOR EACH ROW EXECUTE FUNCTION public.listings_search_vector_update();


--
-- Name: blogs blogs_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.blogs
    ADD CONSTRAINT blogs_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: favorites favorites_listing_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_listing_id_fkey FOREIGN KEY (listing_id) REFERENCES public.listings(id) ON DELETE CASCADE;


--
-- Name: favorites favorites_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: inquiries inquiries_listing_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.inquiries
    ADD CONSTRAINT inquiries_listing_id_fkey FOREIGN KEY (listing_id) REFERENCES public.listings(id) ON DELETE CASCADE;


--
-- Name: inquiries inquiries_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.inquiries
    ADD CONSTRAINT inquiries_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: listing_analytics listing_analytics_listing_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.listing_analytics
    ADD CONSTRAINT listing_analytics_listing_id_fkey FOREIGN KEY (listing_id) REFERENCES public.listings(id) ON DELETE CASCADE;


--
-- Name: listing_images listing_images_listing_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.listing_images
    ADD CONSTRAINT listing_images_listing_id_fkey FOREIGN KEY (listing_id) REFERENCES public.listings(id) ON DELETE CASCADE;


--
-- Name: listings listings_body_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.listings
    ADD CONSTRAINT listings_body_type_id_fkey FOREIGN KEY (body_type_id) REFERENCES public.body_types(id) ON DELETE SET NULL;


--
-- Name: listings listings_car_brand_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.listings
    ADD CONSTRAINT listings_car_brand_id_fkey FOREIGN KEY (car_brand_id) REFERENCES public.car_brands(id) ON DELETE SET NULL;


--
-- Name: listings listings_condition_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.listings
    ADD CONSTRAINT listings_condition_type_id_fkey FOREIGN KEY (condition_type_id) REFERENCES public.condition_types(id) ON DELETE SET NULL;


--
-- Name: listings listings_fuel_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.listings
    ADD CONSTRAINT listings_fuel_type_id_fkey FOREIGN KEY (fuel_type_id) REFERENCES public.fuel_types(id) ON DELETE SET NULL;


--
-- Name: listings listings_seller_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.listings
    ADD CONSTRAINT listings_seller_id_fkey FOREIGN KEY (seller_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: listings listings_transmission_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.listings
    ADD CONSTRAINT listings_transmission_type_id_fkey FOREIGN KEY (transmission_type_id) REFERENCES public.transmission_types(id) ON DELETE SET NULL;


--
-- Name: refresh_tokens refresh_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: subscriptions subscriptions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_roles user_roles_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- Name: user_roles user_roles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: users users_city_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: automarket
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_city_id_fkey FOREIGN KEY (city_id) REFERENCES public.cities(id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

\unrestrict keqxPYNw9xF0moiiURCOoD43I8j6YjAYkSKmHurYqUeOIt3abfImd79eIhbc62e

