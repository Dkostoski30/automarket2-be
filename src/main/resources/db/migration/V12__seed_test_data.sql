-- ═══════════════════════════════════════════════════════════════════
-- V12: Seed test data — full marketplace population for development
-- ═══════════════════════════════════════════════════════════════════

-- ───────────────────────────────────────────────────────────────────
-- Extra test users (organic-looking accounts)
-- All passwords: Test1234!
-- BCrypt hash for "Test1234!" with strength 12
-- ───────────────────────────────────────────────────────────────────

INSERT INTO users (email, password_hash, name, phone, city_id, plan, enabled, created_at) VALUES
('marko.petrovski@gmail.com',  '$2b$12$beMhOs0f3Moc.tF/9Cc1l.szxM1.9wDd9oUt0Aj8DPMGZVWH7rWNa', 'Marko Petrovski',  '+389 71 234 567', (SELECT id FROM cities WHERE name = 'Skopje'),     'FREE', true, NOW() - INTERVAL '45 days'),
('ana.stojanova@yahoo.com',    '$2b$12$beMhOs0f3Moc.tF/9Cc1l.szxM1.9wDd9oUt0Aj8DPMGZVWH7rWNa', 'Ana Stojanova',    '+389 72 345 678', (SELECT id FROM cities WHERE name = 'Bitola'),     'PREMIUM', true, NOW() - INTERVAL '38 days'),
('igor.nikolov@hotmail.com',   '$2b$12$beMhOs0f3Moc.tF/9Cc1l.szxM1.9wDd9oUt0Aj8DPMGZVWH7rWNa', 'Igor Nikolov',     '+389 70 456 789', (SELECT id FROM cities WHERE name = 'Kumanovo'),   'FREE', true, NOW() - INTERVAL '30 days'),
('elena.dimova@gmail.com',     '$2b$12$beMhOs0f3Moc.tF/9Cc1l.szxM1.9wDd9oUt0Aj8DPMGZVWH7rWNa', 'Elena Dimova',     '+389 75 567 890', (SELECT id FROM cities WHERE name = 'Ohrid'),      'FREE', true, NOW() - INTERVAL '25 days'),
('stefan.trajkov@gmail.com',   '$2b$12$beMhOs0f3Moc.tF/9Cc1l.szxM1.9wDd9oUt0Aj8DPMGZVWH7rWNa', 'Stefan Trajkov',   '+389 76 678 901', (SELECT id FROM cities WHERE name = 'Prilep'),     'PREMIUM', true, NOW() - INTERVAL '22 days'),
('maja.kostadinova@gmail.com', '$2b$12$beMhOs0f3Moc.tF/9Cc1l.szxM1.9wDd9oUt0Aj8DPMGZVWH7rWNa', 'Maja Kostadinova', '+389 77 789 012', (SELECT id FROM cities WHERE name = 'Tetovo'),     'FREE', true, NOW() - INTERVAL '18 days'),
('aleksandar.ristov@gmail.com','$2b$12$beMhOs0f3Moc.tF/9Cc1l.szxM1.9wDd9oUt0Aj8DPMGZVWH7rWNa', 'Aleksandar Ristov','+389 78 890 123', (SELECT id FROM cities WHERE name = 'Veles'),      'FREE', true, NOW() - INTERVAL '15 days'),
('ivana.georgievska@gmail.com','$2b$12$beMhOs0f3Moc.tF/9Cc1l.szxM1.9wDd9oUt0Aj8DPMGZVWH7rWNa', 'Ivana Georgievska','+389 79 901 234', (SELECT id FROM cities WHERE name = 'Strumica'),   'FREE', true, NOW() - INTERVAL '12 days'),
('nikola.andonov@gmail.com',   '$2b$12$beMhOs0f3Moc.tF/9Cc1l.szxM1.9wDd9oUt0Aj8DPMGZVWH7rWNa', 'Nikola Andonov',   '+389 70 012 345', (SELECT id FROM cities WHERE name = 'Gostivar'),   'FREE', true, NOW() - INTERVAL '8 days'),
('tamara.mitrevska@gmail.com', '$2b$12$beMhOs0f3Moc.tF/9Cc1l.szxM1.9wDd9oUt0Aj8DPMGZVWH7rWNa', 'Tamara Mitrevska', '+389 71 123 456', (SELECT id FROM cities WHERE name = 'Kavadarci'),  'FREE', true, NOW() - INTERVAL '5 days'),
('dejan.milosevski@gmail.com', '$2b$12$beMhOs0f3Moc.tF/9Cc1l.szxM1.9wDd9oUt0Aj8DPMGZVWH7rWNa', 'Dejan Milosevski', '+389 72 234 567', (SELECT id FROM cities WHERE name = 'Štip'),       'FREE', true, NOW() - INTERVAL '3 days'),
('kristina.ilievska@gmail.com','$2b$12$beMhOs0f3Moc.tF/9Cc1l.szxM1.9wDd9oUt0Aj8DPMGZVWH7rWNa', 'Kristina Ilievska','+389 73 345 678', (SELECT id FROM cities WHERE name = 'Kočani'),     'FREE', true, NOW() - INTERVAL '1 day');

-- Assign ROLE_USER to all extra users
INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id FROM users u, roles r
WHERE r.name = 'ROLE_USER' AND u.email IN (
    'marko.petrovski@gmail.com','ana.stojanova@yahoo.com','igor.nikolov@hotmail.com',
    'elena.dimova@gmail.com','stefan.trajkov@gmail.com','maja.kostadinova@gmail.com',
    'aleksandar.ristov@gmail.com','ivana.georgievska@gmail.com','nikola.andonov@gmail.com',
    'tamara.mitrevska@gmail.com','dejan.milosevski@gmail.com','kristina.ilievska@gmail.com'
);

-- Assign cities to admin accounts
UPDATE users SET city_id = (SELECT id FROM cities WHERE name = 'Skopje')  WHERE email = 'superadmin@automarket.mk';
UPDATE users SET city_id = (SELECT id FROM cities WHERE name = 'Skopje')  WHERE email = 'admin@automarket.mk';
UPDATE users SET city_id = (SELECT id FROM cities WHERE name = 'Bitola')  WHERE email = 'moderator@automarket.mk';
UPDATE users SET city_id = (SELECT id FROM cities WHERE name = 'Ohrid')   WHERE email = 'user@automarket.mk';
UPDATE users SET city_id = (SELECT id FROM cities WHERE name = 'Tetovo')  WHERE email = 'premium@automarket.mk';

-- ───────────────────────────────────────────────────────────────────
-- Subscriptions (premium users)
-- ───────────────────────────────────────────────────────────────────

INSERT INTO subscriptions (user_id, plan, status, current_period_start, current_period_end) VALUES
((SELECT id FROM users WHERE email = 'premium@automarket.mk'),  'PREMIUM', 'ACTIVE',    NOW() - INTERVAL '15 days', NOW() + INTERVAL '15 days'),
((SELECT id FROM users WHERE email = 'ana.stojanova@yahoo.com'),'PREMIUM', 'ACTIVE',    NOW() - INTERVAL '10 days', NOW() + INTERVAL '20 days'),
((SELECT id FROM users WHERE email = 'stefan.trajkov@gmail.com'),'PREMIUM','ACTIVE',    NOW() - INTERVAL '5 days',  NOW() + INTERVAL '25 days')
ON CONFLICT (user_id) DO NOTHING;

-- ═══════════════════════════════════════════════════════════════════
-- LISTINGS (25 total)
-- ═══════════════════════════════════════════════════════════════════

-- ── 1. BMW 320d ─ premium, approved & featured ──────────────────
INSERT INTO listings (title, slug, description, price, condition_type_id, approved, featured, featured_until, seller_id, car_brand_id, car_model, registration_year, kilometers, fuel_type_id, body_type_id, transmission_type_id, num_doors, num_seats, kilowatts, created_by, created_at) VALUES
('BMW 320d M Sport 2021', 'bmw-320d-m-sport-2021',
 'Excellent condition BMW 320d with M Sport package. Full service history, one owner. LED headlights, navigation, heated seats, parking sensors. Recently serviced with new brake pads and tires. Non-smoker vehicle, always garaged.',
 28500.00, (SELECT id FROM condition_types WHERE name = 'Used'), true, true, NOW() + INTERVAL '30 days',
 (SELECT id FROM users WHERE email = 'premium@automarket.mk'),
 (SELECT id FROM car_brands WHERE name = 'BMW'), '320d M Sport', 2021, 45000,
 (SELECT id FROM fuel_types WHERE name = 'Diesel'), (SELECT id FROM body_types WHERE name = 'Sedan'),
 (SELECT id FROM transmission_types WHERE name = 'Automatic'), 4, 5, 140, 'premium@automarket.mk', NOW() - INTERVAL '12 days');

-- ── 2. VW Golf 8 ─ user, approved ──────────────────────────────
INSERT INTO listings (title, slug, description, price, condition_type_id, approved, seller_id, car_brand_id, car_model, registration_year, kilometers, fuel_type_id, body_type_id, transmission_type_id, num_doors, num_seats, kilowatts, created_by, created_at) VALUES
('Volkswagen Golf 8 1.5 TSI', 'volkswagen-golf-8-1-5-tsi',
 'Well-maintained Golf 8 with low mileage. Features include adaptive cruise control, digital cockpit, Apple CarPlay/Android Auto, and lane assist. Non-smoker, garage kept. Perfect condition, no scratches.',
 22000.00, (SELECT id FROM condition_types WHERE name = 'Used'), true,
 (SELECT id FROM users WHERE email = 'user@automarket.mk'),
 (SELECT id FROM car_brands WHERE name = 'Volkswagen'), 'Golf 8 1.5 TSI', 2022, 32000,
 (SELECT id FROM fuel_types WHERE name = 'Petrol'), (SELECT id FROM body_types WHERE name = 'Hatchback'),
 (SELECT id FROM transmission_types WHERE name = 'Manual'), 4, 5, 110, 'user@automarket.mk', NOW() - INTERVAL '20 days');

-- ── 3. Mercedes C220d ─ premium, approved ──────────────────────
INSERT INTO listings (title, slug, description, price, condition_type_id, approved, seller_id, car_brand_id, car_model, registration_year, kilometers, fuel_type_id, body_type_id, transmission_type_id, num_doors, num_seats, kilowatts, created_by, created_at) VALUES
('Mercedes-Benz C220d AMG Line', 'mercedes-benz-c220d-amg-line',
 'Stunning Mercedes C-Class with AMG Line exterior and interior. Burmester sound system, panoramic roof, 360 camera, multibeam LED. Immaculate condition. Full dealer service history.',
 35000.00, (SELECT id FROM condition_types WHERE name = 'Used'), true,
 (SELECT id FROM users WHERE email = 'premium@automarket.mk'),
 (SELECT id FROM car_brands WHERE name = 'Mercedes-Benz'), 'C220d AMG Line', 2022, 28000,
 (SELECT id FROM fuel_types WHERE name = 'Diesel'), (SELECT id FROM body_types WHERE name = 'Sedan'),
 (SELECT id FROM transmission_types WHERE name = 'Automatic'), 4, 5, 147, 'premium@automarket.mk', NOW() - INTERVAL '18 days');

-- ── 4. Toyota RAV4 Hybrid ─ marko, approved ────────────────────
INSERT INTO listings (title, slug, description, price, condition_type_id, approved, seller_id, car_brand_id, car_model, registration_year, kilometers, fuel_type_id, body_type_id, transmission_type_id, num_doors, num_seats, kilowatts, created_by, created_at) VALUES
('Toyota RAV4 2.5 Hybrid AWD', 'toyota-rav4-2-5-hybrid-awd',
 'Reliable Toyota RAV4 Hybrid with all-wheel drive. Great fuel economy, spacious interior, Toyota Safety Sense suite. Perfect family SUV with plenty of cargo space. One owner from new.',
 31000.00, (SELECT id FROM condition_types WHERE name = 'Used'), true,
 (SELECT id FROM users WHERE email = 'marko.petrovski@gmail.com'),
 (SELECT id FROM car_brands WHERE name = 'Toyota'), 'RAV4 2.5 Hybrid', 2021, 52000,
 (SELECT id FROM fuel_types WHERE name = 'Hybrid'), (SELECT id FROM body_types WHERE name = 'SUV'),
 (SELECT id FROM transmission_types WHERE name = 'CVT'), 4, 5, 160, 'marko.petrovski@gmail.com', NOW() - INTERVAL '25 days');

-- ── 5. Audi A3 ─ ana, approved & featured ──────────────────────
INSERT INTO listings (title, slug, description, price, condition_type_id, approved, featured, featured_until, seller_id, car_brand_id, car_model, registration_year, kilometers, fuel_type_id, body_type_id, transmission_type_id, num_doors, num_seats, kilowatts, created_by, created_at) VALUES
('Audi A3 Sportback 35 TFSI S-Line', 'audi-a3-sportback-35-tfsi',
 'Sporty Audi A3 Sportback with S-line package. Virtual cockpit, MMI navigation, Bang & Olufsen sound, sport suspension. Very economical yet fun to drive. Just had major service.',
 26500.00, (SELECT id FROM condition_types WHERE name = 'Used'), true, true, NOW() + INTERVAL '20 days',
 (SELECT id FROM users WHERE email = 'ana.stojanova@yahoo.com'),
 (SELECT id FROM car_brands WHERE name = 'Audi'), 'A3 Sportback 35 TFSI', 2022, 25000,
 (SELECT id FROM fuel_types WHERE name = 'Petrol'), (SELECT id FROM body_types WHERE name = 'Hatchback'),
 (SELECT id FROM transmission_types WHERE name = 'Automatic'), 4, 5, 110, 'ana.stojanova@yahoo.com', NOW() - INTERVAL '14 days');

-- ── 6. Skoda Octavia ─ moderator, approved ─────────────────────
INSERT INTO listings (title, slug, description, price, condition_type_id, approved, seller_id, car_brand_id, car_model, registration_year, kilometers, fuel_type_id, body_type_id, transmission_type_id, num_doors, num_seats, kilowatts, created_by, created_at) VALUES
('Skoda Octavia Combi 2.0 TDI', 'skoda-octavia-combi-2-0-tdi',
 'Practical and spacious Skoda Octavia estate. Massive boot, comfortable ride, great on motorways. Columbus navigation, heated seats, parking assist. Ideal family car.',
 19500.00, (SELECT id FROM condition_types WHERE name = 'Used'), true,
 (SELECT id FROM users WHERE email = 'moderator@automarket.mk'),
 (SELECT id FROM car_brands WHERE name = 'Skoda'), 'Octavia Combi 2.0 TDI', 2020, 78000,
 (SELECT id FROM fuel_types WHERE name = 'Diesel'), (SELECT id FROM body_types WHERE name = 'Estate/Wagon'),
 (SELECT id FROM transmission_types WHERE name = 'Dual-Clutch (DCT)'), 4, 5, 110, 'moderator@automarket.mk', NOW() - INTERVAL '30 days');

-- ── 7. Tesla Model 3 ─ stefan, approved & featured ─────────────
INSERT INTO listings (title, slug, description, price, condition_type_id, approved, featured, featured_until, seller_id, car_brand_id, car_model, registration_year, kilometers, fuel_type_id, body_type_id, transmission_type_id, num_doors, num_seats, kilowatts, created_by, created_at) VALUES
('Tesla Model 3 Long Range 2023', 'tesla-model-3-long-range-2023',
 'Tesla Model 3 Long Range with autopilot. 580 km range, supercharger access, premium white interior. Over-the-air updates, sentry mode, dashcam. Battery health at 97%. The future of driving.',
 42000.00, (SELECT id FROM condition_types WHERE name = 'Used'), true, true, NOW() + INTERVAL '14 days',
 (SELECT id FROM users WHERE email = 'stefan.trajkov@gmail.com'),
 (SELECT id FROM car_brands WHERE name = 'Tesla'), 'Model 3 Long Range', 2023, 15000,
 (SELECT id FROM fuel_types WHERE name = 'Electric'), (SELECT id FROM body_types WHERE name = 'Sedan'),
 (SELECT id FROM transmission_types WHERE name = 'Automatic'), 4, 5, 258, 'stefan.trajkov@gmail.com', NOW() - INTERVAL '7 days');

-- ── 8. Opel Corsa ─ elena, NOT approved (pending) ──────────────
INSERT INTO listings (title, slug, description, price, condition_type_id, approved, seller_id, car_brand_id, car_model, registration_year, kilometers, fuel_type_id, body_type_id, transmission_type_id, num_doors, num_seats, kilowatts, created_by, created_at) VALUES
('Opel Corsa 1.2 Turbo 2023', 'opel-corsa-1-2-turbo-2023',
 'Brand new shape Opel Corsa with turbo engine. Perfect city car with low running costs. Touchscreen infotainment, rear parking sensors, LED lights. Great first car.',
 16500.00, (SELECT id FROM condition_types WHERE name = 'Used'), false,
 (SELECT id FROM users WHERE email = 'elena.dimova@gmail.com'),
 (SELECT id FROM car_brands WHERE name = 'Opel'), 'Corsa 1.2 Turbo', 2023, 8000,
 (SELECT id FROM fuel_types WHERE name = 'Petrol'), (SELECT id FROM body_types WHERE name = 'Hatchback'),
 (SELECT id FROM transmission_types WHERE name = 'Manual'), 4, 5, 74, 'elena.dimova@gmail.com', NOW() - INTERVAL '2 days');

-- ── 9. Ford Ranger ─ igor, approved ────────────────────────────
INSERT INTO listings (title, slug, description, price, condition_type_id, approved, seller_id, car_brand_id, car_model, registration_year, kilometers, fuel_type_id, body_type_id, transmission_type_id, num_doors, num_seats, kilowatts, created_by, created_at) VALUES
('Ford Ranger Wildtrak 2.0 EcoBlue', 'ford-ranger-wildtrak-2-0-ecoblue',
 'Tough and capable Ford Ranger Wildtrak. 4x4, diff lock, roll bar, bed liner, tonneau cover. SYNC 3 navigation, heated seats, reversing camera. Ready for work and play.',
 38000.00, (SELECT id FROM condition_types WHERE name = 'Used'), true,
 (SELECT id FROM users WHERE email = 'igor.nikolov@hotmail.com'),
 (SELECT id FROM car_brands WHERE name = 'Ford'), 'Ranger Wildtrak 2.0', 2022, 35000,
 (SELECT id FROM fuel_types WHERE name = 'Diesel'), (SELECT id FROM body_types WHERE name = 'Pickup'),
 (SELECT id FROM transmission_types WHERE name = 'Automatic'), 4, 5, 156, 'igor.nikolov@hotmail.com', NOW() - INTERVAL '22 days');

-- ── 10. Dacia Sandero ─ user, approved ─────────────────────────
INSERT INTO listings (title, slug, description, price, condition_type_id, approved, seller_id, car_brand_id, car_model, registration_year, kilometers, fuel_type_id, body_type_id, transmission_type_id, num_doors, num_seats, kilowatts, created_by, created_at) VALUES
('Dacia Sandero Stepway TCe 90', 'dacia-sandero-stepway-tce-90',
 'Affordable and practical Dacia Sandero Stepway. Raised ride height, roof rails, 8-inch touchscreen with Apple CarPlay. Best value for money on the market. Low insurance group.',
 12500.00, (SELECT id FROM condition_types WHERE name = 'New'), true,
 (SELECT id FROM users WHERE email = 'user@automarket.mk'),
 (SELECT id FROM car_brands WHERE name = 'Dacia'), 'Sandero Stepway TCe 90', 2024, 0,
 (SELECT id FROM fuel_types WHERE name = 'Petrol'), (SELECT id FROM body_types WHERE name = 'Hatchback'),
 (SELECT id FROM transmission_types WHERE name = 'Manual'), 4, 5, 67, 'user@automarket.mk', NOW() - INTERVAL '10 days');

-- ── 11. Porsche Cayenne ─ stefan, approved & featured ──────────
INSERT INTO listings (title, slug, description, price, condition_type_id, approved, featured, featured_until, seller_id, car_brand_id, car_model, registration_year, kilometers, fuel_type_id, body_type_id, transmission_type_id, num_doors, num_seats, kilowatts, created_by, created_at) VALUES
('Porsche Cayenne S 2.9 V6 Biturbo', 'porsche-cayenne-s-2-9-v6-biturbo',
 'Stunning Porsche Cayenne S in Carrara White. Full leather interior, panoramic roof, BOSE surround, air suspension, Sport Chrono package. Every option ticked. Full Porsche service history.',
 72000.00, (SELECT id FROM condition_types WHERE name = 'Used'), true, true, NOW() + INTERVAL '25 days',
 (SELECT id FROM users WHERE email = 'stefan.trajkov@gmail.com'),
 (SELECT id FROM car_brands WHERE name = 'Porsche'), 'Cayenne S 2.9 V6', 2021, 38000,
 (SELECT id FROM fuel_types WHERE name = 'Petrol'), (SELECT id FROM body_types WHERE name = 'SUV'),
 (SELECT id FROM transmission_types WHERE name = 'Automatic'), 4, 5, 324, 'stefan.trajkov@gmail.com', NOW() - INTERVAL '5 days');

-- ── 12. Renault Clio ─ maja, approved ──────────────────────────
INSERT INTO listings (title, slug, description, price, condition_type_id, approved, seller_id, car_brand_id, car_model, registration_year, kilometers, fuel_type_id, body_type_id, transmission_type_id, num_doors, num_seats, kilowatts, created_by, created_at) VALUES
('Renault Clio 1.0 TCe Intens', 'renault-clio-1-0-tce-intens',
 'Stylish Renault Clio in Diamond Black. 9.3 inch touchscreen, digital instrument cluster, wireless charging, 360 camera. Extremely low fuel consumption. Lady owner, immaculate.',
 14800.00, (SELECT id FROM condition_types WHERE name = 'Used'), true,
 (SELECT id FROM users WHERE email = 'maja.kostadinova@gmail.com'),
 (SELECT id FROM car_brands WHERE name = 'Renault'), 'Clio 1.0 TCe Intens', 2022, 19000,
 (SELECT id FROM fuel_types WHERE name = 'Petrol'), (SELECT id FROM body_types WHERE name = 'Hatchback'),
 (SELECT id FROM transmission_types WHERE name = 'Manual'), 4, 5, 74, 'maja.kostadinova@gmail.com', NOW() - INTERVAL '16 days');

-- ── 13. Hyundai Tucson ─ marko, approved ───────────────────────
INSERT INTO listings (title, slug, description, price, condition_type_id, approved, seller_id, car_brand_id, car_model, registration_year, kilometers, fuel_type_id, body_type_id, transmission_type_id, num_doors, num_seats, kilowatts, created_by, created_at) VALUES
('Hyundai Tucson 1.6 T-GDI Hybrid', 'hyundai-tucson-1-6-tgdi-hybrid',
 'New generation Hyundai Tucson with hybrid powertrain. Striking design, 10.25 inch screens, Krell premium audio, blind spot cameras. 5 year warranty remaining. Like new condition.',
 29500.00, (SELECT id FROM condition_types WHERE name = 'Certified Pre-Owned'), true,
 (SELECT id FROM users WHERE email = 'marko.petrovski@gmail.com'),
 (SELECT id FROM car_brands WHERE name = 'Hyundai'), 'Tucson 1.6 T-GDI Hybrid', 2023, 12000,
 (SELECT id FROM fuel_types WHERE name = 'Hybrid'), (SELECT id FROM body_types WHERE name = 'SUV'),
 (SELECT id FROM transmission_types WHERE name = 'Automatic'), 4, 5, 169, 'marko.petrovski@gmail.com', NOW() - INTERVAL '9 days');

-- ── 14. Fiat 500e ─ ivana, approved ────────────────────────────
INSERT INTO listings (title, slug, description, price, condition_type_id, approved, seller_id, car_brand_id, car_model, registration_year, kilometers, fuel_type_id, body_type_id, transmission_type_id, num_doors, num_seats, kilowatts, created_by, created_at) VALUES
('Fiat 500e La Prima 42 kWh', 'fiat-500e-la-prima-42kwh',
 'Adorable electric Fiat 500 in Celestial Blue. Top spec La Prima with glass roof, leather seats, Level 2 autonomous driving, Harman Kardon audio. 320 km range. Perfect city EV.',
 24000.00, (SELECT id FROM condition_types WHERE name = 'Used'), true,
 (SELECT id FROM users WHERE email = 'ivana.georgievska@gmail.com'),
 (SELECT id FROM car_brands WHERE name = 'Fiat'), '500e La Prima 42 kWh', 2023, 9500,
 (SELECT id FROM fuel_types WHERE name = 'Electric'), (SELECT id FROM body_types WHERE name = 'Convertible'),
 (SELECT id FROM transmission_types WHERE name = 'Automatic'), 2, 4, 87, 'ivana.georgievska@gmail.com', NOW() - INTERVAL '11 days');

-- ── 15. Volvo XC60 ─ ana, approved ─────────────────────────────
INSERT INTO listings (title, slug, description, price, condition_type_id, approved, seller_id, car_brand_id, car_model, registration_year, kilometers, fuel_type_id, body_type_id, transmission_type_id, num_doors, num_seats, kilowatts, created_by, created_at) VALUES
('Volvo XC60 B5 Inscription AWD', 'volvo-xc60-b5-inscription-awd',
 'Premium Volvo XC60 in Crystal White. Inscription trim with Orrefors crystal gear knob, Bowers & Wilkins audio, 360 camera, pilot assist. Swedish luxury at its finest. Full Volvo history.',
 41000.00, (SELECT id FROM condition_types WHERE name = 'Used'), true,
 (SELECT id FROM users WHERE email = 'ana.stojanova@yahoo.com'),
 (SELECT id FROM car_brands WHERE name = 'Volvo'), 'XC60 B5 Inscription', 2022, 31000,
 (SELECT id FROM fuel_types WHERE name = 'Diesel'), (SELECT id FROM body_types WHERE name = 'SUV'),
 (SELECT id FROM transmission_types WHERE name = 'Automatic'), 4, 5, 173, 'ana.stojanova@yahoo.com', NOW() - INTERVAL '19 days');

-- ── 16. Peugeot 3008 ─ aleksandar, approved ────────────────────
INSERT INTO listings (title, slug, description, price, condition_type_id, approved, seller_id, car_brand_id, car_model, registration_year, kilometers, fuel_type_id, body_type_id, transmission_type_id, num_doors, num_seats, kilowatts, created_by, created_at) VALUES
('Peugeot 3008 1.5 BlueHDi GT', 'peugeot-3008-1-5-bluehdi-gt',
 'Eye-catching Peugeot 3008 GT with i-Cockpit. Focal premium audio, grip control, night vision, full LED. French design meets practicality. Very economical diesel engine.',
 23500.00, (SELECT id FROM condition_types WHERE name = 'Used'), true,
 (SELECT id FROM users WHERE email = 'aleksandar.ristov@gmail.com'),
 (SELECT id FROM car_brands WHERE name = 'Peugeot'), '3008 1.5 BlueHDi GT', 2021, 55000,
 (SELECT id FROM fuel_types WHERE name = 'Diesel'), (SELECT id FROM body_types WHERE name = 'SUV'),
 (SELECT id FROM transmission_types WHERE name = 'Automatic'), 4, 5, 96, 'aleksandar.ristov@gmail.com', NOW() - INTERVAL '28 days');

-- ── 17. Kia Sportage ─ nikola, approved ────────────────────────
INSERT INTO listings (title, slug, description, price, condition_type_id, approved, seller_id, car_brand_id, car_model, registration_year, kilometers, fuel_type_id, body_type_id, transmission_type_id, num_doors, num_seats, kilowatts, created_by, created_at) VALUES
('Kia Sportage 1.6 T-GDI GT-Line', 'kia-sportage-1-6-tgdi-gt-line',
 'Head-turning new Kia Sportage with curved dual screen dashboard. Harman Kardon audio, ventilated seats, smart park assist, heads-up display. 7 year Kia warranty. Incredible value.',
 27000.00, (SELECT id FROM condition_types WHERE name = 'Certified Pre-Owned'), true,
 (SELECT id FROM users WHERE email = 'nikola.andonov@gmail.com'),
 (SELECT id FROM car_brands WHERE name = 'Kia'), 'Sportage 1.6 T-GDI', 2023, 18000,
 (SELECT id FROM fuel_types WHERE name = 'Petrol'), (SELECT id FROM body_types WHERE name = 'SUV'),
 (SELECT id FROM transmission_types WHERE name = 'Automatic'), 4, 5, 132, 'nikola.andonov@gmail.com', NOW() - INTERVAL '6 days');

-- ── 18. Seat Leon FR ─ dejan, approved ─────────────────────────
INSERT INTO listings (title, slug, description, price, condition_type_id, approved, seller_id, car_brand_id, car_model, registration_year, kilometers, fuel_type_id, body_type_id, transmission_type_id, num_doors, num_seats, kilowatts, created_by, created_at) VALUES
('Seat Leon FR 1.5 eTSI 150', 'seat-leon-fr-1-5-etsi-150',
 'Dynamic Seat Leon FR with mild hybrid tech. Virtual cockpit, BeatsAudio, dynamic chassis control, full LED matrix headlights. Same platform as Golf 8 but more exciting styling.',
 21500.00, (SELECT id FROM condition_types WHERE name = 'Used'), true,
 (SELECT id FROM users WHERE email = 'dejan.milosevski@gmail.com'),
 (SELECT id FROM car_brands WHERE name = 'Seat'), 'Leon FR 1.5 eTSI', 2022, 29000,
 (SELECT id FROM fuel_types WHERE name = 'Hybrid'), (SELECT id FROM body_types WHERE name = 'Hatchback'),
 (SELECT id FROM transmission_types WHERE name = 'Dual-Clutch (DCT)'), 4, 5, 110, 'dejan.milosevski@gmail.com', NOW() - INTERVAL '4 days');

-- ── 19. Nissan Qashqai ─ tamara, approved ──────────────────────
INSERT INTO listings (title, slug, description, price, condition_type_id, approved, seller_id, car_brand_id, car_model, registration_year, kilometers, fuel_type_id, body_type_id, transmission_type_id, num_doors, num_seats, kilowatts, created_by, created_at) VALUES
('Nissan Qashqai 1.3 DIG-T Tekna+', 'nissan-qashqai-1-3-digt-tekna-plus',
 'Top spec Nissan Qashqai Tekna+ with ProPILOT assist, around view monitor, quilted leather, powered tailgate. Massaging driver seat. The original crossover, perfected.',
 25000.00, (SELECT id FROM condition_types WHERE name = 'Used'), true,
 (SELECT id FROM users WHERE email = 'tamara.mitrevska@gmail.com'),
 (SELECT id FROM car_brands WHERE name = 'Nissan'), 'Qashqai 1.3 DIG-T', 2022, 22000,
 (SELECT id FROM fuel_types WHERE name = 'Petrol'), (SELECT id FROM body_types WHERE name = 'SUV'),
 (SELECT id FROM transmission_types WHERE name = 'CVT'), 4, 5, 116, 'tamara.mitrevska@gmail.com', NOW() - INTERVAL '8 days');

-- ── 20. Mazda CX-5 ─ igor, approved ───────────────────────────
INSERT INTO listings (title, slug, description, price, condition_type_id, approved, seller_id, car_brand_id, car_model, registration_year, kilometers, fuel_type_id, body_type_id, transmission_type_id, num_doors, num_seats, kilowatts, created_by, created_at) VALUES
('Mazda CX-5 2.2 Skyactiv-D AWD', 'mazda-cx5-2-2-skyactiv-d-awd',
 'Beautifully crafted Mazda CX-5 with Soul Red Crystal paint. Nappa leather, BOSE audio, head-up display, 360 view. Japanese precision engineering. Drives like a premium car at half the price.',
 26000.00, (SELECT id FROM condition_types WHERE name = 'Used'), true,
 (SELECT id FROM users WHERE email = 'igor.nikolov@hotmail.com'),
 (SELECT id FROM car_brands WHERE name = 'Mazda'), 'CX-5 2.2 Skyactiv-D', 2021, 42000,
 (SELECT id FROM fuel_types WHERE name = 'Diesel'), (SELECT id FROM body_types WHERE name = 'SUV'),
 (SELECT id FROM transmission_types WHERE name = 'Automatic'), 4, 5, 135, 'igor.nikolov@hotmail.com', NOW() - INTERVAL '15 days');

-- ── 21. Honda Civic ─ kristina, NOT approved (pending) ─────────
INSERT INTO listings (title, slug, description, price, condition_type_id, approved, seller_id, car_brand_id, car_model, registration_year, kilometers, fuel_type_id, body_type_id, transmission_type_id, num_doors, num_seats, kilowatts, created_by, created_at) VALUES
('Honda Civic 2.0 e:HEV Advance', 'honda-civic-2-0-ehev-advance',
 'Sleek 11th generation Honda Civic hybrid. 184 PS combined output, 4.7L/100km fuel economy, BOSE premium audio, Honda SENSING suite. The thinking person''s hatchback.',
 28000.00, (SELECT id FROM condition_types WHERE name = 'Used'), false,
 (SELECT id FROM users WHERE email = 'kristina.ilievska@gmail.com'),
 (SELECT id FROM car_brands WHERE name = 'Honda'), 'Civic 2.0 e:HEV', 2023, 11000,
 (SELECT id FROM fuel_types WHERE name = 'Hybrid'), (SELECT id FROM body_types WHERE name = 'Hatchback'),
 (SELECT id FROM transmission_types WHERE name = 'CVT'), 4, 5, 135, 'kristina.ilievska@gmail.com', NOW() - INTERVAL '1 day');

-- ── 22. Alfa Romeo Giulia ─ ana, approved ──────────────────────
INSERT INTO listings (title, slug, description, price, condition_type_id, approved, seller_id, car_brand_id, car_model, registration_year, kilometers, fuel_type_id, body_type_id, transmission_type_id, num_doors, num_seats, kilowatts, created_by, created_at) VALUES
('Alfa Romeo Giulia 2.2 JTDm Veloce', 'alfa-romeo-giulia-2-2-jtdm-veloce',
 'Drop-dead gorgeous Alfa Romeo Giulia in Misano Blue. Veloce trim with sport seats, carbon fibre trim, limited slip diff, adaptive dampers. Italian passion meets German engineering. A true driver''s car.',
 27500.00, (SELECT id FROM condition_types WHERE name = 'Used'), true,
 (SELECT id FROM users WHERE email = 'ana.stojanova@yahoo.com'),
 (SELECT id FROM car_brands WHERE name = 'Alfa Romeo'), 'Giulia 2.2 JTDm Veloce', 2021, 40000,
 (SELECT id FROM fuel_types WHERE name = 'Diesel'), (SELECT id FROM body_types WHERE name = 'Sedan'),
 (SELECT id FROM transmission_types WHERE name = 'Automatic'), 4, 5, 154, 'ana.stojanova@yahoo.com', NOW() - INTERVAL '21 days');

-- ── 23. Mini Cooper S ─ maja, approved ─────────────────────────
INSERT INTO listings (title, slug, description, price, condition_type_id, approved, seller_id, car_brand_id, car_model, registration_year, kilometers, fuel_type_id, body_type_id, transmission_type_id, num_doors, num_seats, kilowatts, created_by, created_at) VALUES
('Mini Cooper S 2.0 John Cooper Works Trim', 'mini-cooper-s-jcw-trim',
 'Fun and characterful Mini Cooper S with JCW body kit, sport exhaust, and Chili Red roof. Harman Kardon audio, heads-up display, driving modes. Go-kart handling in the city!',
 23000.00, (SELECT id FROM condition_types WHERE name = 'Used'), true,
 (SELECT id FROM users WHERE email = 'maja.kostadinova@gmail.com'),
 (SELECT id FROM car_brands WHERE name = 'Mini'), 'Cooper S 2.0 JCW', 2022, 21000,
 (SELECT id FROM fuel_types WHERE name = 'Petrol'), (SELECT id FROM body_types WHERE name = 'Hatchback'),
 (SELECT id FROM transmission_types WHERE name = 'Automatic'), 2, 4, 141, 'maja.kostadinova@gmail.com', NOW() - INTERVAL '13 days');

-- ── 24. Land Rover Discovery Sport ─ marko, approved ───────────
INSERT INTO listings (title, slug, description, price, condition_type_id, approved, seller_id, car_brand_id, car_model, registration_year, kilometers, fuel_type_id, body_type_id, transmission_type_id, num_doors, num_seats, kilowatts, created_by, created_at) VALUES
('Land Rover Discovery Sport 2.0 D200 R-Dynamic', 'land-rover-discovery-sport-d200',
 'Capable Land Rover Discovery Sport with 7 seats. Terrain Response 2, wade sensing, ClearSight mirror, meridian audio. British off-road heritage with urban sophistication. Perfect for families who love adventure.',
 37500.00, (SELECT id FROM condition_types WHERE name = 'Used'), true,
 (SELECT id FROM users WHERE email = 'marko.petrovski@gmail.com'),
 (SELECT id FROM car_brands WHERE name = 'Land Rover'), 'Discovery Sport D200', 2022, 33000,
 (SELECT id FROM fuel_types WHERE name = 'Diesel'), (SELECT id FROM body_types WHERE name = 'SUV'),
 (SELECT id FROM transmission_types WHERE name = 'Automatic'), 4, 7, 150, 'marko.petrovski@gmail.com', NOW() - INTERVAL '17 days');

-- ── 25. Suzuki Jimny ─ nikola, NOT approved (pending) ──────────
INSERT INTO listings (title, slug, description, price, condition_type_id, approved, seller_id, car_brand_id, car_model, registration_year, kilometers, fuel_type_id, body_type_id, transmission_type_id, num_doors, num_seats, kilowatts, created_by, created_at) VALUES
('Suzuki Jimny 1.5 AllGrip Pro', 'suzuki-jimny-1-5-allgrip-pro',
 'Iconic Suzuki Jimny in Kinetic Yellow. Part-time 4WD with low range, ladder frame chassis, 210mm ground clearance. Tiny but mighty. Rare find — these sell out instantly!',
 22500.00, (SELECT id FROM condition_types WHERE name = 'New'), false,
 (SELECT id FROM users WHERE email = 'nikola.andonov@gmail.com'),
 (SELECT id FROM car_brands WHERE name = 'Suzuki'), 'Jimny 1.5 AllGrip', 2024, 500,
 (SELECT id FROM fuel_types WHERE name = 'Petrol'), (SELECT id FROM body_types WHERE name = 'SUV'),
 (SELECT id FROM transmission_types WHERE name = 'Manual'), 2, 4, 75, 'nikola.andonov@gmail.com', NOW() - INTERVAL '6 hours');

-- ── 26. Old BMW 525i ─ aleksandar, approved, soft-deleted ──────
INSERT INTO listings (title, slug, description, price, condition_type_id, approved, seller_id, car_brand_id, car_model, registration_year, kilometers, fuel_type_id, body_type_id, transmission_type_id, num_doors, num_seats, kilowatts, created_by, created_at, deleted_at) VALUES
('BMW 525i E60 2006 - SOLD', 'bmw-525i-e60-2006-sold',
 'Classic E60 BMW 5 Series. Was a great car. Sold to a happy buyer from Skopje.',
 5500.00, (SELECT id FROM condition_types WHERE name = 'Used'), true,
 (SELECT id FROM users WHERE email = 'aleksandar.ristov@gmail.com'),
 (SELECT id FROM car_brands WHERE name = 'BMW'), '525i E60', 2006, 245000,
 (SELECT id FROM fuel_types WHERE name = 'Petrol'), (SELECT id FROM body_types WHERE name = 'Sedan'),
 (SELECT id FROM transmission_types WHERE name = 'Automatic'), 4, 5, 141, 'aleksandar.ristov@gmail.com', NOW() - INTERVAL '40 days', NOW() - INTERVAL '5 days');

-- ═══════════════════════════════════════════════════════════════════
-- LISTING IMAGES (2-3 per listing, public Unsplash URLs)
-- ═══════════════════════════════════════════════════════════════════

INSERT INTO listing_images (listing_id, storage_key, url, display_order) VALUES
-- BMW 320d
((SELECT id FROM listings WHERE slug='bmw-320d-m-sport-2021'), 'seed/bmw-320d-1.jpg', 'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800', 0),
((SELECT id FROM listings WHERE slug='bmw-320d-m-sport-2021'), 'seed/bmw-320d-2.jpg', 'https://images.unsplash.com/photo-1520050206757-275d0e4e3cec?w=800', 1),
((SELECT id FROM listings WHERE slug='bmw-320d-m-sport-2021'), 'seed/bmw-320d-3.jpg', 'https://images.unsplash.com/photo-1507136566006-cfc505b114fc?w=800', 2),
-- VW Golf 8
((SELECT id FROM listings WHERE slug='volkswagen-golf-8-1-5-tsi'), 'seed/golf-1.jpg', 'https://images.unsplash.com/photo-1619405399517-d7fce0f13302?w=800', 0),
((SELECT id FROM listings WHERE slug='volkswagen-golf-8-1-5-tsi'), 'seed/golf-2.jpg', 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800', 1),
-- Mercedes C220d
((SELECT id FROM listings WHERE slug='mercedes-benz-c220d-amg-line'), 'seed/merc-1.jpg', 'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=800', 0),
((SELECT id FROM listings WHERE slug='mercedes-benz-c220d-amg-line'), 'seed/merc-2.jpg', 'https://images.unsplash.com/photo-1609521263047-f8f205293f24?w=800', 1),
((SELECT id FROM listings WHERE slug='mercedes-benz-c220d-amg-line'), 'seed/merc-3.jpg', 'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=800', 2),
-- Toyota RAV4
((SELECT id FROM listings WHERE slug='toyota-rav4-2-5-hybrid-awd'), 'seed/rav4-1.jpg', 'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=800', 0),
((SELECT id FROM listings WHERE slug='toyota-rav4-2-5-hybrid-awd'), 'seed/rav4-2.jpg', 'https://images.unsplash.com/photo-1625231334401-5b5411724ab9?w=800', 1),
-- Audi A3
((SELECT id FROM listings WHERE slug='audi-a3-sportback-35-tfsi'), 'seed/audi-1.jpg', 'https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?w=800', 0),
((SELECT id FROM listings WHERE slug='audi-a3-sportback-35-tfsi'), 'seed/audi-2.jpg', 'https://images.unsplash.com/photo-1603584173870-7f23fdae1b7a?w=800', 1),
-- Skoda Octavia
((SELECT id FROM listings WHERE slug='skoda-octavia-combi-2-0-tdi'), 'seed/octavia-1.jpg', 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?w=800', 0),
((SELECT id FROM listings WHERE slug='skoda-octavia-combi-2-0-tdi'), 'seed/octavia-2.jpg', 'https://images.unsplash.com/photo-1502877338535-766e1452684a?w=800', 1),
-- Tesla Model 3
((SELECT id FROM listings WHERE slug='tesla-model-3-long-range-2023'), 'seed/tesla-1.jpg', 'https://images.unsplash.com/photo-1560958089-b8a1929cea89?w=800', 0),
((SELECT id FROM listings WHERE slug='tesla-model-3-long-range-2023'), 'seed/tesla-2.jpg', 'https://images.unsplash.com/photo-1536700503339-1e4b06520771?w=800', 1),
((SELECT id FROM listings WHERE slug='tesla-model-3-long-range-2023'), 'seed/tesla-3.jpg', 'https://images.unsplash.com/photo-1554744512-d6c603f27c54?w=800', 2),
-- Opel Corsa
((SELECT id FROM listings WHERE slug='opel-corsa-1-2-turbo-2023'), 'seed/corsa-1.jpg', 'https://images.unsplash.com/photo-1609521263047-f8f205293f24?w=800', 0),
-- Ford Ranger
((SELECT id FROM listings WHERE slug='ford-ranger-wildtrak-2-0-ecoblue'), 'seed/ranger-1.jpg', 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=800', 0),
((SELECT id FROM listings WHERE slug='ford-ranger-wildtrak-2-0-ecoblue'), 'seed/ranger-2.jpg', 'https://images.unsplash.com/photo-1544636331-e26879cd4d9b?w=800', 1),
-- Dacia Sandero
((SELECT id FROM listings WHERE slug='dacia-sandero-stepway-tce-90'), 'seed/sandero-1.jpg', 'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?w=800', 0),
((SELECT id FROM listings WHERE slug='dacia-sandero-stepway-tce-90'), 'seed/sandero-2.jpg', 'https://images.unsplash.com/photo-1494976388531-d1058494ceb8?w=800', 1),
-- Porsche Cayenne
((SELECT id FROM listings WHERE slug='porsche-cayenne-s-2-9-v6-biturbo'), 'seed/cayenne-1.jpg', 'https://images.unsplash.com/photo-1503736334956-4c8f8e92946d?w=800', 0),
((SELECT id FROM listings WHERE slug='porsche-cayenne-s-2-9-v6-biturbo'), 'seed/cayenne-2.jpg', 'https://images.unsplash.com/photo-1614162692292-7ac56d7f373e?w=800', 1),
((SELECT id FROM listings WHERE slug='porsche-cayenne-s-2-9-v6-biturbo'), 'seed/cayenne-3.jpg', 'https://images.unsplash.com/photo-1580274455191-1c62238fa333?w=800', 2),
-- Renault Clio
((SELECT id FROM listings WHERE slug='renault-clio-1-0-tce-intens'), 'seed/clio-1.jpg', 'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=800', 0),
((SELECT id FROM listings WHERE slug='renault-clio-1-0-tce-intens'), 'seed/clio-2.jpg', 'https://images.unsplash.com/photo-1583267746897-2cf415887172?w=800', 1),
-- Hyundai Tucson
((SELECT id FROM listings WHERE slug='hyundai-tucson-1-6-tgdi-hybrid'), 'seed/tucson-1.jpg', 'https://images.unsplash.com/photo-1611016186353-652a19d4e502?w=800', 0),
((SELECT id FROM listings WHERE slug='hyundai-tucson-1-6-tgdi-hybrid'), 'seed/tucson-2.jpg', 'https://images.unsplash.com/photo-1619682817481-e994891cd1f5?w=800', 1),
-- Fiat 500e
((SELECT id FROM listings WHERE slug='fiat-500e-la-prima-42kwh'), 'seed/fiat500-1.jpg', 'https://images.unsplash.com/photo-1595787142240-aedb81e0e090?w=800', 0),
((SELECT id FROM listings WHERE slug='fiat-500e-la-prima-42kwh'), 'seed/fiat500-2.jpg', 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=800', 1),
-- Volvo XC60
((SELECT id FROM listings WHERE slug='volvo-xc60-b5-inscription-awd'), 'seed/xc60-1.jpg', 'https://images.unsplash.com/photo-1606016159991-dfe4f2746ad5?w=800', 0),
((SELECT id FROM listings WHERE slug='volvo-xc60-b5-inscription-awd'), 'seed/xc60-2.jpg', 'https://images.unsplash.com/photo-1606016159991-dfe4f2746ad5?w=800', 1),
-- Peugeot 3008
((SELECT id FROM listings WHERE slug='peugeot-3008-1-5-bluehdi-gt'), 'seed/3008-1.jpg', 'https://images.unsplash.com/photo-1542362567-b07e54358753?w=800', 0),
((SELECT id FROM listings WHERE slug='peugeot-3008-1-5-bluehdi-gt'), 'seed/3008-2.jpg', 'https://images.unsplash.com/photo-1494905998402-395d579af36f?w=800', 1),
-- Kia Sportage
((SELECT id FROM listings WHERE slug='kia-sportage-1-6-tgdi-gt-line'), 'seed/sportage-1.jpg', 'https://images.unsplash.com/photo-1605559424843-9e4c228bf1c2?w=800', 0),
((SELECT id FROM listings WHERE slug='kia-sportage-1-6-tgdi-gt-line'), 'seed/sportage-2.jpg', 'https://images.unsplash.com/photo-1550355291-bbee04a92027?w=800', 1),
-- Seat Leon
((SELECT id FROM listings WHERE slug='seat-leon-fr-1-5-etsi-150'), 'seed/leon-1.jpg', 'https://images.unsplash.com/photo-1570356528233-b442cf2de345?w=800', 0),
((SELECT id FROM listings WHERE slug='seat-leon-fr-1-5-etsi-150'), 'seed/leon-2.jpg', 'https://images.unsplash.com/photo-1489824904134-891ab64532f1?w=800', 1),
-- Nissan Qashqai
((SELECT id FROM listings WHERE slug='nissan-qashqai-1-3-digt-tekna-plus'), 'seed/qashqai-1.jpg', 'https://images.unsplash.com/photo-1609521263047-f8f205293f24?w=800', 0),
((SELECT id FROM listings WHERE slug='nissan-qashqai-1-3-digt-tekna-plus'), 'seed/qashqai-2.jpg', 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=800', 1),
-- Mazda CX-5
((SELECT id FROM listings WHERE slug='mazda-cx5-2-2-skyactiv-d-awd'), 'seed/cx5-1.jpg', 'https://images.unsplash.com/photo-1616422285623-13ff0162193c?w=800', 0),
((SELECT id FROM listings WHERE slug='mazda-cx5-2-2-skyactiv-d-awd'), 'seed/cx5-2.jpg', 'https://images.unsplash.com/photo-1583121274602-3e2820c69888?w=800', 1),
-- Honda Civic
((SELECT id FROM listings WHERE slug='honda-civic-2-0-ehev-advance'), 'seed/civic-1.jpg', 'https://images.unsplash.com/photo-1590362891991-f776e747a588?w=800', 0),
-- Alfa Romeo Giulia
((SELECT id FROM listings WHERE slug='alfa-romeo-giulia-2-2-jtdm-veloce'), 'seed/giulia-1.jpg', 'https://images.unsplash.com/photo-1573950940509-d924ee3fd345?w=800', 0),
((SELECT id FROM listings WHERE slug='alfa-romeo-giulia-2-2-jtdm-veloce'), 'seed/giulia-2.jpg', 'https://images.unsplash.com/photo-1547744152-14d985cb937f?w=800', 1),
-- Mini Cooper S
((SELECT id FROM listings WHERE slug='mini-cooper-s-jcw-trim'), 'seed/mini-1.jpg', 'https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=800', 0),
((SELECT id FROM listings WHERE slug='mini-cooper-s-jcw-trim'), 'seed/mini-2.jpg', 'https://images.unsplash.com/photo-1617531653332-bd46c24f2068?w=800', 1),
-- Land Rover Discovery Sport
((SELECT id FROM listings WHERE slug='land-rover-discovery-sport-d200'), 'seed/disco-1.jpg', 'https://images.unsplash.com/photo-1519245659620-e859806a8d7b?w=800', 0),
((SELECT id FROM listings WHERE slug='land-rover-discovery-sport-d200'), 'seed/disco-2.jpg', 'https://images.unsplash.com/photo-1606016159991-dfe4f2746ad5?w=800', 1),
-- Suzuki Jimny
((SELECT id FROM listings WHERE slug='suzuki-jimny-1-5-allgrip-pro'), 'seed/jimny-1.jpg', 'https://images.unsplash.com/photo-1559416523-140ddc3d238c?w=800', 0);

-- ═══════════════════════════════════════════════════════════════════
-- BLOGS (8 total — 6 published, 2 drafts)
-- ═══════════════════════════════════════════════════════════════════

INSERT INTO blogs (title, slug, excerpt, content, published, author_id, created_by, created_at) VALUES
(
    'Top 10 Tips for Buying a Used Car in 2024',
    'top-10-tips-buying-used-car-2024',
    'Navigate the used car market with confidence using our expert tips on inspections, negotiations, and avoiding common pitfalls.',
    E'Buying a used car can be a daunting experience, but with the right knowledge, you can find a great deal. Here are our top 10 tips:\n\n## 1. Set Your Budget\nBefore you start looking, know exactly how much you can afford — including insurance, tax, and maintenance costs.\n\n## 2. Research the Model\nLook up common issues, running costs, and reliability ratings for any model you''re considering.\n\n## 3. Check the Service History\nA full service history is essential. It shows the car has been properly maintained and can significantly affect resale value.\n\n## 4. Get an Independent Inspection\nNever rely solely on the seller''s word. Pay for a professional pre-purchase inspection.\n\n## 5. Test Drive Thoroughly\nDrive on different road types — city, highway, and hills. Listen for unusual noises and check all electronics.\n\n## 6. Verify the Mileage\nCompare the odometer reading with service records and MOT history to spot potential clocking.\n\n## 7. Check for Outstanding Finance\nUse a vehicle check service to ensure there''s no outstanding finance, insurance write-offs, or stolen flags.\n\n## 8. Inspect the Bodywork\nLook for mismatched paint, uneven panel gaps, and signs of accident repair.\n\n## 9. Negotiate the Price\nAlways negotiate. Use comparable listings as leverage and don''t be afraid to walk away.\n\n## 10. Get Everything in Writing\nEnsure any verbal promises are documented in the sales contract.',
    true, (SELECT id FROM users WHERE email = 'admin@automarket.mk'), 'admin@automarket.mk', NOW() - INTERVAL '35 days'
),
(
    'Electric Cars: Are They Worth It in Macedonia?',
    'electric-cars-worth-it-macedonia',
    'We explore the pros and cons of owning an electric vehicle in Macedonia, from charging infrastructure to total cost of ownership.',
    E'Electric vehicles (EVs) are gaining popularity worldwide, but how practical are they in Macedonia?\n\n## Charging Infrastructure\nMacedonia''s charging network is still developing. Major cities like Skopje have several fast chargers, but rural coverage remains limited. Home charging is the most convenient option if you have a garage.\n\n## Cost of Ownership\nWhile EVs have a higher purchase price, electricity is significantly cheaper than petrol or diesel. Maintenance costs are also lower — no oil changes, fewer brake replacements thanks to regenerative braking.\n\n## Range Anxiety\nModern EVs offer 300-500 km of range, which covers most daily needs. For long trips within the country, the distances are manageable with a single charge.\n\n## Government Incentives\nCurrently, there are limited incentives for EV purchases in Macedonia. However, the lower running costs can offset the higher initial investment over 3-5 years.\n\n## Our Verdict\nIf you have home charging and primarily drive in the city, an EV makes excellent financial sense. For frequent long-distance drivers, a plug-in hybrid might be a better compromise.',
    true, (SELECT id FROM users WHERE email = 'admin@automarket.mk'), 'admin@automarket.mk', NOW() - INTERVAL '28 days'
),
(
    'How to Prepare Your Car for Winter',
    'how-to-prepare-car-for-winter',
    'Essential winter preparation checklist to keep you safe on the road during the cold months in Macedonia.',
    E'Winter driving in Macedonia can be challenging, especially in mountainous regions. Here''s how to prepare your car:\n\n## Tires\nSwitch to winter tires when temperatures consistently drop below 7°C. They provide significantly better grip on cold, wet, and icy roads.\n\n## Battery\nCold weather reduces battery capacity. Have your battery tested and replace it if it''s more than 4 years old.\n\n## Antifreeze\nCheck your coolant mix is adequate for the expected temperatures. A 50/50 mix of antifreeze and water protects down to about -35°C.\n\n## Wipers and Washer Fluid\nInstall winter wiper blades and fill up with winter-grade washer fluid that won''t freeze.\n\n## Lights\nWith shorter days, ensure all lights are working properly. Clean headlight lenses for maximum visibility.\n\n## Emergency Kit\nKeep a blanket, torch, ice scraper, jump cables, and a small shovel in your boot.',
    true, (SELECT id FROM users WHERE email = 'moderator@automarket.mk'), 'moderator@automarket.mk', NOW() - INTERVAL '21 days'
),
(
    'SUV vs Sedan: Which Is Right for You?',
    'suv-vs-sedan-which-right-for-you',
    'A comprehensive comparison of SUVs and sedans to help you decide which body style suits your lifestyle best.',
    E'The SUV vs sedan debate is one of the most common dilemmas for car buyers. Let''s break it down:\n\n## Space and Practicality\nSUVs offer more cargo space and a higher seating position. Sedans counter with easier parking and lower loading heights.\n\n## Fuel Economy\nSedans typically consume less fuel due to lighter weight and better aerodynamics. The gap is narrowing with modern SUVs, but it''s still significant.\n\n## Driving Dynamics\nSedans generally handle better with a lower centre of gravity. SUVs compensate with available AWD systems for rough roads.\n\n## Safety\nBoth types score well in modern crash tests. SUVs offer the psychological benefit of a commanding view, while sedans benefit from lower rollover risk.\n\n## Cost\nSedans are usually cheaper to buy, insure, and maintain. SUVs come at a premium but hold their resale value better.\n\n## Our Recommendation\nChoose a sedan if you prioritize efficiency and driving pleasure. Go for an SUV if you need space, ground clearance, or frequently tackle rough roads.',
    true, (SELECT id FROM users WHERE email = 'admin@automarket.mk'), 'admin@automarket.mk', NOW() - INTERVAL '14 days'
),
(
    'Best First Cars for New Drivers in Macedonia',
    'best-first-cars-new-drivers-macedonia',
    'Our picks for the safest, most affordable, and easiest-to-insure first cars available on the Macedonian market.',
    E'Getting your first car is exciting, but choosing the right one matters. Here are our top picks for new drivers in Macedonia:\n\n## 1. Dacia Sandero\nThe most affordable new car on the market. Simple, reliable, and cheap to run. Insurance group 1-3.\n\n## 2. Opel Corsa\nCompact, easy to park, and available with a small turbo engine. Modern safety features come standard.\n\n## 3. Renault Clio\nStylish interior that punches above its weight. Excellent safety rating and low running costs.\n\n## 4. Volkswagen Polo\nBuilt like a small Golf. Premium feel, great resale value, and rock-solid reliability.\n\n## 5. Suzuki Swift\nLightweight, fun to drive, and very fuel efficient. The sport version is a hidden gem.\n\n## What to Look For\n- Small engine (1.0-1.2L) for lower insurance\n- High safety rating (minimum 4 stars Euro NCAP)\n- Good parts availability in Macedonia\n- Manual transmission to learn properly\n- Under 100,000 km if buying used',
    true, (SELECT id FROM users WHERE email = 'admin@automarket.mk'), 'admin@automarket.mk', NOW() - INTERVAL '7 days'
),
(
    'The Rise of Hybrid Cars: A Practical Guide',
    'rise-of-hybrid-cars-practical-guide',
    'Everything you need to know about hybrid cars — mild, full, and plug-in — and which type suits your driving style.',
    E'Hybrid cars are everywhere now, but which type is right for you?\n\n## Types of Hybrid\n\n### Mild Hybrid (MHEV)\nA small electric motor assists the petrol/diesel engine. Cannot drive on electric alone. Improves fuel economy by 5-15%. Examples: most new Audis, Suzuki Swift.\n\n### Full Hybrid (HEV)\nCan drive short distances on electric power alone. Self-charging — no plug needed. Great for city driving. Examples: Toyota Yaris, Honda Jazz.\n\n### Plug-in Hybrid (PHEV)\nLarger battery that you charge at home or at a charging station. 40-80 km electric-only range. Best of both worlds if you charge regularly. Examples: BMW 330e, Volvo XC60 Recharge.\n\n## Which Should You Choose?\n- **Short city commute** → Full Hybrid (Toyota)\n- **Mixed driving with home charging** → Plug-in Hybrid\n- **Highway driving** → Mild Hybrid or Diesel\n- **No charging option** → Full Hybrid\n\n## Running Costs\nHybrids typically save 20-40% on fuel compared to equivalent petrol cars. Maintenance is similar, though brake pads last longer due to regenerative braking.',
    true, (SELECT id FROM users WHERE email = 'moderator@automarket.mk'), 'moderator@automarket.mk', NOW() - INTERVAL '3 days'
),
(
    'Understanding Car Finance Options',
    'understanding-car-finance-options',
    'A guide to the different ways you can finance your next car purchase, from bank loans to leasing.',
    E'Not everyone can buy a car outright. Here are the main financing options available:\n\n## Bank Loan\nA traditional personal loan from your bank. You own the car from day one and can sell it whenever you want. Interest rates vary based on your credit history.\n\n## Dealer Finance\nConvenient but often more expensive. Always compare the dealer''s APR with your bank before signing.\n\n## Leasing\nYou pay monthly to use the car for a fixed period (usually 2-4 years). Lower monthly payments but you don''t own the car and face mileage restrictions.\n\n## Tips for Getting the Best Deal\n- Shop around for the best interest rate\n- Make the largest deposit you can afford\n- Keep the term as short as possible to minimize total interest\n- Read the fine print carefully\n- Factor in insurance and maintenance costs',
    false, (SELECT id FROM users WHERE email = 'admin@automarket.mk'), 'admin@automarket.mk', NOW() - INTERVAL '1 day'
),
(
    'AutoMarket Guide to Car Insurance in Macedonia',
    'guide-car-insurance-macedonia',
    'Draft: Comprehensive overview of mandatory and optional car insurance types available in Macedonia.',
    E'## Coming Soon\n\nThis article will cover:\n- Mandatory third-party liability insurance\n- Comprehensive (kasko) insurance explained\n- How premiums are calculated\n- Tips for reducing your premium\n- Claim process walkthrough\n- Best insurance providers comparison',
    false, (SELECT id FROM users WHERE email = 'admin@automarket.mk'), 'admin@automarket.mk', NOW() - INTERVAL '12 hours'
);

-- Blog cover images
UPDATE blogs SET cover_image_url = 'https://images.unsplash.com/photo-1449965408869-ebd13bc9e5a8?w=1200',  cover_image_key = 'seed/blog-used-car-tips.jpg'   WHERE slug = 'top-10-tips-buying-used-car-2024';
UPDATE blogs SET cover_image_url = 'https://images.unsplash.com/photo-1593941707882-a5bba14938c7?w=1200',  cover_image_key = 'seed/blog-ev.jpg'               WHERE slug = 'electric-cars-worth-it-macedonia';
UPDATE blogs SET cover_image_url = 'https://images.unsplash.com/photo-1477346611705-65d1883cee1e?w=1200',  cover_image_key = 'seed/blog-winter.jpg'           WHERE slug = 'how-to-prepare-car-for-winter';
UPDATE blogs SET cover_image_url = 'https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?w=1200',  cover_image_key = 'seed/blog-suv-sedan.jpg'        WHERE slug = 'suv-vs-sedan-which-right-for-you';
UPDATE blogs SET cover_image_url = 'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=1200',     cover_image_key = 'seed/blog-first-car.jpg'        WHERE slug = 'best-first-cars-new-drivers-macedonia';
UPDATE blogs SET cover_image_url = 'https://images.unsplash.com/photo-1611016186353-652a19d4e502?w=1200',  cover_image_key = 'seed/blog-hybrid.jpg'           WHERE slug = 'rise-of-hybrid-cars-practical-guide';
UPDATE blogs SET cover_image_url = 'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=1200',     cover_image_key = 'seed/blog-finance.jpg'          WHERE slug = 'understanding-car-finance-options';

-- ═══════════════════════════════════════════════════════════════════
-- FAVORITES (20+ — lots of cross-user activity)
-- ═══════════════════════════════════════════════════════════════════

INSERT INTO favorites (user_id, listing_id, created_at)
SELECT u.id, l.id, NOW() - INTERVAL '10 days' FROM users u, listings l WHERE u.email='user@automarket.mk' AND l.slug='bmw-320d-m-sport-2021';
INSERT INTO favorites (user_id, listing_id, created_at)
SELECT u.id, l.id, NOW() - INTERVAL '9 days' FROM users u, listings l WHERE u.email='user@automarket.mk' AND l.slug='tesla-model-3-long-range-2023';
INSERT INTO favorites (user_id, listing_id, created_at)
SELECT u.id, l.id, NOW() - INTERVAL '8 days' FROM users u, listings l WHERE u.email='user@automarket.mk' AND l.slug='mercedes-benz-c220d-amg-line';
INSERT INTO favorites (user_id, listing_id, created_at)
SELECT u.id, l.id, NOW() - INTERVAL '5 days' FROM users u, listings l WHERE u.email='user@automarket.mk' AND l.slug='porsche-cayenne-s-2-9-v6-biturbo';

INSERT INTO favorites (user_id, listing_id, created_at)
SELECT u.id, l.id, NOW() - INTERVAL '7 days' FROM users u, listings l WHERE u.email='premium@automarket.mk' AND l.slug='volkswagen-golf-8-1-5-tsi';
INSERT INTO favorites (user_id, listing_id, created_at)
SELECT u.id, l.id, NOW() - INTERVAL '6 days' FROM users u, listings l WHERE u.email='premium@automarket.mk' AND l.slug='toyota-rav4-2-5-hybrid-awd';
INSERT INTO favorites (user_id, listing_id, created_at)
SELECT u.id, l.id, NOW() - INTERVAL '3 days' FROM users u, listings l WHERE u.email='premium@automarket.mk' AND l.slug='alfa-romeo-giulia-2-2-jtdm-veloce';

INSERT INTO favorites (user_id, listing_id, created_at)
SELECT u.id, l.id, NOW() - INTERVAL '6 days' FROM users u, listings l WHERE u.email='moderator@automarket.mk' AND l.slug='tesla-model-3-long-range-2023';
INSERT INTO favorites (user_id, listing_id, created_at)
SELECT u.id, l.id, NOW() - INTERVAL '4 days' FROM users u, listings l WHERE u.email='moderator@automarket.mk' AND l.slug='porsche-cayenne-s-2-9-v6-biturbo';

INSERT INTO favorites (user_id, listing_id, created_at)
SELECT u.id, l.id, NOW() - INTERVAL '5 days' FROM users u, listings l WHERE u.email='admin@automarket.mk' AND l.slug='ford-ranger-wildtrak-2-0-ecoblue';
INSERT INTO favorites (user_id, listing_id, created_at)
SELECT u.id, l.id, NOW() - INTERVAL '2 days' FROM users u, listings l WHERE u.email='admin@automarket.mk' AND l.slug='volvo-xc60-b5-inscription-awd';

INSERT INTO favorites (user_id, listing_id, created_at)
SELECT u.id, l.id, NOW() - INTERVAL '4 days' FROM users u, listings l WHERE u.email='marko.petrovski@gmail.com' AND l.slug='bmw-320d-m-sport-2021';
INSERT INTO favorites (user_id, listing_id, created_at)
SELECT u.id, l.id, NOW() - INTERVAL '3 days' FROM users u, listings l WHERE u.email='marko.petrovski@gmail.com' AND l.slug='porsche-cayenne-s-2-9-v6-biturbo';
INSERT INTO favorites (user_id, listing_id, created_at)
SELECT u.id, l.id, NOW() - INTERVAL '1 day' FROM users u, listings l WHERE u.email='marko.petrovski@gmail.com' AND l.slug='land-rover-discovery-sport-d200';

INSERT INTO favorites (user_id, listing_id, created_at)
SELECT u.id, l.id, NOW() - INTERVAL '6 days' FROM users u, listings l WHERE u.email='elena.dimova@gmail.com' AND l.slug='renault-clio-1-0-tce-intens';
INSERT INTO favorites (user_id, listing_id, created_at)
SELECT u.id, l.id, NOW() - INTERVAL '5 days' FROM users u, listings l WHERE u.email='elena.dimova@gmail.com' AND l.slug='mini-cooper-s-jcw-trim';
INSERT INTO favorites (user_id, listing_id, created_at)
SELECT u.id, l.id, NOW() - INTERVAL '2 days' FROM users u, listings l WHERE u.email='elena.dimova@gmail.com' AND l.slug='fiat-500e-la-prima-42kwh';

INSERT INTO favorites (user_id, listing_id, created_at)
SELECT u.id, l.id, NOW() - INTERVAL '3 days' FROM users u, listings l WHERE u.email='ana.stojanova@yahoo.com' AND l.slug='tesla-model-3-long-range-2023';
INSERT INTO favorites (user_id, listing_id, created_at)
SELECT u.id, l.id, NOW() - INTERVAL '2 days' FROM users u, listings l WHERE u.email='ana.stojanova@yahoo.com' AND l.slug='mercedes-benz-c220d-amg-line';

INSERT INTO favorites (user_id, listing_id, created_at)
SELECT u.id, l.id, NOW() - INTERVAL '2 days' FROM users u, listings l WHERE u.email='igor.nikolov@hotmail.com' AND l.slug='land-rover-discovery-sport-d200';
INSERT INTO favorites (user_id, listing_id, created_at)
SELECT u.id, l.id, NOW() - INTERVAL '1 day' FROM users u, listings l WHERE u.email='igor.nikolov@hotmail.com' AND l.slug='mazda-cx5-2-2-skyactiv-d-awd';

INSERT INTO favorites (user_id, listing_id, created_at)
SELECT u.id, l.id, NOW() - INTERVAL '1 day' FROM users u, listings l WHERE u.email='tamara.mitrevska@gmail.com' AND l.slug='fiat-500e-la-prima-42kwh';
INSERT INTO favorites (user_id, listing_id, created_at)
SELECT u.id, l.id, NOW() - INTERVAL '8 hours' FROM users u, listings l WHERE u.email='tamara.mitrevska@gmail.com' AND l.slug='mini-cooper-s-jcw-trim';

INSERT INTO favorites (user_id, listing_id, created_at)
SELECT u.id, l.id, NOW() - INTERVAL '18 hours' FROM users u, listings l WHERE u.email='dejan.milosevski@gmail.com' AND l.slug='bmw-320d-m-sport-2021';
INSERT INTO favorites (user_id, listing_id, created_at)
SELECT u.id, l.id, NOW() - INTERVAL '6 hours' FROM users u, listings l WHERE u.email='kristina.ilievska@gmail.com' AND l.slug='audi-a3-sportback-35-tfsi';

-- ═══════════════════════════════════════════════════════════════════
-- INQUIRIES (15 messages — realistic buyer/seller conversations)
-- ═══════════════════════════════════════════════════════════════════

-- BMW 320d inquiries
INSERT INTO inquiries (listing_id, sender_id, message, read_by_seller, created_at)
SELECT l.id, u.id, 'Hi, is this BMW still available? I am very interested. Can we arrange a test drive this weekend?', false, NOW() - INTERVAL '5 days'
FROM listings l, users u WHERE l.slug='bmw-320d-m-sport-2021' AND u.email='user@automarket.mk';

INSERT INTO inquiries (listing_id, sender_id, message, read_by_seller, created_at)
SELECT l.id, u.id, 'Hello! What is the lowest you would go on the BMW? I can pay cash today. Also, any scratches on the body?', true, NOW() - INTERVAL '3 days'
FROM listings l, users u WHERE l.slug='bmw-320d-m-sport-2021' AND u.email='marko.petrovski@gmail.com';

INSERT INTO inquiries (listing_id, sender_id, message, read_by_seller, created_at)
SELECT l.id, u.id, 'Does the M Sport package include the adaptive suspension? And is the timing chain or belt?', false, NOW() - INTERVAL '1 day'
FROM listings l, users u WHERE l.slug='bmw-320d-m-sport-2021' AND u.email='dejan.milosevski@gmail.com';

-- Mercedes C220d inquiry
INSERT INTO inquiries (listing_id, sender_id, message, read_by_seller, created_at)
SELECT l.id, u.id, 'Hello, what is the lowest price you would accept for the C-Class? Also, has it ever been in an accident?', true, NOW() - INTERVAL '8 days'
FROM listings l, users u WHERE l.slug='mercedes-benz-c220d-amg-line' AND u.email='user@automarket.mk';

INSERT INTO inquiries (listing_id, sender_id, message, read_by_seller, created_at)
SELECT l.id, u.id, 'Beautiful car! Is the panoramic roof the full-length one or partial? Can I see it in Bitola?', true, NOW() - INTERVAL '4 days'
FROM listings l, users u WHERE l.slug='mercedes-benz-c220d-amg-line' AND u.email='ana.stojanova@yahoo.com';

-- Tesla Model 3 inquiries
INSERT INTO inquiries (listing_id, sender_id, message, read_by_seller, created_at)
SELECT l.id, u.id, 'Interested in the Model 3. How is the battery health? Do you have the degradation report from Tesla?', false, NOW() - INTERVAL '4 days'
FROM listings l, users u WHERE l.slug='tesla-model-3-long-range-2023' AND u.email='moderator@automarket.mk';

INSERT INTO inquiries (listing_id, sender_id, message, read_by_seller, created_at)
SELECT l.id, u.id, 'Is the Full Self-Driving package included or just basic Autopilot? What about supercharger transfers?', false, NOW() - INTERVAL '2 days'
FROM listings l, users u WHERE l.slug='tesla-model-3-long-range-2023' AND u.email='elena.dimova@gmail.com';

-- Porsche Cayenne inquiry
INSERT INTO inquiries (listing_id, sender_id, message, read_by_seller, created_at)
SELECT l.id, u.id, 'Wow, what a spec! Is the price negotiable? I am a serious buyer from Skopje. Can come see it today.', true, NOW() - INTERVAL '2 days'
FROM listings l, users u WHERE l.slug='porsche-cayenne-s-2-9-v6-biturbo' AND u.email='marko.petrovski@gmail.com';

-- VW Golf inquiry
INSERT INTO inquiries (listing_id, sender_id, message, read_by_seller, created_at)
SELECT l.id, u.id, 'Nice Golf! Would you consider a part exchange with my Audi A3? Similar value. Let me know.', true, NOW() - INTERVAL '10 days'
FROM listings l, users u WHERE l.slug='volkswagen-golf-8-1-5-tsi' AND u.email='premium@automarket.mk';

-- Dacia Sandero inquiry
INSERT INTO inquiries (listing_id, sender_id, message, read_by_seller, created_at)
SELECT l.id, u.id, 'Is this Sandero actually brand new? The price seems too good. Can you provide the invoice?', false, NOW() - INTERVAL '6 days'
FROM listings l, users u WHERE l.slug='dacia-sandero-stepway-tce-90' AND u.email='admin@automarket.mk';

-- Fiat 500e inquiry
INSERT INTO inquiries (listing_id, sender_id, message, read_by_seller, created_at)
SELECT l.id, u.id, 'So cute! How long does it take to charge from 0-100%? Is the range really 320 km in real life?', false, NOW() - INTERVAL '3 days'
FROM listings l, users u WHERE l.slug='fiat-500e-la-prima-42kwh' AND u.email='tamara.mitrevska@gmail.com';

-- Volvo XC60 inquiry
INSERT INTO inquiries (listing_id, sender_id, message, read_by_seller, created_at)
SELECT l.id, u.id, 'My wife loves this car. Is the B5 the diesel or petrol version? Can we arrange a viewing in Bitola?', true, NOW() - INTERVAL '7 days'
FROM listings l, users u WHERE l.slug='volvo-xc60-b5-inscription-awd' AND u.email='igor.nikolov@hotmail.com';

-- Land Rover inquiry
INSERT INTO inquiries (listing_id, sender_id, message, read_by_seller, created_at)
SELECT l.id, u.id, 'Does the 7-seat version sacrifice boot space? I need to fit a double pram. Also, any electrical issues?', false, NOW() - INTERVAL '5 days'
FROM listings l, users u WHERE l.slug='land-rover-discovery-sport-d200' AND u.email='maja.kostadinova@gmail.com';

-- Mini Cooper inquiry
INSERT INTO inquiries (listing_id, sender_id, message, read_by_seller, created_at)
SELECT l.id, u.id, 'Love the JCW trim! Is the sport exhaust the factory one or aftermarket? Real reason for selling?', true, NOW() - INTERVAL '4 days'
FROM listings l, users u WHERE l.slug='mini-cooper-s-jcw-trim' AND u.email='kristina.ilievska@gmail.com';

-- ═══════════════════════════════════════════════════════════════════
-- LISTING ANALYTICS (30 days for all approved listings)
-- ═══════════════════════════════════════════════════════════════════

-- Generate analytics for all approved, non-deleted listings over the last 30 days
-- Popular listings get more views; featured listings get a boost
INSERT INTO listing_analytics (listing_id, date, view_count, inquiry_count, favorite_count)
SELECT
    l.id,
    CURRENT_DATE - i,
    -- Base views + price-popularity factor + featured boost + recency boost
    GREATEST(1, (
        (RANDOM() * 20 + 5)
        + CASE WHEN l.price < 20000 THEN 15 WHEN l.price < 30000 THEN 10 ELSE 5 END
        + CASE WHEN l.featured THEN 25 ELSE 0 END
        + CASE WHEN i < 7 THEN 10 ELSE 0 END
    )::int),
    GREATEST(0, (RANDOM() * 3 - 0.5)::int),
    GREATEST(0, (RANDOM() * 2 - 0.3)::int)
FROM listings l, generate_series(0, 29) AS i
WHERE l.approved = true AND l.deleted_at IS NULL;
