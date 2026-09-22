-- AutoMarket Seed Data
-- Password for all seeded users: "Password123!" (BCrypt cost 12)
-- Existing user kostoskidaniel13@gmail.com is preserved

BEGIN;

-- Tables live in one schema per service; every name below is unique across them.
SET LOCAL search_path TO auth, listing, blog, inquiry, payment;

-- ============================================================
-- 1. ROLES
-- ============================================================
INSERT INTO roles (id, name) VALUES
  ('a0000000-0000-0000-0000-000000000001', 'ROLE_USER'),
  ('a0000000-0000-0000-0000-000000000002', 'ROLE_MODERATOR'),
  ('a0000000-0000-0000-0000-000000000003', 'ROLE_ADMIN')
ON CONFLICT DO NOTHING;

-- Assign ROLE_USER + ROLE_ADMIN to existing user
INSERT INTO user_roles (user_id, role_id) VALUES
  ('6d52517c-efc5-48fc-b256-a262b66027be', 'a0000000-0000-0000-0000-000000000001'),
  ('6d52517c-efc5-48fc-b256-a262b66027be', 'a0000000-0000-0000-0000-000000000003')
ON CONFLICT DO NOTHING;

-- ============================================================
-- 2. CITIES (Macedonian cities)
-- ============================================================
INSERT INTO cities (id, name) VALUES
  ('c0000000-0000-0000-0000-000000000001', 'Skopje'),
  ('c0000000-0000-0000-0000-000000000002', 'Bitola'),
  ('c0000000-0000-0000-0000-000000000003', 'Kumanovo'),
  ('c0000000-0000-0000-0000-000000000004', 'Prilep'),
  ('c0000000-0000-0000-0000-000000000005', 'Tetovo'),
  ('c0000000-0000-0000-0000-000000000006', 'Ohrid'),
  ('c0000000-0000-0000-0000-000000000007', 'Veles'),
  ('c0000000-0000-0000-0000-000000000008', 'Strumica'),
  ('c0000000-0000-0000-0000-000000000009', 'Stip'),
  ('c0000000-0000-0000-0000-00000000000a', 'Gostivar'),
  ('c0000000-0000-0000-0000-00000000000b', 'Kavadarci'),
  ('c0000000-0000-0000-0000-00000000000c', 'Kocani'),
  ('c0000000-0000-0000-0000-00000000000d', 'Struga'),
  ('c0000000-0000-0000-0000-00000000000e', 'Gevgelija'),
  ('c0000000-0000-0000-0000-00000000000f', 'Negotino')
ON CONFLICT DO NOTHING;

-- ============================================================
-- 3. CAR BRANDS
-- ============================================================
INSERT INTO car_brands (id, name) VALUES
  ('b0000000-0000-0000-0000-000000000001', 'Volkswagen'),
  ('b0000000-0000-0000-0000-000000000002', 'BMW'),
  ('b0000000-0000-0000-0000-000000000003', 'Mercedes-Benz'),
  ('b0000000-0000-0000-0000-000000000004', 'Audi'),
  ('b0000000-0000-0000-0000-000000000005', 'Opel'),
  ('b0000000-0000-0000-0000-000000000006', 'Toyota'),
  ('b0000000-0000-0000-0000-000000000007', 'Ford'),
  ('b0000000-0000-0000-0000-000000000008', 'Renault'),
  ('b0000000-0000-0000-0000-000000000009', 'Peugeot'),
  ('b0000000-0000-0000-0000-00000000000a', 'Fiat'),
  ('b0000000-0000-0000-0000-00000000000b', 'Hyundai'),
  ('b0000000-0000-0000-0000-00000000000c', 'Kia'),
  ('b0000000-0000-0000-0000-00000000000d', 'Skoda'),
  ('b0000000-0000-0000-0000-00000000000e', 'Seat'),
  ('b0000000-0000-0000-0000-00000000000f', 'Citroen'),
  ('b0000000-0000-0000-0000-000000000010', 'Mazda'),
  ('b0000000-0000-0000-0000-000000000011', 'Honda'),
  ('b0000000-0000-0000-0000-000000000012', 'Nissan'),
  ('b0000000-0000-0000-0000-000000000013', 'Volvo'),
  ('b0000000-0000-0000-0000-000000000014', 'Dacia')
ON CONFLICT DO NOTHING;

-- ============================================================
-- 4. FUEL TYPES
-- ============================================================
INSERT INTO fuel_types (id, name) VALUES
  ('f0000000-0000-0000-0000-000000000001', 'Petrol'),
  ('f0000000-0000-0000-0000-000000000002', 'Diesel'),
  ('f0000000-0000-0000-0000-000000000003', 'Electric'),
  ('f0000000-0000-0000-0000-000000000004', 'Hybrid'),
  ('f0000000-0000-0000-0000-000000000005', 'LPG')
ON CONFLICT DO NOTHING;

-- ============================================================
-- 5. BODY TYPES
-- ============================================================
INSERT INTO body_types (id, name) VALUES
  ('d0000000-0000-0000-0000-000000000001', 'Sedan'),
  ('d0000000-0000-0000-0000-000000000002', 'Hatchback'),
  ('d0000000-0000-0000-0000-000000000003', 'SUV'),
  ('d0000000-0000-0000-0000-000000000004', 'Wagon'),
  ('d0000000-0000-0000-0000-000000000005', 'Coupe'),
  ('d0000000-0000-0000-0000-000000000006', 'Convertible'),
  ('d0000000-0000-0000-0000-000000000007', 'Van'),
  ('d0000000-0000-0000-0000-000000000008', 'Pickup')
ON CONFLICT DO NOTHING;

-- ============================================================
-- 6. TRANSMISSION TYPES
-- ============================================================
INSERT INTO transmission_types (id, name) VALUES
  ('e0000000-0000-0000-0000-000000000001', 'Manual'),
  ('e0000000-0000-0000-0000-000000000002', 'Automatic'),
  ('e0000000-0000-0000-0000-000000000003', 'Semi-Automatic')
ON CONFLICT DO NOTHING;

-- ============================================================
-- 7. CONDITION TYPES
-- ============================================================
INSERT INTO condition_types (id, name) VALUES
  ('cc000000-0000-0000-0000-000000000001', 'New'),
  ('cc000000-0000-0000-0000-000000000002', 'Used'),
  ('cc000000-0000-0000-0000-000000000003', 'Certified Pre-Owned'),
  ('cc000000-0000-0000-0000-000000000004', 'For Parts')
ON CONFLICT DO NOTHING;

-- ============================================================
-- 8. USERS (30 new users)
-- BCrypt hash of "Password123!" with cost 12
-- ============================================================
INSERT INTO users (id, email, name, phone, password_hash, plan, city_id, created_at, updated_at) VALUES
  ('10000000-0000-0000-0000-000000000001', 'marko.petrov@example.com',     'Marko Petrov',       '+38970111001', '$2a$12$LJ3m4ys4uz0m6e9Pv5tXiOiR3k8bGqKCEwP7W2H.VzFGhN1mK0mSa', 'FREE',    'c0000000-0000-0000-0000-000000000001', NOW() - interval '90 days', NOW() - interval '2 days'),
  ('10000000-0000-0000-0000-000000000002', 'ana.stojanovic@example.com',   'Ana Stojanovic',     '+38970111002', '$2a$12$LJ3m4ys4uz0m6e9Pv5tXiOiR3k8bGqKCEwP7W2H.VzFGhN1mK0mSa', 'PREMIUM', 'c0000000-0000-0000-0000-000000000001', NOW() - interval '85 days', NOW() - interval '1 day'),
  ('10000000-0000-0000-0000-000000000003', 'igor.dimitrov@example.com',    'Igor Dimitrov',      '+38970111003', '$2a$12$LJ3m4ys4uz0m6e9Pv5tXiOiR3k8bGqKCEwP7W2H.VzFGhN1mK0mSa', 'FREE',    'c0000000-0000-0000-0000-000000000002', NOW() - interval '80 days', NOW() - interval '5 days'),
  ('10000000-0000-0000-0000-000000000004', 'elena.jovanova@example.com',   'Elena Jovanova',     '+38970111004', '$2a$12$LJ3m4ys4uz0m6e9Pv5tXiOiR3k8bGqKCEwP7W2H.VzFGhN1mK0mSa', 'FREE',    'c0000000-0000-0000-0000-000000000003', NOW() - interval '75 days', NOW() - interval '3 days'),
  ('10000000-0000-0000-0000-000000000005', 'stefan.nikolov@example.com',   'Stefan Nikolov',     '+38970111005', '$2a$12$LJ3m4ys4uz0m6e9Pv5tXiOiR3k8bGqKCEwP7W2H.VzFGhN1mK0mSa', 'PREMIUM', 'c0000000-0000-0000-0000-000000000004', NOW() - interval '70 days', NOW() - interval '1 day'),
  ('10000000-0000-0000-0000-000000000006', 'maja.trajkova@example.com',    'Maja Trajkova',      '+38970111006', '$2a$12$LJ3m4ys4uz0m6e9Pv5tXiOiR3k8bGqKCEwP7W2H.VzFGhN1mK0mSa', 'FREE',    'c0000000-0000-0000-0000-000000000005', NOW() - interval '65 days', NOW() - interval '4 days'),
  ('10000000-0000-0000-0000-000000000007', 'aleksandar.popov@example.com', 'Aleksandar Popov',   '+38970111007', '$2a$12$LJ3m4ys4uz0m6e9Pv5tXiOiR3k8bGqKCEwP7W2H.VzFGhN1mK0mSa', 'FREE',    'c0000000-0000-0000-0000-000000000006', NOW() - interval '60 days', NOW() - interval '2 days'),
  ('10000000-0000-0000-0000-000000000008', 'ivana.kostadinova@example.com','Ivana Kostadinova',  '+38970111008', '$2a$12$LJ3m4ys4uz0m6e9Pv5tXiOiR3k8bGqKCEwP7W2H.VzFGhN1mK0mSa', 'FREE',    'c0000000-0000-0000-0000-000000000007', NOW() - interval '55 days', NOW() - interval '6 days'),
  ('10000000-0000-0000-0000-000000000009', 'nikola.angelov@example.com',   'Nikola Angelov',     '+38970111009', '$2a$12$LJ3m4ys4uz0m6e9Pv5tXiOiR3k8bGqKCEwP7W2H.VzFGhN1mK0mSa', 'PREMIUM', 'c0000000-0000-0000-0000-000000000008', NOW() - interval '50 days', NOW() - interval '1 day'),
  ('10000000-0000-0000-0000-00000000000a', 'katerina.velkova@example.com', 'Katerina Velkova',   '+38970111010', '$2a$12$LJ3m4ys4uz0m6e9Pv5tXiOiR3k8bGqKCEwP7W2H.VzFGhN1mK0mSa', 'FREE',    'c0000000-0000-0000-0000-000000000009', NOW() - interval '48 days', NOW() - interval '3 days'),
  ('10000000-0000-0000-0000-00000000000b', 'dimitar.serafimov@example.com','Dimitar Serafimov',  '+38970111011', '$2a$12$LJ3m4ys4uz0m6e9Pv5tXiOiR3k8bGqKCEwP7W2H.VzFGhN1mK0mSa', 'FREE',    'c0000000-0000-0000-0000-00000000000a', NOW() - interval '45 days', NOW() - interval '2 days'),
  ('10000000-0000-0000-0000-00000000000c', 'simona.taseva@example.com',    'Simona Taseva',      '+38970111012', '$2a$12$LJ3m4ys4uz0m6e9Pv5tXiOiR3k8bGqKCEwP7W2H.VzFGhN1mK0mSa', 'FREE',    'c0000000-0000-0000-0000-00000000000b', NOW() - interval '42 days', NOW() - interval '5 days'),
  ('10000000-0000-0000-0000-00000000000d', 'bojan.ristov@example.com',     'Bojan Ristov',       '+38970111013', '$2a$12$LJ3m4ys4uz0m6e9Pv5tXiOiR3k8bGqKCEwP7W2H.VzFGhN1mK0mSa', 'PREMIUM', 'c0000000-0000-0000-0000-000000000001', NOW() - interval '40 days', NOW() - interval '1 day'),
  ('10000000-0000-0000-0000-00000000000e', 'milena.atanasova@example.com', 'Milena Atanasova',   '+38970111014', '$2a$12$LJ3m4ys4uz0m6e9Pv5tXiOiR3k8bGqKCEwP7W2H.VzFGhN1mK0mSa', 'FREE',    'c0000000-0000-0000-0000-000000000002', NOW() - interval '38 days', NOW() - interval '4 days'),
  ('10000000-0000-0000-0000-00000000000f', 'petar.georgiev@example.com',   'Petar Georgiev',     '+38970111015', '$2a$12$LJ3m4ys4uz0m6e9Pv5tXiOiR3k8bGqKCEwP7W2H.VzFGhN1mK0mSa', 'FREE',    'c0000000-0000-0000-0000-000000000003', NOW() - interval '35 days', NOW() - interval '2 days'),
  ('10000000-0000-0000-0000-000000000010', 'jana.mitrova@example.com',     'Jana Mitrova',       '+38970111016', '$2a$12$LJ3m4ys4uz0m6e9Pv5tXiOiR3k8bGqKCEwP7W2H.VzFGhN1mK0mSa', 'FREE',    'c0000000-0000-0000-0000-000000000004', NOW() - interval '33 days', NOW() - interval '3 days'),
  ('10000000-0000-0000-0000-000000000011', 'goran.pavlov@example.com',     'Goran Pavlov',       '+38970111017', '$2a$12$LJ3m4ys4uz0m6e9Pv5tXiOiR3k8bGqKCEwP7W2H.VzFGhN1mK0mSa', 'PREMIUM', 'c0000000-0000-0000-0000-000000000005', NOW() - interval '30 days', NOW() - interval '1 day'),
  ('10000000-0000-0000-0000-000000000012', 'sonja.ilievska@example.com',   'Sonja Ilievska',     '+38970111018', '$2a$12$LJ3m4ys4uz0m6e9Pv5tXiOiR3k8bGqKCEwP7W2H.VzFGhN1mK0mSa', 'FREE',    'c0000000-0000-0000-0000-000000000006', NOW() - interval '28 days', NOW() - interval '5 days'),
  ('10000000-0000-0000-0000-000000000013', 'viktor.manev@example.com',     'Viktor Manev',       '+38970111019', '$2a$12$LJ3m4ys4uz0m6e9Pv5tXiOiR3k8bGqKCEwP7W2H.VzFGhN1mK0mSa', 'FREE',    'c0000000-0000-0000-0000-000000000007', NOW() - interval '25 days', NOW() - interval '2 days'),
  ('10000000-0000-0000-0000-000000000014', 'kristina.blazeva@example.com', 'Kristina Blazeva',   '+38970111020', '$2a$12$LJ3m4ys4uz0m6e9Pv5tXiOiR3k8bGqKCEwP7W2H.VzFGhN1mK0mSa', 'FREE',    'c0000000-0000-0000-0000-000000000008', NOW() - interval '22 days', NOW() - interval '3 days'),
  ('10000000-0000-0000-0000-000000000015', 'darko.stojanov@example.com',   'Darko Stojanov',     '+38970111021', '$2a$12$LJ3m4ys4uz0m6e9Pv5tXiOiR3k8bGqKCEwP7W2H.VzFGhN1mK0mSa', 'FREE',    'c0000000-0000-0000-0000-000000000009', NOW() - interval '20 days', NOW() - interval '1 day'),
  ('10000000-0000-0000-0000-000000000016', 'tamara.todorova@example.com',  'Tamara Todorova',    '+38970111022', '$2a$12$LJ3m4ys4uz0m6e9Pv5tXiOiR3k8bGqKCEwP7W2H.VzFGhN1mK0mSa', 'PREMIUM', 'c0000000-0000-0000-0000-00000000000a', NOW() - interval '18 days', NOW() - interval '2 days'),
  ('10000000-0000-0000-0000-000000000017', 'dejan.ivanovski@example.com',  'Dejan Ivanovski',    '+38970111023', '$2a$12$LJ3m4ys4uz0m6e9Pv5tXiOiR3k8bGqKCEwP7W2H.VzFGhN1mK0mSa', 'FREE',    'c0000000-0000-0000-0000-00000000000b', NOW() - interval '15 days', NOW() - interval '4 days'),
  ('10000000-0000-0000-0000-000000000018', 'angela.spasova@example.com',   'Angela Spasova',     '+38970111024', '$2a$12$LJ3m4ys4uz0m6e9Pv5tXiOiR3k8bGqKCEwP7W2H.VzFGhN1mK0mSa', 'FREE',    'c0000000-0000-0000-0000-00000000000c', NOW() - interval '12 days', NOW() - interval '1 day'),
  ('10000000-0000-0000-0000-000000000019', 'tome.lazarov@example.com',     'Tome Lazarov',       '+38970111025', '$2a$12$LJ3m4ys4uz0m6e9Pv5tXiOiR3k8bGqKCEwP7W2H.VzFGhN1mK0mSa', 'FREE',    'c0000000-0000-0000-0000-00000000000d', NOW() - interval '10 days', NOW() - interval '2 days'),
  ('10000000-0000-0000-0000-00000000001a', 'vesna.mickovska@example.com',  'Vesna Mickovska',    '+38970111026', '$2a$12$LJ3m4ys4uz0m6e9Pv5tXiOiR3k8bGqKCEwP7W2H.VzFGhN1mK0mSa', 'PREMIUM', 'c0000000-0000-0000-0000-00000000000e', NOW() - interval '8 days',  NOW() - interval '1 day'),
  ('10000000-0000-0000-0000-00000000001b', 'robert.krstev@example.com',    'Robert Krstev',      '+38970111027', '$2a$12$LJ3m4ys4uz0m6e9Pv5tXiOiR3k8bGqKCEwP7W2H.VzFGhN1mK0mSa', 'FREE',    'c0000000-0000-0000-0000-00000000000f', NOW() - interval '7 days',  NOW() - interval '1 day'),
  ('10000000-0000-0000-0000-00000000001c', 'biljana.cvetanova@example.com','Biljana Cvetanova',  '+38970111028', '$2a$12$LJ3m4ys4uz0m6e9Pv5tXiOiR3k8bGqKCEwP7W2H.VzFGhN1mK0mSa', 'FREE',    'c0000000-0000-0000-0000-000000000001', NOW() - interval '5 days',  NOW() - interval '1 day'),
  ('10000000-0000-0000-0000-00000000001d', 'zoran.milosevski@example.com', 'Zoran Milosevski',   '+38970111029', '$2a$12$LJ3m4ys4uz0m6e9Pv5tXiOiR3k8bGqKCEwP7W2H.VzFGhN1mK0mSa', 'FREE',    'c0000000-0000-0000-0000-000000000002', NOW() - interval '3 days',  NOW() - interval '1 day'),
  ('10000000-0000-0000-0000-00000000001e', 'nadica.gruevska@example.com',  'Nadica Gruevska',    '+38970111030', '$2a$12$LJ3m4ys4uz0m6e9Pv5tXiOiR3k8bGqKCEwP7W2H.VzFGhN1mK0mSa', 'FREE',    'c0000000-0000-0000-0000-000000000003', NOW() - interval '1 day',   NOW() - interval '1 day')
ON CONFLICT DO NOTHING;

-- Assign ROLE_USER to all new users
INSERT INTO user_roles (user_id, role_id)
SELECT u.id, 'a0000000-0000-0000-0000-000000000001'::uuid
FROM users u WHERE u.id::text LIKE '10000000-%'
ON CONFLICT DO NOTHING;

-- Make user 0x0d a moderator too
INSERT INTO user_roles (user_id, role_id) VALUES
  ('10000000-0000-0000-0000-00000000000d', 'a0000000-0000-0000-0000-000000000002')
ON CONFLICT DO NOTHING;

-- Update existing user with a city
UPDATE users SET city_id = 'c0000000-0000-0000-0000-000000000001'
WHERE id = '6d52517c-efc5-48fc-b256-a262b66027be' AND city_id IS NULL;

-- ============================================================
-- 9. LISTINGS (50)
-- ============================================================
INSERT INTO listings (id, title, slug, description, price, kilometers, registration_year, car_model, kilowatts, num_doors, num_seats, approved, featured, seller_id, car_brand_id, fuel_type_id, body_type_id, transmission_type_id, condition_type_id, created_at, updated_at, created_by) VALUES
-- VW listings
('20000000-0000-0000-0000-000000000001', 'VW Golf 7 1.6 TDI Comfortline', 'vw-golf-7-1-6-tdi-comfortline', 'Well maintained Golf 7 with full service history. New tires, recently serviced. Non-smoker car.', 12500.00, 145000, 2016, 'Golf 7', 81, 5, 5, true, false, '10000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000001', 'f0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000001', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '30 days', NOW() - interval '2 days', 'marko.petrov@example.com'),

('20000000-0000-0000-0000-000000000002', 'VW Passat B8 2.0 TDI Highline', 'vw-passat-b8-2-0-tdi-highline', 'Top spec Passat with leather seats, panoramic roof, adaptive cruise control. Garage kept.', 18900.00, 98000, 2018, 'Passat B8', 110, 5, 5, true, true, '10000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000001', 'f0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000002', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '28 days', NOW() - interval '1 day', 'ana.stojanovic@example.com'),

('20000000-0000-0000-0000-000000000003', 'VW Polo 1.0 TSI Style', 'vw-polo-1-0-tsi-style', 'Perfect city car, very economical. Apple CarPlay, parking sensors front and rear.', 14200.00, 42000, 2020, 'Polo', 70, 5, 5, true, false, '10000000-0000-0000-0000-000000000003', 'b0000000-0000-0000-0000-000000000001', 'f0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000001', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '25 days', NOW() - interval '3 days', 'igor.dimitrov@example.com'),

('20000000-0000-0000-0000-000000000004', 'VW Tiguan 2.0 TDI 4Motion', 'vw-tiguan-2-0-tdi-4motion', 'Family SUV with all-wheel drive. Perfect for Macedonian roads. Full LED headlights.', 24500.00, 67000, 2019, 'Tiguan', 110, 5, 5, true, true, '10000000-0000-0000-0000-000000000004', 'b0000000-0000-0000-0000-000000000001', 'f0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000003', 'e0000000-0000-0000-0000-000000000002', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '22 days', NOW() - interval '1 day', 'elena.jovanova@example.com'),

-- BMW listings
('20000000-0000-0000-0000-000000000005', 'BMW 320d F30 Sport Line', 'bmw-320d-f30-sport-line', 'Sporty diesel sedan with M Sport steering wheel. Professional navigation, Harman Kardon sound.', 16800.00, 132000, 2015, '320d F30', 135, 4, 5, true, false, '10000000-0000-0000-0000-000000000005', 'b0000000-0000-0000-0000-000000000002', 'f0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000002', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '27 days', NOW() - interval '5 days', 'stefan.nikolov@example.com'),

('20000000-0000-0000-0000-000000000006', 'BMW X3 xDrive20d M Sport', 'bmw-x3-xdrive20d-m-sport', 'Luxury SUV with M Sport package, head-up display, ambient lighting. One owner.', 35500.00, 55000, 2020, 'X3', 140, 5, 5, true, true, '10000000-0000-0000-0000-000000000006', 'b0000000-0000-0000-0000-000000000002', 'f0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000003', 'e0000000-0000-0000-0000-000000000002', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '20 days', NOW() - interval '1 day', 'maja.trajkova@example.com'),

('20000000-0000-0000-0000-000000000007', 'BMW 520d G30 Luxury Line', 'bmw-520d-g30-luxury-line', 'Executive sedan in excellent condition. Leather Dakota, soft-close doors, wireless charging.', 28900.00, 89000, 2019, '520d G30', 140, 4, 5, true, false, '10000000-0000-0000-0000-000000000007', 'b0000000-0000-0000-0000-000000000002', 'f0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000002', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '18 days', NOW() - interval '2 days', 'aleksandar.popov@example.com'),

('20000000-0000-0000-0000-000000000008', 'BMW 118i F40 M Sport', 'bmw-118i-f40-m-sport', 'Sporty hatchback, great on fuel. M Sport bumpers, 18 inch wheels. Under warranty.', 27000.00, 28000, 2021, '118i F40', 103, 5, 5, true, false, '10000000-0000-0000-0000-000000000008', 'b0000000-0000-0000-0000-000000000002', 'f0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000002', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '15 days', NOW() - interval '1 day', 'ivana.kostadinova@example.com'),

-- Mercedes listings
('20000000-0000-0000-0000-000000000009', 'Mercedes C220d W205 AMG Line', 'mercedes-c220d-w205-amg-line', 'AMG Line exterior and interior, COMAND navigation, LED Intelligent headlights. Swiss import.', 22500.00, 110000, 2017, 'C220d W205', 125, 4, 5, true, false, '10000000-0000-0000-0000-000000000009', 'b0000000-0000-0000-0000-000000000003', 'f0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000002', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '26 days', NOW() - interval '4 days', 'nikola.angelov@example.com'),

('20000000-0000-0000-0000-00000000000a', 'Mercedes GLA 200 CDI', 'mercedes-gla-200-cdi', 'Compact premium crossover, perfect condition. Night package, panoramic roof.', 19800.00, 76000, 2018, 'GLA 200', 100, 5, 5, true, true, '10000000-0000-0000-0000-00000000000a', 'b0000000-0000-0000-0000-000000000003', 'f0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000003', 'e0000000-0000-0000-0000-000000000002', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '24 days', NOW() - interval '2 days', 'katerina.velkova@example.com'),

('20000000-0000-0000-0000-00000000000b', 'Mercedes E350d W213 Avantgarde', 'mercedes-e350d-w213-avantgarde', 'Powerful and luxurious. Multibeam LED, Burmester sound, air suspension. Full options.', 42000.00, 48000, 2020, 'E350d W213', 210, 4, 5, true, true, '10000000-0000-0000-0000-00000000000b', 'b0000000-0000-0000-0000-000000000003', 'f0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000002', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '14 days', NOW() - interval '1 day', 'dimitar.serafimov@example.com'),

-- Audi listings
('20000000-0000-0000-0000-00000000000c', 'Audi A4 2.0 TDI S-Line', 'audi-a4-2-0-tdi-s-line', 'S-Line package with sport suspension. Virtual cockpit, MMI navigation plus. Very clean.', 20500.00, 95000, 2018, 'A4 B9', 110, 4, 5, true, false, '10000000-0000-0000-0000-00000000000c', 'b0000000-0000-0000-0000-000000000004', 'f0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000001', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '21 days', NOW() - interval '3 days', 'simona.taseva@example.com'),

('20000000-0000-0000-0000-00000000000d', 'Audi Q5 2.0 TDI quattro', 'audi-q5-2-0-tdi-quattro', 'Premium SUV with quattro all-wheel drive. Matrix LED, virtual mirrors, Bang & Olufsen sound.', 38000.00, 42000, 2021, 'Q5', 150, 5, 5, true, true, '10000000-0000-0000-0000-00000000000d', 'b0000000-0000-0000-0000-000000000004', 'f0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000003', 'e0000000-0000-0000-0000-000000000002', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '12 days', NOW() - interval '1 day', 'bojan.ristov@example.com'),

('20000000-0000-0000-0000-00000000000e', 'Audi A3 Sportback 1.5 TFSI', 'audi-a3-sportback-1-5-tfsi', 'Latest model A3 Sportback. Digital cockpit, wireless Apple CarPlay, LED headlights.', 29500.00, 18000, 2022, 'A3 Sportback', 110, 5, 5, true, false, '10000000-0000-0000-0000-00000000000e', 'b0000000-0000-0000-0000-000000000004', 'f0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000002', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '10 days', NOW() - interval '2 days', 'milena.atanasova@example.com'),

-- Opel listings
('20000000-0000-0000-0000-00000000000f', 'Opel Astra K 1.6 CDTI Dynamic', 'opel-astra-k-1-6-cdti-dynamic', 'Reliable and economical. IntelliLink infotainment, climate control, cruise control.', 11500.00, 115000, 2017, 'Astra K', 81, 5, 5, true, false, '10000000-0000-0000-0000-00000000000f', 'b0000000-0000-0000-0000-000000000005', 'f0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000001', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '29 days', NOW() - interval '6 days', 'petar.georgiev@example.com'),

('20000000-0000-0000-0000-000000000010', 'Opel Insignia Grand Sport 2.0 CDTI', 'opel-insignia-grand-sport-2-0-cdti', 'Spacious sedan with great highway comfort. Matrix LED headlights, massage seats.', 15800.00, 88000, 2019, 'Insignia', 125, 5, 5, true, false, '10000000-0000-0000-0000-000000000010', 'b0000000-0000-0000-0000-000000000005', 'f0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000002', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '19 days', NOW() - interval '3 days', 'jana.mitrova@example.com'),

-- Toyota listings
('20000000-0000-0000-0000-000000000011', 'Toyota Corolla 1.8 Hybrid', 'toyota-corolla-1-8-hybrid', 'Ultra-reliable hybrid sedan. Amazing fuel economy - under 4L/100km. Toyota warranty until 2027.', 22000.00, 35000, 2021, 'Corolla', 90, 5, 5, true, true, '10000000-0000-0000-0000-000000000011', 'b0000000-0000-0000-0000-000000000006', 'f0000000-0000-0000-0000-000000000004', 'd0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000002', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '16 days', NOW() - interval '1 day', 'goran.pavlov@example.com'),

('20000000-0000-0000-0000-000000000012', 'Toyota RAV4 2.5 Hybrid AWD', 'toyota-rav4-2-5-hybrid-awd', 'Spacious hybrid SUV with all-wheel drive. JBL premium audio, panoramic roof. Like new.', 36500.00, 22000, 2022, 'RAV4', 160, 5, 5, true, true, '10000000-0000-0000-0000-000000000012', 'b0000000-0000-0000-0000-000000000006', 'f0000000-0000-0000-0000-000000000004', 'd0000000-0000-0000-0000-000000000003', 'e0000000-0000-0000-0000-000000000002', 'cc000000-0000-0000-0000-000000000003', NOW() - interval '8 days', NOW() - interval '1 day', 'sonja.ilievska@example.com'),

('20000000-0000-0000-0000-000000000013', 'Toyota Yaris 1.5 Hybrid Active', 'toyota-yaris-1-5-hybrid-active', 'Compact hybrid with outstanding city fuel economy. Safety Sense 3.0, touchscreen.', 17500.00, 15000, 2022, 'Yaris', 85, 5, 5, true, false, '10000000-0000-0000-0000-000000000013', 'b0000000-0000-0000-0000-000000000006', 'f0000000-0000-0000-0000-000000000004', 'd0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000002', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '6 days', NOW() - interval '1 day', 'viktor.manev@example.com'),

-- Ford listings
('20000000-0000-0000-0000-000000000014', 'Ford Focus 1.5 EcoBlue Titanium', 'ford-focus-1-5-ecoblue-titanium', 'Great driving dynamics, well equipped. SYNC3, heated seats, B&O sound system.', 16500.00, 62000, 2019, 'Focus', 88, 5, 5, true, false, '10000000-0000-0000-0000-000000000014', 'b0000000-0000-0000-0000-000000000007', 'f0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000001', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '23 days', NOW() - interval '4 days', 'kristina.blazeva@example.com'),

('20000000-0000-0000-0000-000000000015', 'Ford Kuga 2.0 TDCi AWD ST-Line', 'ford-kuga-2-0-tdci-awd-st-line', 'Sporty SUV with AWD. Adaptive cruise, lane keeping assist, panoramic roof.', 23800.00, 58000, 2020, 'Kuga', 140, 5, 5, true, false, '10000000-0000-0000-0000-000000000015', 'b0000000-0000-0000-0000-000000000007', 'f0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000003', 'e0000000-0000-0000-0000-000000000002', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '17 days', NOW() - interval '2 days', 'darko.stojanov@example.com'),

-- Renault listings
('20000000-0000-0000-0000-000000000016', 'Renault Megane 1.5 dCi Intens', 'renault-megane-1-5-dci-intens', 'French elegance with great comfort. Large touchscreen, full LED, auto parking.', 13500.00, 82000, 2018, 'Megane', 81, 5, 5, true, false, '10000000-0000-0000-0000-000000000016', 'b0000000-0000-0000-0000-000000000008', 'f0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000001', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '26 days', NOW() - interval '5 days', 'tamara.todorova@example.com'),

('20000000-0000-0000-0000-000000000017', 'Renault Clio 1.0 TCe Zen', 'renault-clio-1-0-tce-zen', 'Stylish supermini, very low running costs. 7 inch touchscreen, auto climate, cruise control.', 12800.00, 38000, 2020, 'Clio', 74, 5, 5, true, false, '10000000-0000-0000-0000-000000000017', 'b0000000-0000-0000-0000-000000000008', 'f0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000001', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '13 days', NOW() - interval '2 days', 'dejan.ivanovski@example.com'),

-- Peugeot
('20000000-0000-0000-0000-000000000018', 'Peugeot 3008 1.5 BlueHDi GT Line', 'peugeot-3008-1-5-bluehdi-gt-line', 'Award-winning SUV with i-Cockpit. Night vision, 360 camera, focal sound system.', 25500.00, 52000, 2020, '3008', 96, 5, 5, true, true, '10000000-0000-0000-0000-000000000018', 'b0000000-0000-0000-0000-000000000009', 'f0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000003', 'e0000000-0000-0000-0000-000000000002', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '11 days', NOW() - interval '1 day', 'angela.spasova@example.com'),

('20000000-0000-0000-0000-000000000019', 'Peugeot 308 1.5 BlueHDi Allure', 'peugeot-308-1-5-bluehdi-allure', 'Elegant hatchback with low fuel consumption. Digital i-Cockpit, CarPlay, lane assist.', 18200.00, 41000, 2021, '308', 96, 5, 5, true, false, '10000000-0000-0000-0000-000000000019', 'b0000000-0000-0000-0000-000000000009', 'f0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000002', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '9 days', NOW() - interval '2 days', 'tome.lazarov@example.com'),

-- Fiat
('20000000-0000-0000-0000-00000000001a', 'Fiat 500 1.2 Lounge', 'fiat-500-1-2-lounge', 'Iconic city car in pastel blue. Glass roof, Uconnect with CarPlay, parking sensors.', 9800.00, 55000, 2018, '500', 51, 3, 4, true, false, '10000000-0000-0000-0000-00000000001a', 'b0000000-0000-0000-0000-00000000000a', 'f0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000001', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '24 days', NOW() - interval '3 days', 'vesna.mickovska@example.com'),

-- Hyundai
('20000000-0000-0000-0000-00000000001b', 'Hyundai Tucson 1.6 CRDi Premium', 'hyundai-tucson-1-6-crdi-premium', 'Popular Korean SUV with 5-year warranty. Smart key, heated steering, JBL sound.', 21500.00, 68000, 2019, 'Tucson', 100, 5, 5, true, false, '10000000-0000-0000-0000-00000000001b', 'b0000000-0000-0000-0000-00000000000b', 'f0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000003', 'e0000000-0000-0000-0000-000000000002', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '20 days', NOW() - interval '4 days', 'robert.krstev@example.com'),

('20000000-0000-0000-0000-00000000001c', 'Hyundai i30 1.6 CRDi Style', 'hyundai-i30-1-6-crdi-style', 'Great value hatchback. Touchscreen navigation, wireless charging, smart cruise control.', 14800.00, 72000, 2019, 'i30', 100, 5, 5, true, false, '10000000-0000-0000-0000-00000000001c', 'b0000000-0000-0000-0000-00000000000b', 'f0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000001', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '15 days', NOW() - interval '2 days', 'biljana.cvetanova@example.com'),

-- Kia
('20000000-0000-0000-0000-00000000001d', 'Kia Sportage 1.6 CRDi GT-Line', 'kia-sportage-1-6-crdi-gt-line', 'Stylish SUV with 7-year warranty remaining. Panoramic roof, JBL audio, ventilated seats.', 24200.00, 45000, 2021, 'Sportage', 100, 5, 5, true, true, '10000000-0000-0000-0000-00000000001d', 'b0000000-0000-0000-0000-00000000000c', 'f0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000003', 'e0000000-0000-0000-0000-000000000002', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '7 days', NOW() - interval '1 day', 'zoran.milosevski@example.com'),

('20000000-0000-0000-0000-00000000001e', 'Kia Ceed 1.4 T-GDi GT-Line', 'kia-ceed-1-4-tgdi-gt-line', 'Sporty hatchback with turbo petrol engine. Digital cockpit, LED headlights, lane following.', 17900.00, 38000, 2020, 'Ceed', 103, 5, 5, true, false, '10000000-0000-0000-0000-00000000001e', 'b0000000-0000-0000-0000-00000000000c', 'f0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000001', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '5 days', NOW() - interval '1 day', 'nadica.gruevska@example.com'),

-- Skoda
('20000000-0000-0000-0000-00000000001f', 'Skoda Octavia 2.0 TDI Style', 'skoda-octavia-2-0-tdi-style', 'Best value for space. Massive boot, canton sound, virtual cockpit, Columbus navigation.', 19500.00, 78000, 2019, 'Octavia', 110, 5, 5, true, false, '10000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-00000000000d', 'f0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000004', 'e0000000-0000-0000-0000-000000000001', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '19 days', NOW() - interval '3 days', 'marko.petrov@example.com'),

('20000000-0000-0000-0000-000000000020', 'Skoda Superb 2.0 TDI Laurin & Klement', 'skoda-superb-2-0-tdi-laurin-klement', 'Top-of-the-line Superb with rear legroom rivaling luxury cars. Full options, Canton sound.', 24800.00, 65000, 2020, 'Superb', 140, 5, 5, true, false, '10000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-00000000000d', 'f0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000004', 'e0000000-0000-0000-0000-000000000002', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '16 days', NOW() - interval '2 days', 'ana.stojanovic@example.com'),

-- Seat
('20000000-0000-0000-0000-000000000021', 'Seat Leon FR 1.5 TSI', 'seat-leon-fr-1-5-tsi', 'Spanish hot hatch with sports seats, digital cockpit, progressive steering. Fun to drive.', 19200.00, 32000, 2021, 'Leon', 110, 5, 5, true, false, '10000000-0000-0000-0000-000000000003', 'b0000000-0000-0000-0000-00000000000e', 'f0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000001', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '11 days', NOW() - interval '2 days', 'igor.dimitrov@example.com'),

-- Citroen
('20000000-0000-0000-0000-000000000022', 'Citroen C3 Aircross 1.5 BlueHDi', 'citroen-c3-aircross-1-5-bluehdi', 'Quirky and comfortable crossover. Advanced comfort seats, grip control, modular boot.', 15500.00, 48000, 2020, 'C3 Aircross', 81, 5, 5, true, false, '10000000-0000-0000-0000-000000000004', 'b0000000-0000-0000-0000-00000000000f', 'f0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000003', 'e0000000-0000-0000-0000-000000000001', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '9 days', NOW() - interval '1 day', 'elena.jovanova@example.com'),

-- Mazda
('20000000-0000-0000-0000-000000000023', 'Mazda 3 2.0 Skyactiv-G', 'mazda-3-2-0-skyactiv-g', 'Beautiful design with premium interior. Bose sound, head-up display, 360 camera.', 21000.00, 36000, 2020, 'Mazda3', 90, 5, 5, true, false, '10000000-0000-0000-0000-000000000005', 'b0000000-0000-0000-0000-000000000010', 'f0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000002', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '13 days', NOW() - interval '3 days', 'stefan.nikolov@example.com'),

('20000000-0000-0000-0000-000000000024', 'Mazda CX-5 2.2 Skyactiv-D AWD', 'mazda-cx-5-2-2-skyactiv-d-awd', 'Premium feel without the premium price tag. All-wheel drive, leather, Bose, power tailgate.', 26800.00, 52000, 2020, 'CX-5', 135, 5, 5, true, false, '10000000-0000-0000-0000-000000000006', 'b0000000-0000-0000-0000-000000000010', 'f0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000003', 'e0000000-0000-0000-0000-000000000002', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '7 days', NOW() - interval '1 day', 'maja.trajkova@example.com'),

-- Honda
('20000000-0000-0000-0000-000000000025', 'Honda Civic 1.5 VTEC Turbo Sport', 'honda-civic-1-5-vtec-turbo-sport', 'Sporty and reliable. Turbocharged engine, Honda Sensing safety suite, dual-zone climate.', 20500.00, 55000, 2019, 'Civic', 134, 5, 5, true, false, '10000000-0000-0000-0000-000000000007', 'b0000000-0000-0000-0000-000000000011', 'f0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000001', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '18 days', NOW() - interval '4 days', 'aleksandar.popov@example.com'),

-- Nissan
('20000000-0000-0000-0000-000000000026', 'Nissan Qashqai 1.5 dCi Tekna', 'nissan-qashqai-1-5-dci-tekna', 'Best-selling crossover in Europe. ProPilot, panoramic roof, Bose audio, around-view monitor.', 19200.00, 72000, 2019, 'Qashqai', 85, 5, 5, true, false, '10000000-0000-0000-0000-000000000008', 'b0000000-0000-0000-0000-000000000012', 'f0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000003', 'e0000000-0000-0000-0000-000000000002', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '22 days', NOW() - interval '5 days', 'ivana.kostadinova@example.com'),

-- Volvo
('20000000-0000-0000-0000-000000000027', 'Volvo XC60 D4 Momentum', 'volvo-xc60-d4-momentum', 'Safest SUV on the market. Pilot Assist, 360 camera, Harman Kardon, air quality system.', 31000.00, 62000, 2019, 'XC60', 140, 5, 5, true, true, '10000000-0000-0000-0000-000000000009', 'b0000000-0000-0000-0000-000000000013', 'f0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000003', 'e0000000-0000-0000-0000-000000000002', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '14 days', NOW() - interval '2 days', 'nikola.angelov@example.com'),

('20000000-0000-0000-0000-000000000028', 'Volvo V60 D3 R-Design', 'volvo-v60-d3-r-design', 'Stylish estate with R-Design trim. Clean Scandinavian interior, pilot assist, large boot.', 23500.00, 85000, 2019, 'V60', 110, 5, 5, true, false, '10000000-0000-0000-0000-00000000000a', 'b0000000-0000-0000-0000-000000000013', 'f0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000004', 'e0000000-0000-0000-0000-000000000002', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '10 days', NOW() - interval '3 days', 'katerina.velkova@example.com'),

-- Dacia
('20000000-0000-0000-0000-000000000029', 'Dacia Duster 1.5 dCi 4x4 Prestige', 'dacia-duster-1-5-dci-4x4-prestige', 'Best value 4x4 SUV on the market. Multiview camera, keyless entry, climate control.', 16500.00, 42000, 2020, 'Duster', 85, 5, 5, true, false, '10000000-0000-0000-0000-00000000000b', 'b0000000-0000-0000-0000-000000000014', 'f0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000003', 'e0000000-0000-0000-0000-000000000001', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '12 days', NOW() - interval '2 days', 'dimitar.serafimov@example.com'),

('20000000-0000-0000-0000-00000000002a', 'Dacia Sandero Stepway 1.0 TCe', 'dacia-sandero-stepway-1-0-tce', 'Best-selling car in Europe for good reason. Affordable, practical, and well equipped.', 11200.00, 25000, 2022, 'Sandero Stepway', 67, 5, 5, true, false, '10000000-0000-0000-0000-00000000000c', 'b0000000-0000-0000-0000-000000000014', 'f0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000001', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '4 days', NOW() - interval '1 day', 'simona.taseva@example.com'),

-- More premium/interesting listings
('20000000-0000-0000-0000-00000000002b', 'BMW M340i xDrive', 'bmw-m340i-xdrive', 'Performance sedan with 374hp inline-6. M Sport diff, adaptive suspension, laser headlights.', 52000.00, 32000, 2021, 'M340i', 275, 4, 5, true, true, '10000000-0000-0000-0000-00000000000d', 'b0000000-0000-0000-0000-000000000002', 'f0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000002', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '6 days', NOW() - interval '1 day', 'bojan.ristov@example.com'),

('20000000-0000-0000-0000-00000000002c', 'Mercedes A250e Hybrid AMG Line', 'mercedes-a250e-hybrid-amg-line', 'Plug-in hybrid with 70km electric range. AMG styling, MBUX with AR navigation.', 34500.00, 18000, 2022, 'A250e', 160, 5, 5, true, false, '10000000-0000-0000-0000-00000000000e', 'b0000000-0000-0000-0000-000000000003', 'f0000000-0000-0000-0000-000000000004', 'd0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000002', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '3 days', NOW() - interval '1 day', 'milena.atanasova@example.com'),

('20000000-0000-0000-0000-00000000002d', 'Audi TT 2.0 TFSI S-Line', 'audi-tt-2-0-tfsi-s-line', 'Iconic sports coupe. Quattro AWD, magnetic ride, virtual cockpit, B&O sound system.', 28500.00, 48000, 2019, 'TT', 169, 2, 4, true, false, '10000000-0000-0000-0000-00000000000f', 'b0000000-0000-0000-0000-000000000004', 'f0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000005', 'e0000000-0000-0000-0000-000000000002', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '8 days', NOW() - interval '2 days', 'petar.georgiev@example.com'),

('20000000-0000-0000-0000-00000000002e', 'VW T-Roc 2.0 TSI R-Line 4Motion', 'vw-t-roc-2-0-tsi-r-line-4motion', 'Sporty compact SUV with 190hp and 4Motion AWD. Digital cockpit, Beats audio.', 27500.00, 35000, 2021, 'T-Roc', 140, 5, 5, true, false, '10000000-0000-0000-0000-000000000010', 'b0000000-0000-0000-0000-000000000001', 'f0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000003', 'e0000000-0000-0000-0000-000000000002', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '4 days', NOW() - interval '1 day', 'jana.mitrova@example.com'),

('20000000-0000-0000-0000-00000000002f', 'Opel Corsa-e Electric', 'opel-corsa-e-electric', 'All-electric city car with 337km range. Fast charging capable, 7 inch touchscreen.', 22500.00, 15000, 2022, 'Corsa-e', 100, 5, 5, true, false, '10000000-0000-0000-0000-000000000011', 'b0000000-0000-0000-0000-000000000005', 'f0000000-0000-0000-0000-000000000003', 'd0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000002', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '2 days', NOW() - interval '1 day', 'goran.pavlov@example.com'),

('20000000-0000-0000-0000-000000000030', 'Ford Mustang 2.3 EcoBoost', 'ford-mustang-2-3-ecoboost', 'American muscle with European efficiency. 290hp turbo, custom exhaust, sport suspension.', 35000.00, 28000, 2020, 'Mustang', 213, 2, 4, true, true, '10000000-0000-0000-0000-000000000012', 'b0000000-0000-0000-0000-000000000007', 'f0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000005', 'e0000000-0000-0000-0000-000000000001', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '6 days', NOW() - interval '1 day', 'sonja.ilievska@example.com'),

('20000000-0000-0000-0000-000000000031', 'Hyundai Kona Electric 64kWh', 'hyundai-kona-electric-64kwh', 'Long-range electric SUV - 484km range. Fast charging, heated everything, smart cruise.', 28000.00, 30000, 2021, 'Kona Electric', 150, 5, 5, true, false, '10000000-0000-0000-0000-000000000013', 'b0000000-0000-0000-0000-00000000000b', 'f0000000-0000-0000-0000-000000000003', 'd0000000-0000-0000-0000-000000000003', 'e0000000-0000-0000-0000-000000000002', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '5 days', NOW() - interval '1 day', 'viktor.manev@example.com'),

('20000000-0000-0000-0000-000000000032', 'Skoda Kodiaq 2.0 TDI 4x4 L&K', 'skoda-kodiaq-2-0-tdi-4x4-lk', 'Seven-seater SUV with premium L&K trim. Virtual cockpit, canton sound, 360 camera.', 32000.00, 55000, 2020, 'Kodiaq', 140, 5, 7, true, false, '10000000-0000-0000-0000-000000000014', 'b0000000-0000-0000-0000-00000000000d', 'f0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000003', 'e0000000-0000-0000-0000-000000000002', 'cc000000-0000-0000-0000-000000000002', NOW() - interval '3 days', NOW() - interval '1 day', 'kristina.blazeva@example.com')
ON CONFLICT DO NOTHING;

-- ============================================================
-- 10. LISTING ANALYTICS (for some popular listings)
-- ============================================================
INSERT INTO listing_analytics (id, listing_id, date, view_count, favorite_count, inquiry_count) VALUES
  (gen_random_uuid(), '20000000-0000-0000-0000-000000000002', CURRENT_DATE - 7, 45, 5, 2),
  (gen_random_uuid(), '20000000-0000-0000-0000-000000000002', CURRENT_DATE - 6, 38, 3, 1),
  (gen_random_uuid(), '20000000-0000-0000-0000-000000000002', CURRENT_DATE - 5, 52, 4, 3),
  (gen_random_uuid(), '20000000-0000-0000-0000-000000000002', CURRENT_DATE - 4, 30, 2, 0),
  (gen_random_uuid(), '20000000-0000-0000-0000-000000000002', CURRENT_DATE - 3, 41, 6, 2),
  (gen_random_uuid(), '20000000-0000-0000-0000-000000000004', CURRENT_DATE - 5, 33, 4, 1),
  (gen_random_uuid(), '20000000-0000-0000-0000-000000000004', CURRENT_DATE - 4, 28, 2, 1),
  (gen_random_uuid(), '20000000-0000-0000-0000-000000000004', CURRENT_DATE - 3, 35, 5, 2),
  (gen_random_uuid(), '20000000-0000-0000-0000-000000000006', CURRENT_DATE - 3, 55, 8, 3),
  (gen_random_uuid(), '20000000-0000-0000-0000-000000000006', CURRENT_DATE - 2, 48, 6, 2),
  (gen_random_uuid(), '20000000-0000-0000-0000-00000000000b', CURRENT_DATE - 4, 62, 9, 4),
  (gen_random_uuid(), '20000000-0000-0000-0000-00000000000b', CURRENT_DATE - 3, 44, 5, 2),
  (gen_random_uuid(), '20000000-0000-0000-0000-00000000000d', CURRENT_DATE - 2, 37, 4, 1),
  (gen_random_uuid(), '20000000-0000-0000-0000-000000000011', CURRENT_DATE - 3, 29, 3, 1),
  (gen_random_uuid(), '20000000-0000-0000-0000-000000000012', CURRENT_DATE - 2, 41, 5, 2),
  (gen_random_uuid(), '20000000-0000-0000-0000-00000000002b', CURRENT_DATE - 1, 78, 12, 5),
  (gen_random_uuid(), '20000000-0000-0000-0000-000000000030', CURRENT_DATE - 1, 65, 10, 4),
  (gen_random_uuid(), '20000000-0000-0000-0000-000000000027', CURRENT_DATE - 2, 34, 4, 2)
ON CONFLICT DO NOTHING;

-- ============================================================
-- 11. FAVORITES
-- ============================================================
INSERT INTO favorites (id, user_id, listing_id, created_at) VALUES
  (gen_random_uuid(), '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', NOW() - interval '10 days'),
  (gen_random_uuid(), '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-00000000000b', NOW() - interval '8 days'),
  (gen_random_uuid(), '10000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000004', NOW() - interval '12 days'),
  (gen_random_uuid(), '10000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-00000000002b', NOW() - interval '5 days'),
  (gen_random_uuid(), '10000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000002', NOW() - interval '15 days'),
  (gen_random_uuid(), '10000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000030', NOW() - interval '4 days'),
  (gen_random_uuid(), '10000000-0000-0000-0000-000000000006', '20000000-0000-0000-0000-000000000011', NOW() - interval '9 days'),
  (gen_random_uuid(), '10000000-0000-0000-0000-000000000007', '20000000-0000-0000-0000-000000000012', NOW() - interval '7 days'),
  (gen_random_uuid(), '10000000-0000-0000-0000-000000000008', '20000000-0000-0000-0000-00000000001d', NOW() - interval '3 days'),
  (gen_random_uuid(), '10000000-0000-0000-0000-000000000009', '20000000-0000-0000-0000-000000000027', NOW() - interval '6 days'),
  (gen_random_uuid(), '10000000-0000-0000-0000-00000000000a', '20000000-0000-0000-0000-000000000018', NOW() - interval '5 days'),
  (gen_random_uuid(), '10000000-0000-0000-0000-00000000000b', '20000000-0000-0000-0000-00000000000d', NOW() - interval '4 days'),
  (gen_random_uuid(), '10000000-0000-0000-0000-00000000000c', '20000000-0000-0000-0000-000000000006', NOW() - interval '11 days'),
  (gen_random_uuid(), '10000000-0000-0000-0000-00000000000d', '20000000-0000-0000-0000-000000000002', NOW() - interval '14 days'),
  (gen_random_uuid(), '10000000-0000-0000-0000-00000000000e', '20000000-0000-0000-0000-00000000002b', NOW() - interval '3 days'),
  (gen_random_uuid(), '6d52517c-efc5-48fc-b256-a262b66027be', '20000000-0000-0000-0000-000000000006', NOW() - interval '2 days'),
  (gen_random_uuid(), '6d52517c-efc5-48fc-b256-a262b66027be', '20000000-0000-0000-0000-00000000002b', NOW() - interval '1 day')
ON CONFLICT DO NOTHING;

-- ============================================================
-- 12. INQUIRIES
-- ============================================================
INSERT INTO inquiries (id, listing_id, sender_id, message, read_by_seller, created_at) VALUES
  (gen_random_uuid(), '20000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000003', 'Is the price negotiable? I can come see the car this weekend in Skopje.', true, NOW() - interval '20 days'),
  (gen_random_uuid(), '20000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000005', 'Does it have a full service history? Any accidents?', true, NOW() - interval '18 days'),
  (gen_random_uuid(), '20000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000001', 'Is the 4Motion working perfectly? Any issues with the DSG gearbox?', true, NOW() - interval '15 days'),
  (gen_random_uuid(), '20000000-0000-0000-0000-000000000006', '10000000-0000-0000-0000-00000000000c', 'Can you do a test drive? I am interested in buying it this month.', false, NOW() - interval '5 days'),
  (gen_random_uuid(), '20000000-0000-0000-0000-00000000000b', '10000000-0000-0000-0000-000000000001', 'What is the engine condition? How many km between oil changes?', true, NOW() - interval '10 days'),
  (gen_random_uuid(), '20000000-0000-0000-0000-00000000000b', '10000000-0000-0000-0000-000000000007', 'Would you accept 38000 EUR? I can pay in cash immediately.', false, NOW() - interval '3 days'),
  (gen_random_uuid(), '20000000-0000-0000-0000-00000000000d', '10000000-0000-0000-0000-000000000008', 'Is it available for viewing tomorrow? I am from Bitola.', true, NOW() - interval '8 days'),
  (gen_random_uuid(), '20000000-0000-0000-0000-000000000011', '10000000-0000-0000-0000-00000000000a', 'What is the actual fuel consumption in city driving?', true, NOW() - interval '12 days'),
  (gen_random_uuid(), '20000000-0000-0000-0000-000000000012', '10000000-0000-0000-0000-000000000004', 'Is the Toyota warranty transferable? How long does it last?', false, NOW() - interval '4 days'),
  (gen_random_uuid(), '20000000-0000-0000-0000-00000000002b', '10000000-0000-0000-0000-000000000003', 'Incredible car! Is the price firm or is there room for negotiation?', false, NOW() - interval '2 days'),
  (gen_random_uuid(), '20000000-0000-0000-0000-000000000030', '10000000-0000-0000-0000-000000000009', 'Does it have the performance package? What exhaust is installed?', false, NOW() - interval '1 day'),
  (gen_random_uuid(), '20000000-0000-0000-0000-000000000027', '10000000-0000-0000-0000-00000000000e', 'How is the maintenance cost for a Volvo XC60? Any expensive repairs done?', true, NOW() - interval '7 days')
ON CONFLICT DO NOTHING;

-- ============================================================
-- 13. BLOG POSTS
-- ============================================================
INSERT INTO blogs (id, title, slug, excerpt, content, author_id, published, created_at, updated_at, created_by) VALUES
  (gen_random_uuid(), 'Top 10 Tips for Buying a Used Car in Macedonia', 'top-10-tips-buying-used-car-macedonia',
   'Essential advice for first-time buyers navigating the Macedonian used car market.',
   E'# Top 10 Tips for Buying a Used Car in Macedonia\n\nBuying a used car can be daunting, especially if it''s your first time. Here are our top tips to help you make the right decision.\n\n## 1. Set a Realistic Budget\nDon''t forget to account for registration fees, insurance, and potential repairs. A good rule of thumb is to keep 10-15% of your budget for these costs.\n\n## 2. Research the Market\nBrowse AutoMarket listings to understand pricing for the make and model you''re interested in.\n\n## 3. Check the Vehicle History\nAlways ask for the full service history. Swiss and German imports typically have the best documentation.\n\n## 4. Inspect Before You Buy\nLook for signs of rust, especially under the car and around wheel arches. Macedonia''s roads can be tough on vehicles.\n\n## 5. Test Drive Thoroughly\nDrive on different road surfaces - city streets, highways, and rough roads. Listen for unusual sounds.\n\n## 6. Verify Registration Papers\nEnsure the vehicle''s documents match the seller''s identity. Check for any liens or outstanding debts.\n\n## 7. Get a Pre-Purchase Inspection\nHave an independent mechanic inspect the car. This small investment can save you thousands.\n\n## 8. Negotiate Wisely\nPrices on AutoMarket are often negotiable. Research comparable listings to strengthen your position.\n\n## 9. Consider Fuel Economy\nWith fuel prices in Macedonia, a diesel or hybrid might save you significantly on daily commutes.\n\n## 10. Trust Your Instincts\nIf something feels off about the deal or the seller, walk away. There are always more cars available.',
   '6d52517c-efc5-48fc-b256-a262b66027be', true, NOW() - interval '25 days', NOW() - interval '25 days', 'kostoskidaniel13@gmail.com'),

  (gen_random_uuid(), 'Electric Cars in Macedonia: Are They Worth It in 2026?', 'electric-cars-macedonia-worth-it-2026',
   'A comprehensive look at EV ownership in Macedonia - charging infrastructure, costs, and real-world range.',
   E'# Electric Cars in Macedonia: Are They Worth It in 2026?\n\nThe electric vehicle revolution is here, but is Macedonia ready? Let''s break it down.\n\n## Charging Infrastructure\nMacedonia has seen significant growth in charging stations over the past year. Major cities like Skopje, Bitola, and Ohrid now have multiple fast-charging locations.\n\n## Cost of Ownership\nWhile the upfront cost is higher, EVs save significantly on fuel and maintenance. With electricity prices in Macedonia, charging an EV costs roughly 1/4 of fueling a comparable petrol car.\n\n## Popular EV Models Available\n- Hyundai Kona Electric - excellent range at a reasonable price\n- Opel Corsa-e - perfect city EV\n- Tesla Model 3 - premium option with Supercharger network\n\n## Real-World Range\nIn Macedonian conditions (hilly terrain, varying temperatures), expect about 80-85% of the advertised range.\n\n## Government Incentives\nCurrently, Macedonia offers reduced customs duties on electric vehicles, making them more accessible.\n\n## Verdict\nIf you primarily drive within cities and have home charging available, an EV makes excellent financial sense in 2026.',
   '6d52517c-efc5-48fc-b256-a262b66027be', true, NOW() - interval '15 days', NOW() - interval '15 days', 'kostoskidaniel13@gmail.com'),

  (gen_random_uuid(), 'Best Family SUVs Under 25,000 EUR', 'best-family-suvs-under-25000-eur',
   'Our top picks for affordable family SUVs that combine space, safety, and value for Macedonian families.',
   E'# Best Family SUVs Under 25,000 EUR\n\nLooking for a family SUV that won''t break the bank? Here are our top picks available on AutoMarket.\n\n## 1. VW Tiguan 2.0 TDI\nThe Tiguan offers VW reliability with generous interior space. Excellent for both city and highway driving.\n\n## 2. Hyundai Tucson\nIncredible value with a long warranty. The latest model offers a premium feel at a non-premium price.\n\n## 3. Kia Sportage\nStylish design and a 7-year warranty make the Sportage a compelling choice.\n\n## 4. Dacia Duster 4x4\nFor those who need genuine off-road capability, the Duster 4x4 delivers at an unbeatable price.\n\n## 5. Ford Kuga\nGreat driving dynamics for an SUV. The ST-Line trim adds sporty styling.\n\n## What to Look For\n- At least 5 seats with good rear legroom\n- ISOFIX child seat mounts\n- Modern safety features (AEB, lane assist)\n- Reasonable boot space (450L+)\n\n## Our Recommendation\nThe Hyundai Tucson offers the best overall package, but the VW Tiguan wins on driving quality.',
   '10000000-0000-0000-0000-000000000002', true, NOW() - interval '10 days', NOW() - interval '10 days', 'ana.stojanovic@example.com'),

  (gen_random_uuid(), 'How to Prepare Your Car for Winter in Macedonia', 'prepare-car-winter-macedonia',
   'Essential winter preparation tips for Macedonian drivers - from tires to antifreeze.',
   E'# How to Prepare Your Car for Winter in Macedonia\n\nMacedonian winters can be harsh, especially in mountainous regions. Here''s how to prepare your car.\n\n## Winter Tires\nWinter tires are mandatory in Macedonia from November 15 to March 15. Choose tires with the M+S or 3PMSF marking. Budget 200-400 EUR for a set depending on size.\n\n## Battery Check\nCold weather is hard on batteries. Have your battery tested - if it''s more than 4 years old, consider replacing it.\n\n## Antifreeze\nEnsure your coolant mix can handle -25C or lower. Most workshops will test this for free.\n\n## Windshield Wipers and Fluid\nReplace worn wipers and fill up with winter washer fluid rated for -20C.\n\n## Emergency Kit\nKeep in your car: blanket, flashlight, jumper cables, ice scraper, and a small shovel.\n\n## Driving Tips\n- Reduce speed on wet and icy roads\n- Keep a greater following distance\n- Use engine braking on descents\n- Clear all snow from your car before driving\n\nStay safe this winter!',
   '10000000-0000-0000-0000-00000000000d', true, NOW() - interval '5 days', NOW() - interval '5 days', 'bojan.ristov@example.com'),

  (gen_random_uuid(), 'Diesel vs Petrol: Which is Better for Macedonian Roads?', 'diesel-vs-petrol-macedonian-roads',
   'An honest comparison of diesel and petrol engines for typical Macedonian driving patterns.',
   E'# Diesel vs Petrol: Which is Better for Macedonian Roads?\n\nThe eternal debate - diesel or petrol? The answer depends on your driving patterns.\n\n## Choose Diesel If:\n- You drive more than 20,000 km per year\n- Most of your driving is highway/intercity\n- You need strong torque for mountain roads\n- You tow a trailer regularly\n\n## Choose Petrol If:\n- You drive less than 15,000 km per year\n- Most of your driving is in the city\n- You prefer a smoother, quieter engine\n- The car will be used for short trips\n\n## Cost Comparison (2026 Prices)\n| Factor | Diesel | Petrol |\n|--------|--------|--------|\n| Fuel price/L | ~1.20 EUR | ~1.35 EUR |\n| Consumption (avg) | 5.5 L/100km | 7.0 L/100km |\n| Annual cost (15,000km) | 990 EUR | 1,417 EUR |\n| Service cost | Higher | Lower |\n\n## The Hybrid Alternative\nFor city drivers, a hybrid (especially Toyota''s system) offers the best of both worlds - excellent fuel economy without the diesel particulate concerns.\n\n## Our Verdict\nFor the average Macedonian driver doing mixed city/highway driving, a modern diesel remains the most economical choice. But if you''re city-only, consider hybrid.',
   '10000000-0000-0000-0000-000000000005', true, NOW() - interval '2 days', NOW() - interval '2 days', 'stefan.nikolov@example.com')
ON CONFLICT DO NOTHING;

COMMIT;
