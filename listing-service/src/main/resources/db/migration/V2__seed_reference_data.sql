-- ═══════════════════════════════════════════════════════════════════
-- listing-service V2: Seed reference data
--
-- Carried over from the decommissioned reference-service, whose reference
-- endpoints were merged into listing-service. Without this the reference
-- tables (cities, car_brands, fuel_types, ...) are created empty by V1 and
-- every dropdown in the frontend renders blank on a fresh deployment.
--
-- Unlike the reference-service original, ids are generated explicitly:
-- these tables declare `id UUID PRIMARY KEY` with no DEFAULT (Hibernate
-- assigns ids application-side), so a bare INSERT would violate NOT NULL.
-- gen_random_uuid() is built in from PostgreSQL 13 onwards.
--
-- ON CONFLICT (name) DO NOTHING keeps this safe to re-run and safe on a
-- database already seeded by the old monolith.
-- ═══════════════════════════════════════════════════════════════════

-- Cities (Macedonian cities)
INSERT INTO cities (id, name)
SELECT gen_random_uuid(), name FROM (VALUES
    ('Skopje'), ('Bitola'), ('Kumanovo'), ('Prilep'), ('Tetovo'),
    ('Veles'), ('Štip'), ('Ohrid'), ('Gostivar'), ('Strumica'),
    ('Kavadarci'), ('Kočani'), ('Kičevo'), ('Struga'), ('Radoviš'),
    ('Gevgelija'), ('Debar'), ('Kriva Palanka'), ('Negotino'), ('Vinica')
) AS v(name)
ON CONFLICT (name) DO NOTHING;

-- Car Brands
INSERT INTO car_brands (id, name)
SELECT gen_random_uuid(), name FROM (VALUES
    ('Audi'), ('BMW'), ('Mercedes-Benz'), ('Volkswagen'), ('Toyota'),
    ('Honda'), ('Ford'), ('Opel'), ('Peugeot'), ('Renault'),
    ('Skoda'), ('Seat'), ('Fiat'), ('Hyundai'), ('Kia'),
    ('Nissan'), ('Mazda'), ('Volvo'), ('Porsche'), ('Land Rover'),
    ('Jeep'), ('Mitsubishi'), ('Suzuki'), ('Subaru'), ('Lexus'),
    ('Alfa Romeo'), ('Citroën'), ('Dacia'), ('Mini'), ('Tesla')
) AS v(name)
ON CONFLICT (name) DO NOTHING;

-- Fuel Types
INSERT INTO fuel_types (id, name)
SELECT gen_random_uuid(), name FROM (VALUES
    ('Petrol'), ('Diesel'), ('Electric'), ('Hybrid'), ('Plug-in Hybrid'),
    ('LPG'), ('CNG'), ('Hydrogen')
) AS v(name)
ON CONFLICT (name) DO NOTHING;

-- Body Types
INSERT INTO body_types (id, name)
SELECT gen_random_uuid(), name FROM (VALUES
    ('Sedan'), ('Hatchback'), ('SUV'), ('Coupe'), ('Estate / Wagon'),
    ('Convertible'), ('Van'), ('Pickup'), ('Minivan'), ('Roadster')
) AS v(name)
ON CONFLICT (name) DO NOTHING;

-- Condition Types
INSERT INTO condition_types (id, name)
SELECT gen_random_uuid(), name FROM (VALUES
    ('New'), ('Used'), ('Certified Pre-Owned'), ('Salvage')
) AS v(name)
ON CONFLICT (name) DO NOTHING;

-- Transmission Types
INSERT INTO transmission_types (id, name)
SELECT gen_random_uuid(), name FROM (VALUES
    ('Manual'), ('Automatic'), ('Semi-Automatic'), ('CVT'), ('Dual-Clutch (DCT)')
) AS v(name)
ON CONFLICT (name) DO NOTHING;
