# AutoMarket Test Accounts

Seeded by Flyway migrations `V11__seed_test_users.sql` and `V12__seed_test_data.sql`.

> **WARNING:** These are development/testing credentials. Do NOT use in production.

## Admin Accounts

| Role | Email | Password | Plan |
|------|-------|----------|------|
| SuperAdmin | superadmin@automarket.mk | SuperAdmin123! | FREE |
| Admin | admin@automarket.mk | Admin123! | FREE |
| Moderator | moderator@automarket.mk | Moderator123! | FREE |
| User | user@automarket.mk | User123! | FREE |
| Premium User | premium@automarket.mk | Premium123! | PREMIUM |

## Community Users (password: `Test1234!`)

| Name | Email | City | Plan |
|------|-------|------|------|
| Marko Petrovski | marko.petrovski@gmail.com | Skopje | FREE |
| Ana Stojanova | ana.stojanova@yahoo.com | Bitola | PREMIUM |
| Igor Nikolov | igor.nikolov@hotmail.com | Kumanovo | FREE |
| Elena Dimova | elena.dimova@gmail.com | Ohrid | FREE |
| Stefan Trajkov | stefan.trajkov@gmail.com | Prilep | PREMIUM |
| Maja Kostadinova | maja.kostadinova@gmail.com | Tetovo | FREE |
| Aleksandar Ristov | aleksandar.ristov@gmail.com | Veles | FREE |
| Ivana Georgievska | ivana.georgievska@gmail.com | Strumica | FREE |
| Nikola Andonov | nikola.andonov@gmail.com | Gostivar | FREE |
| Tamara Mitrevska | tamara.mitrevska@gmail.com | Kavadarci | FREE |
| Dejan Milosevski | dejan.milosevski@gmail.com | Stip | FREE |
| Kristina Ilievska | kristina.ilievska@gmail.com | Kocani | FREE |

## Role Hierarchy

```
ROLE_SUPERADMIN > ROLE_ADMIN > ROLE_MODERATOR > ROLE_USER
```

## Access Levels

- **SuperAdmin** - Full access, all admin endpoints (`/api/v1/admin/**`)
- **Admin** - Admin endpoints (`/api/v1/admin/**`)
- **Moderator** - Moderation endpoints (`/api/v1/moderation/**`)
- **User / Premium** - Standard authenticated endpoints

## Authentication

**POST** `/api/v1/auth/login`

```json
{
  "email": "admin@automarket.mk",
  "password": "Admin123!"
}
```

The response returns an access token (JWT, 15 min) and a refresh token (30 days).
Use the access token as `Authorization: Bearer <token>` header.

## Seeded Listings (25 + 1 soft-deleted)

| # | Title | Seller | Price | Status |
|---|-------|--------|-------|--------|
| 1 | BMW 320d M Sport 2021 | premium@ | 28,500 | Approved, Featured |
| 2 | VW Golf 8 1.5 TSI | user@ | 22,000 | Approved |
| 3 | Mercedes C220d AMG Line | premium@ | 35,000 | Approved |
| 4 | Toyota RAV4 2.5 Hybrid AWD | Marko P. | 31,000 | Approved |
| 5 | Audi A3 Sportback 35 TFSI | Ana S. | 26,500 | Approved, Featured |
| 6 | Skoda Octavia Combi 2.0 TDI | moderator@ | 19,500 | Approved |
| 7 | Tesla Model 3 Long Range 2023 | Stefan T. | 42,000 | Approved, Featured |
| 8 | Opel Corsa 1.2 Turbo 2023 | Elena D. | 16,500 | Pending |
| 9 | Ford Ranger Wildtrak 2.0 | Igor N. | 38,000 | Approved |
| 10 | Dacia Sandero Stepway TCe 90 | user@ | 12,500 | Approved |
| 11 | Porsche Cayenne S 2.9 V6 | Stefan T. | 72,000 | Approved, Featured |
| 12 | Renault Clio 1.0 TCe Intens | Maja K. | 14,800 | Approved |
| 13 | Hyundai Tucson 1.6 Hybrid | Marko P. | 29,500 | Approved |
| 14 | Fiat 500e La Prima 42 kWh | Ivana G. | 24,000 | Approved |
| 15 | Volvo XC60 B5 Inscription | Ana S. | 41,000 | Approved |
| 16 | Peugeot 3008 1.5 BlueHDi GT | Aleksandar R. | 23,500 | Approved |
| 17 | Kia Sportage 1.6 T-GDI | Nikola A. | 27,000 | Approved |
| 18 | Seat Leon FR 1.5 eTSI | Dejan M. | 21,500 | Approved |
| 19 | Nissan Qashqai 1.3 Tekna+ | Tamara M. | 25,000 | Approved |
| 20 | Mazda CX-5 2.2 Skyactiv-D | Igor N. | 26,000 | Approved |
| 21 | Honda Civic 2.0 e:HEV | Kristina I. | 28,000 | Pending |
| 22 | Alfa Romeo Giulia Veloce | Ana S. | 27,500 | Approved |
| 23 | Mini Cooper S JCW Trim | Maja K. | 23,000 | Approved |
| 24 | Land Rover Discovery Sport | Marko P. | 37,500 | Approved |
| 25 | Suzuki Jimny 1.5 AllGrip | Nikola A. | 22,500 | Pending |
| 26 | BMW 525i E60 2006 | Aleksandar R. | 5,500 | Sold (deleted) |

## Seeded Blogs (8)

| # | Title | Author | Published |
|---|-------|--------|-----------|
| 1 | Top 10 Tips for Buying a Used Car | admin@ | Yes |
| 2 | Electric Cars: Worth It in Macedonia? | admin@ | Yes |
| 3 | How to Prepare Your Car for Winter | moderator@ | Yes |
| 4 | SUV vs Sedan: Which Is Right for You? | admin@ | Yes |
| 5 | Best First Cars for New Drivers | admin@ | Yes |
| 6 | The Rise of Hybrid Cars | moderator@ | Yes |
| 7 | Understanding Car Finance Options | admin@ | Draft |
| 8 | Guide to Car Insurance in Macedonia | admin@ | Draft |

## Other Seeded Data

- **Subscriptions** (3) - premium@, Ana, and Stefan have active PREMIUM subscriptions
- **Favorites** (25) - Organic cross-user activity across many listings
- **Inquiries** (15) - Realistic buyer messages, mix of read/unread
- **Listing Images** (50+) - 1-3 public Unsplash images per listing
- **Blog Cover Images** - Public Unsplash images for all published posts
- **Listing Analytics** - 30 days of view/inquiry/favorite stats for all approved listings
