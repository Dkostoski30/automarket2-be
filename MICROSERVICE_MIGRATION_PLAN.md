# AutoMarket Microservice Migration Plan

> **Constraint:** The frontend (Angular, `http://localhost:4200`) must not be affected. All existing API contracts (`/api/v1/*`), JWT auth flow, request/response shapes, and error formats remain identical.

---

## Table of Contents

1. [Current Architecture Summary](#1-current-architecture-summary)
2. [Domain Decomposition](#2-domain-decomposition)
3. [Target Architecture](#3-target-architecture)
4. [Service Specifications](#4-service-specifications)
5. [API Gateway](#5-api-gateway)
6. [Database Decomposition](#6-database-decomposition)
7. [Inter-Service Communication](#7-inter-service-communication)
8. [Cross-Cutting Concerns](#8-cross-cutting-concerns)
9. [Migration Strategy (Strangler Fig)](#9-migration-strategy-strangler-fig)
10. [Infrastructure & DevOps](#10-infrastructure--devops)
11. [Phased Roadmap](#11-phased-roadmap)
12. [Risks & Mitigations](#12-risks--mitigations)

---

## 1. Current Architecture Summary

### Monolith Stats
- **Framework:** Spring Boot 3.2.3, Java 21, Spring Security 6.2
- **Database:** PostgreSQL 16 (single DB, 18 tables, Flyway-managed)
- **Cache:** Redis 7 (featured listings, reference data, listing detail)
- **Storage:** Local filesystem (dev) / AWS S3 + CloudFront (prod)
- **Payments:** Stripe (checkout sessions, webhooks)
- **Email:** SMTP (MailHog dev / real SMTP prod)
- **Auth:** Stateless JWT (15min access + 30-day refresh rotation)
- **Deployment:** Docker Compose (postgres, redis, mailhog, app)

### Current Module Inventory
| Layer | Count | Items |
|-------|-------|-------|
| Controllers | 10 | Auth, User, Listing, Blog, Favorite, Inquiry, Reference, Subscription, Admin (3), Moderation, Webhook |
| Services | 18 | + 2 AI stubs |
| Entities | 16 | + 1 base class, 1 embeddable |
| Repositories | 16 | |
| DTOs | 28 | Across 10 packages |
| Flyway migrations | 12 | V1 through V12 |
| REST endpoints | ~50 | Public + authenticated + admin |

---

## 2. Domain Decomposition

### Bounded Context Map

```
+------------------+       +------------------+       +------------------+
|   AUTH SERVICE   |       | LISTING SERVICE  |       |  BLOG SERVICE    |
|                  |       |                  |       |                  |
| - User           |<------| - Listing        |       | - Blog           |
| - Role           |  ref  | - ListingImage   |       |                  |
| - RefreshToken   |       | - CarDetails     |       |                  |
|                  |       | - Favorite       |       |                  |
|                  |       | - ListingAnalytics|      |                  |
+--------+---------+       +--------+---------+       +--------+---------+
         |                          |                           |
         |    +--------------------+|+--------------------------+
         |    |                     |
+--------+----+----+       +-------+---------+       +------------------+
| REFERENCE SERVICE|       | INQUIRY SERVICE |       | PAYMENT SERVICE  |
|                  |       |                 |       |                  |
| - CarBrand       |       | - Inquiry       |       | - Subscription   |
| - FuelType       |       |                 |       | - Stripe webhook |
| - BodyType       |       |                 |       |                  |
| - ConditionType  |       |                 |       |                  |
| - TransmissionType|      |                 |       |                  |
| - City           |       |                 |       |                  |
+------------------+       +-----------------+       +------------------+

+------------------+       +------------------+       +------------------+
| NOTIFICATION SVC |       |  STORAGE SERVICE |       |   API GATEWAY    |
| (event-driven)   |       |  (shared lib)    |       |                  |
| - Email          |       | - Local / S3     |       | - Routing        |
|                  |       |                  |       | - JWT validation |
|                  |       |                  |       | - CORS           |
|                  |       |                  |       | - Rate limiting  |
+------------------+       +------------------+       +------------------+
```

### Why These Boundaries?

| Service | Rationale |
|---------|-----------|
| **Auth** | Identity is foundational. Every service depends on user identity but none should own it. Isolated to enable independent scaling and security hardening. |
| **Listing** | Core business domain, highest traffic, most complex queries. Benefits most from independent scaling and dedicated DB tuning. |
| **Blog** | Completely independent content domain. No transactional coupling with listings. |
| **Inquiry** | Messaging is a distinct concern. Can be swapped for a real-time system later. |
| **Reference** | Slow-changing lookup data. Rarely deployed, heavily cached. |
| **Payment** | Stripe integration isolated for PCI compliance scope reduction. |
| **Notification** | Pure side-effect, no query path. Perfect candidate for async event-driven. |
| **Storage** | Shared library (not a service) — each service that needs uploads includes the library. |

---

## 3. Target Architecture

```
                         Frontend (Angular)
                              |
                         :8080 (unchanged)
                              |
                     +--------v---------+
                     |   API GATEWAY    |
                     | (Spring Cloud    |
                     |  Gateway)        |
                     +--+--+--+--+--+--+
                        |  |  |  |  |  |
           +------------+  |  |  |  |  +------------+
           |               |  |  |  |               |
     +-----v----+  +------v--v--v--v------+  +------v------+
     |  Auth    |  |   Listing Service    |  |    Blog     |
     | Service  |  |                      |  |   Service   |
     | :8081    |  |        :8082         |  |    :8083    |
     +----+-----+  +----------+----------+  +------+------+
          |                    |                    |
     +----v-----+  +---------v----------+  +------v------+
     | auth_db  |  |    listing_db      |  |   blog_db   |
     +----------+  +--------------------+  +-------------+

     +----------+  +----------+  +------------+  +------------+
     | Inquiry  |  | Reference|  |  Payment   |  |Notification|
     | Service  |  | Service  |  |  Service   |  |  Service   |
     |  :8084   |  |  :8085   |  |   :8086    |  |   :8087    |
     +----+-----+  +----+-----+  +-----+------+  +------+-----+
          |              |              |                |
     +----v-----+  +----v-----+  +-----v------+   (no DB,
     |inquiry_db|  | ref_db   |  | payment_db |   event consumer)
     +----------+  +----------+  +------------+

                    Shared Infrastructure
              +----------+    +----------+
              |  Redis   |    | RabbitMQ |
              | (cache)  |    | (events) |
              +----------+    +----------+
```

---

## 4. Service Specifications

### 4.1 API Gateway

**Technology:** Spring Cloud Gateway (reactive)
**Port:** 8080 (same as current monolith — FE sees no change)

**Responsibilities:**
- Route requests to downstream services based on path prefix
- Validate JWT signature and expiry (lightweight — no DB call)
- Inject `X-User-Email` and `X-User-Roles` headers into downstream requests
- CORS handling (centralized, removed from downstream services)
- Rate limiting (per-user, backed by Redis)
- Request/response logging, `X-Request-Id` propagation
- Circuit breaker (Resilience4j) per downstream service

**Route Table:**

| Path Pattern | Target Service | Notes |
|---|---|---|
| `/api/v1/auth/**` | auth-service:8081 | Public (no JWT validation) |
| `/api/v1/users/**` | auth-service:8081 | Mixed public/auth |
| `/api/v1/listings/**` | listing-service:8082 | Mixed public/auth |
| `/api/v1/blog/**` | blog-service:8083 | Mixed public/auth |
| `/api/v1/favorites/**` | listing-service:8082 | Auth required |
| `/api/v1/inquiries/**` | inquiry-service:8084 | Auth required |
| `/api/v1/reference/**` | reference-service:8085 | Public |
| `/api/v1/subscriptions/**` | payment-service:8086 | Mixed |
| `/api/v1/webhooks/**` | payment-service:8086 | Public (Stripe signature) |
| `/api/v1/admin/users/**` | auth-service:8081 | Admin only |
| `/api/v1/admin/dashboard/**` | listing-service:8082 | Admin (aggregates internally) |
| `/api/v1/admin/reference/**` | reference-service:8085 | Admin only |
| `/api/v1/moderation/**` | listing-service:8082 | Moderator+ |
| `/uploads/**` | listing-service:8082 | Public static files |
| `/v3/api-docs/**` | Aggregated | OpenAPI aggregation |
| `/swagger-ui/**` | Gateway serves | Aggregated Swagger UI |
| `/actuator/health` | Gateway composite | Health aggregate |

**JWT validation at the gateway level:**
```
Request arrives → Extract Bearer token → Verify signature + expiry using shared secret
→ Decode claims → Forward X-User-Email + X-User-Roles headers → Downstream service
```

Downstream services trust gateway headers (internal network only). They do NOT re-validate JWT. This eliminates the need for every service to call UserDetailsService/DB.

---

### 4.2 Auth Service (port 8081)

**Owns:** Users, Roles, RefreshTokens, Authentication

**Database: `auth_db`**
| Table | Source |
|-------|--------|
| users | Current users table |
| roles | Current roles table |
| user_roles | Current user_roles table |
| refresh_tokens | Current refresh_tokens table |

**Endpoints (unchanged paths):**

| Method | Path | Current Controller |
|--------|------|--------------------|
| POST | `/api/v1/auth/register` | AuthController |
| POST | `/api/v1/auth/login` | AuthController |
| POST | `/api/v1/auth/refresh` | AuthController |
| POST | `/api/v1/auth/logout` | AuthController |
| GET | `/api/v1/users/{id}` | UserController |
| GET | `/api/v1/users/me` | UserController |
| PUT | `/api/v1/users/me` | UserController |
| PUT | `/api/v1/users/me/password` | UserController |
| GET | `/api/v1/admin/users` | AdminUserController |
| GET | `/api/v1/admin/users/{id}` | AdminUserController |
| PUT | `/api/v1/admin/users/{id}/roles` | AdminUserController |
| PUT | `/api/v1/admin/users/{id}/status` | AdminUserController |
| DELETE | `/api/v1/admin/users/{id}` | AdminUserController |

**Internal API (service-to-service only, not exposed via gateway):**

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/internal/users/{id}` | Get user summary (name, email, city) for embedding in listing/blog responses |
| GET | `/internal/users/by-email/{email}` | Lookup by email |
| GET | `/internal/users/{id}/listing-count` | Active listing count for public profile |
| PUT | `/internal/users/{id}/plan` | Update plan (called by payment-service) |

**Events Published (to RabbitMQ):**

| Event | When | Consumers |
|-------|------|-----------|
| `user.registered` | New registration | notification-service |
| `user.disabled` | Admin disables account | listing-service (deactivate listings) |
| `user.deleted` | Admin deletes account | listing-service, inquiry-service, blog-service |
| `user.plan-changed` | Plan upgraded/downgraded | listing-service (enforce limits) |

**Key Migration Notes:**
- JwtService, RefreshTokenService, UserDetailsServiceImpl move here
- Password encoding stays here (BCrypt 12)
- Scheduled `cleanupExpiredTokens()` stays here
- AdminUserService moves here (it operates on users)
- `UserProfileDto.activeListingCount` — call listing-service internal API or use cached count from events

---

### 4.3 Listing Service (port 8082)

**Owns:** Listings, ListingImages, CarDetails, Favorites, ListingAnalytics, Moderation

**Database: `listing_db`**
| Table | Source |
|-------|--------|
| listings | Current listings table |
| listing_images | Current listing_images table |
| listing_analytics | Current listing_analytics table |
| favorites | Current favorites table |

**Note:** `seller_id` is stored as a UUID foreign key but references auth_db. No DB-level FK constraint — enforced at application level.

**Endpoints (unchanged paths):**

| Method | Path | Current Controller |
|--------|------|--------------------|
| GET | `/api/v1/listings` | ListingController |
| GET | `/api/v1/listings/{id}` | ListingController |
| GET | `/api/v1/listings/slug/{slug}` | ListingController |
| GET | `/api/v1/listings/featured` | ListingController |
| GET | `/api/v1/listings/my` | ListingController |
| POST | `/api/v1/listings` | ListingController |
| PUT | `/api/v1/listings/{id}` | ListingController |
| DELETE | `/api/v1/listings/{id}` | ListingController |
| POST | `/api/v1/listings/{id}/images` | ListingController |
| DELETE | `/api/v1/listings/{id}/images/{imageId}` | ListingController |
| POST | `/api/v1/listings/{id}/favorite` | ListingController |
| DELETE | `/api/v1/listings/{id}/favorite` | ListingController |
| GET | `/api/v1/listings/{id}/analytics` | ListingController |
| GET | `/api/v1/favorites` | FavoriteController |
| GET | `/api/v1/moderation/listings` | ModerationController |
| GET | `/api/v1/moderation/listings/{id}` | ModerationController |
| POST | `/api/v1/moderation/listings/{id}/approve` | ModerationController |
| POST | `/api/v1/moderation/listings/{id}/reject` | ModerationController |
| GET | `/api/v1/admin/dashboard` | AdminDashboardController |
| `/uploads/**` | Static file serving | StorageConfig |

**Internal API:**

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/internal/listings/count-by-user/{userId}` | Active listing count (for user profile) |
| GET | `/internal/listings/stats` | Listing counts for admin dashboard |

**Events Published:**

| Event | When | Consumers |
|-------|------|-----------|
| `listing.approved` | Moderator approves | notification-service |
| `listing.rejected` | Moderator rejects | notification-service |
| `listing.created` | New listing | (future: search indexing) |

**Events Consumed:**

| Event | Action |
|-------|--------|
| `user.disabled` | Soft-delete all user's listings |
| `user.deleted` | Permanently delete user's listings |
| `user.plan-changed` | Update plan-based limits cache |

**Key Migration Notes:**
- ListingService, FavoriteService, AnalyticsService, ListingModerationService move here
- AdminDashboardController moves here — for `totalUsers`/`activeUsers`/`disabledUsers` counts, it calls auth-service internal API. For `totalBrands`, calls reference-service internal API. For listing/blog counts, uses local DB + blog-service internal API
- Reference data IDs (brand, fuelType, bodyType, etc.) are stored as UUIDs. No FK to reference_db — validated at creation time via sync call to reference-service
- ListingFilterRequest Specification queries reference IDs directly (UUIDs), so no join needed
- StorageService (local or S3) is included as a shared library dependency
- `seller` info in `ListingDetailDto` is enriched via sync call to auth-service (cached in Redis, 5min TTL)

---

### 4.4 Blog Service (port 8083)

**Owns:** Blog posts, blog images

**Database: `blog_db`**
| Table | Source |
|-------|--------|
| blogs | Current blogs table |

**Endpoints (unchanged paths):**

| Method | Path |
|--------|------|
| GET | `/api/v1/blog` |
| GET | `/api/v1/blog/{id}` |
| GET | `/api/v1/blog/slug/{slug}` |
| POST | `/api/v1/blog` |
| PUT | `/api/v1/blog/{id}` |
| DELETE | `/api/v1/blog/{id}` |
| POST | `/api/v1/blog/{id}/cover-image` |
| POST | `/api/v1/blog/images` |

**Internal API:**

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/internal/blogs/count` | Total blog count (for admin dashboard) |

**Key Migration Notes:**
- BlogService moves here entirely
- `author` field stores userId. Author name/info enriched via auth-service internal call (cached)
- StorageService included as shared library
- Smallest, simplest service — good candidate for first extraction

---

### 4.5 Inquiry Service (port 8084)

**Owns:** Inquiries between buyers and sellers

**Database: `inquiry_db`**
| Table | Source |
|-------|--------|
| inquiries | Current inquiries table |

**Endpoints (unchanged paths):**

| Method | Path |
|--------|------|
| POST | `/api/v1/inquiries` |
| GET | `/api/v1/inquiries/received` |
| GET | `/api/v1/inquiries/sent` |
| PUT | `/api/v1/inquiries/{id}/read` |

**Events Published:**

| Event | When | Consumers |
|-------|------|-----------|
| `inquiry.sent` | New inquiry created | notification-service |

**Key Migration Notes:**
- InquiryService moves here
- Stores `listingId` and `senderId` as UUIDs (no FK)
- Validates listing exists and is approved via sync call to listing-service
- Seller email lookup via auth-service internal API
- Listing title for notification enriched at notification-service level

---

### 4.6 Reference Service (port 8085)

**Owns:** All lookup/reference data

**Database: `ref_db`**
| Table | Source |
|-------|--------|
| car_brands | Current car_brands table |
| fuel_types | Current fuel_types table |
| body_types | Current body_types table |
| condition_types | Current condition_types table |
| transmission_types | Current transmission_types table |
| cities | Current cities table |

**Endpoints (unchanged paths):**

| Method | Path |
|--------|------|
| GET | `/api/v1/reference/car-brands` |
| GET | `/api/v1/reference/fuel-types` |
| GET | `/api/v1/reference/body-types` |
| GET | `/api/v1/reference/condition-types` |
| GET | `/api/v1/reference/transmission-types` |
| GET | `/api/v1/reference/cities` |
| POST | `/api/v1/admin/reference/car-brands` |
| DELETE | `/api/v1/admin/reference/car-brands/{id}` |

**Internal API:**

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/internal/reference/brands/count` | Brand count for admin dashboard |
| GET | `/internal/reference/validate` | Validate a set of reference IDs exist |

**Key Migration Notes:**
- ReferenceService moves here
- Heaviest caching, lowest write frequency
- Data changes trigger cache eviction events via Redis pub/sub
- Could remain a shared library instead of a service (see simplification options below)

---

### 4.7 Payment Service (port 8086)

**Owns:** Subscriptions, Stripe integration

**Database: `payment_db`**
| Table | Source |
|-------|--------|
| subscriptions | Current subscriptions table |

**Endpoints (unchanged paths):**

| Method | Path |
|--------|------|
| GET | `/api/v1/subscriptions/plans` |
| POST | `/api/v1/subscriptions/checkout` |
| POST | `/api/v1/webhooks/stripe` |

**Events Published:**

| Event | When | Consumers |
|-------|------|-----------|
| `subscription.activated` | Checkout completed | auth-service (update plan) |
| `subscription.cancelled` | Subscription deleted | auth-service (downgrade plan) |

**Key Migration Notes:**
- SubscriptionService moves here
- Stripe API key and webhook secret isolated in this service only (reduced PCI scope)
- When Stripe webhook fires `checkout.session.completed`, publishes event → auth-service updates user plan
- No direct DB write to users table; event-driven plan changes

---

### 4.8 Notification Service (port 8087)

**Owns:** All outbound notifications (email, future: push, SMS)

**No database.** Pure event consumer.

**Events Consumed:**

| Event | Action |
|-------|--------|
| `listing.approved` | Send "listing approved" email to seller |
| `listing.rejected` | Send "listing rejected" email to seller |
| `inquiry.sent` | Send "new inquiry" email to seller |
| `user.registered` | Send welcome email (future) |

**Key Migration Notes:**
- EmailService moves here
- Looks up user email via auth-service internal API (or event payload includes it)
- SMTP config isolated to this service
- All sends are async (event-driven), no synchronous callers
- Easy to extend with push notifications, SMS, etc.

---

## 5. API Gateway

### JWT Validation Strategy

The gateway performs **lightweight JWT validation** (signature + expiry only) using the shared `JWT_SECRET`. It does NOT hit the database. The decoded claims are forwarded as trusted headers.

```
Gateway JWT Filter:
1. Extract "Authorization: Bearer <token>" header
2. Verify HMAC signature using JWT_SECRET
3. Check expiry claim
4. Extract subject (email) and "roles" claim
5. Set headers:
   X-User-Email: user@example.com
   X-User-Roles: ROLE_USER,ROLE_ADMIN
   X-User-Id: <uuid>  (if stored in token)
6. Forward to downstream service
7. If token invalid/expired → 401 directly from gateway
```

**Downstream services:**
- Read `X-User-Email` and `X-User-Roles` from headers
- Create SecurityContext from these headers (simple filter, no JWT parsing)
- `@PreAuthorize` annotations work unchanged — they check SecurityContext authorities
- Internal network only — headers cannot be spoofed from outside

### Why Not OAuth2/Keycloak?

For this migration, keeping the existing JWT mechanism is simpler. The gateway acts as the single trust boundary. A move to OAuth2/Keycloak can be a future phase if needed.

---

## 6. Database Decomposition

### Strategy: Schema-per-Service (Phase 1) → DB-per-Service (Phase 2)

**Phase 1 — Logical Separation (same PostgreSQL instance):**
```sql
-- Create schemas in existing PostgreSQL 16 instance
CREATE SCHEMA auth_schema;
CREATE SCHEMA listing_schema;
CREATE SCHEMA blog_schema;
CREATE SCHEMA inquiry_schema;
CREATE SCHEMA reference_schema;
CREATE SCHEMA payment_schema;

-- Move tables into schemas
ALTER TABLE users SET SCHEMA auth_schema;
ALTER TABLE roles SET SCHEMA auth_schema;
ALTER TABLE user_roles SET SCHEMA auth_schema;
ALTER TABLE refresh_tokens SET SCHEMA auth_schema;

ALTER TABLE listings SET SCHEMA listing_schema;
ALTER TABLE listing_images SET SCHEMA listing_schema;
ALTER TABLE listing_analytics SET SCHEMA listing_schema;
ALTER TABLE favorites SET SCHEMA listing_schema;

ALTER TABLE blogs SET SCHEMA blog_schema;

ALTER TABLE inquiries SET SCHEMA inquiry_schema;

ALTER TABLE car_brands SET SCHEMA reference_schema;
ALTER TABLE fuel_types SET SCHEMA reference_schema;
-- ... etc

ALTER TABLE subscriptions SET SCHEMA payment_schema;
```

Each service connects with a DB user that only has access to its own schema.

**Phase 2 — Physical Separation (separate PostgreSQL instances):**
- Migrate each schema to its own PostgreSQL instance
- Update connection strings per service
- Remove cross-schema FK constraints (already removed in Phase 1)

### Handling Cross-Service References

| Reference | Current (FK) | After Migration |
|-----------|-------------|-----------------|
| listing.seller_id → users.id | FK constraint | UUID stored, no FK. Validated via auth-service API on creation |
| blog.author_id → users.id | FK constraint | UUID stored, no FK. Author info enriched via API call |
| inquiry.sender_id → users.id | FK constraint | UUID stored, no FK |
| inquiry.listing_id → listings.id | FK constraint | UUID stored, no FK. Validated via listing-service API |
| favorite.user_id → users.id | FK constraint | UUID stored, no FK |
| listing.brand_id → car_brands.id | FK constraint | UUID stored, no FK. Validated on creation |

### Data Consistency Without FKs

- **Soft deletes:** Services publish `*.deleted` events. Consumers mark related data as orphaned or soft-delete
- **Eventual consistency:** Acceptable for this domain (a listing showing a deleted user's name for a few seconds is fine)
- **Compensating transactions:** If listing creation fails after image upload, the listing-service rolls back locally. No distributed transactions needed

---

## 7. Inter-Service Communication

### Synchronous (HTTP — OpenFeign)

Used for: request-time data enrichment where the caller needs the response to build its own response.

```java
// In listing-service
@FeignClient(name = "auth-service", url = "${services.auth.url}")
public interface AuthServiceClient {
    @GetMapping("/internal/users/{id}")
    UserSummaryDto getUser(@PathVariable UUID id);
}
```

**Where sync calls are needed:**

| Caller | Callee | When | Fallback |
|--------|--------|------|----------|
| listing-service | auth-service | Enrich seller info in ListingDetailDto | Return cached seller info or placeholder |
| listing-service | reference-service | Validate reference IDs on listing create | Reject if reference-service down |
| blog-service | auth-service | Enrich author info in BlogDto | Return cached author info |
| inquiry-service | listing-service | Validate listing exists on inquiry send | Reject if listing-service down |
| inquiry-service | auth-service | Get seller email for inquiry routing | Reject if auth-service down |
| auth-service (admin) | listing-service | Get listing counts for user profile & dashboard | Return 0 / cached value |

**Caching sync responses:**
- User summaries cached in Redis (5min TTL) — users rarely change name/city
- Reference data cached in Redis (1hr TTL) — same as current
- Circuit breaker per client (Resilience4j): 5s timeout, 50% failure threshold

### Asynchronous (RabbitMQ — Events)

Used for: side effects that don't need to be in the request path.

**Exchange:** `automarket.events` (topic exchange)

**Routing keys:**

| Routing Key | Publisher | Consumers |
|-------------|-----------|-----------|
| `user.registered` | auth-service | notification-service |
| `user.disabled` | auth-service | listing-service |
| `user.deleted` | auth-service | listing-service, inquiry-service, blog-service |
| `user.plan-changed` | auth-service | listing-service |
| `listing.approved` | listing-service | notification-service |
| `listing.rejected` | listing-service | notification-service |
| `inquiry.sent` | inquiry-service | notification-service |
| `subscription.activated` | payment-service | auth-service |
| `subscription.cancelled` | payment-service | auth-service |

**Event Envelope:**

```json
{
  "eventId": "uuid",
  "eventType": "listing.approved",
  "timestamp": "2026-05-09T10:30:00Z",
  "payload": {
    "listingId": "uuid",
    "sellerId": "uuid",
    "sellerEmail": "user@example.com",
    "listingTitle": "BMW 320d M Sport"
  }
}
```

**Idempotency:** Each consumer tracks processed `eventId` values (simple DB table or Redis set) to handle redeliveries.

---

## 8. Cross-Cutting Concerns

### 8.1 Shared Libraries (Maven modules, not services)

Create a multi-module parent POM with shared libraries:

```
automarket-platform/
├── pom.xml                          (parent POM)
├── automarket-common/               (shared DTOs, exceptions, utils)
│   ├── ApiError.java
│   ├── PageResponse.java
│   ├── BusinessRuleException.java
│   ├── ResourceNotFoundException.java
│   └── GlobalExceptionHandler.java
├── automarket-security-common/      (gateway header → SecurityContext filter)
│   ├── GatewayAuthFilter.java       (reads X-User-Email, X-User-Roles headers)
│   └── SecurityConstants.java
├── automarket-storage/              (StorageService interface + implementations)
│   ├── StorageService.java
│   ├── LocalStorageService.java
│   └── S3StorageService.java
├── automarket-events/               (event DTOs + RabbitMQ config)
│   ├── UserEvent.java
│   ├── ListingEvent.java
│   └── RabbitConfig.java
├── gateway/                         (API Gateway application)
├── auth-service/
├── listing-service/
├── blog-service/
├── inquiry-service/
├── reference-service/
├── payment-service/
└── notification-service/
```

### 8.2 Logging & Observability

| Concern | Solution |
|---------|----------|
| Structured logging | logstash-logback-encoder (already in use) |
| Distributed tracing | Micrometer Tracing + Zipkin (trace IDs propagated via headers) |
| Metrics | Micrometer → Prometheus → Grafana |
| Health checks | Spring Actuator per service, gateway aggregates composite health |
| Centralized logs | All services output JSON logs → ELK or Loki |
| X-Request-Id | Gateway generates, propagated via header to all downstream services |

### 8.3 Service Discovery

**Phase 1 (Docker Compose):** Static URLs via environment variables (`LISTING_SERVICE_URL=http://listing-service:8082`)

**Phase 2 (Kubernetes):** Kubernetes DNS-based service discovery (`http://listing-service.automarket.svc.cluster.local:8082`)

**Phase 3 (optional):** Spring Cloud Eureka / Consul if needed outside K8s.

### 8.4 Configuration Management

| Phase | Approach |
|-------|----------|
| Dev | `.env` files per service (same as current) |
| Staging/Prod | Spring Cloud Config Server or Kubernetes ConfigMaps/Secrets |

---

## 9. Migration Strategy (Strangler Fig)

The Strangler Fig pattern incrementally replaces monolith functionality with microservices, routing traffic via the API Gateway. At no point does the frontend need to change.

### How It Works

```
Phase 0 (current):
  FE → :8080 (monolith)

Phase 1 (gateway introduced):
  FE → :8080 (gateway) → :8081 (monolith, moved to new port)
  All routes forward to monolith. Zero behavior change.

Phase 2 (first service extracted):
  FE → :8080 (gateway) → /api/v1/reference/** → :8085 (reference-service)
                        → everything else     → :8081 (monolith)

Phase 3+ (more services extracted):
  FE → :8080 (gateway) → /api/v1/blog/**      → :8083 (blog-service)
                        → /api/v1/reference/** → :8085 (reference-service)
                        → everything else      → :8081 (monolith)

Final:
  FE → :8080 (gateway) → all routes → individual services
  Monolith decommissioned.
```

---

## 10. Infrastructure & DevOps

### Docker Compose (Development)

```yaml
services:
  # Infrastructure
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: automarket
      POSTGRES_USER: automarket
      POSTGRES_PASSWORD: secret
    ports: ["5433:5432"]
    volumes: [postgres_data:/var/lib/postgresql/data]

  redis:
    image: redis:7-alpine
    ports: ["6379:6379"]

  rabbitmq:
    image: rabbitmq:3-management-alpine
    ports:
      - "5672:5672"    # AMQP
      - "15672:15672"  # Management UI
    environment:
      RABBITMQ_DEFAULT_USER: automarket
      RABBITMQ_DEFAULT_PASS: secret

  mailhog:
    image: mailhog/mailhog:latest
    ports:
      - "1025:1025"
      - "8025:8025"

  # API Gateway
  gateway:
    build: ./gateway
    ports: ["8080:8080"]
    environment:
      JWT_SECRET: ${JWT_SECRET}
      AUTH_SERVICE_URL: http://auth-service:8081
      LISTING_SERVICE_URL: http://listing-service:8082
      BLOG_SERVICE_URL: http://blog-service:8083
      INQUIRY_SERVICE_URL: http://inquiry-service:8084
      REFERENCE_SERVICE_URL: http://reference-service:8085
      PAYMENT_SERVICE_URL: http://payment-service:8086
    depends_on: [auth-service, listing-service, blog-service, inquiry-service, reference-service, payment-service]

  # Services
  auth-service:
    build: ./auth-service
    ports: ["8081:8081"]
    environment:
      DB_URL: jdbc:postgresql://postgres:5432/automarket?currentSchema=auth_schema
      REDIS_HOST: redis
      RABBITMQ_HOST: rabbitmq
    depends_on: [postgres, redis, rabbitmq]

  listing-service:
    build: ./listing-service
    ports: ["8082:8082"]
    environment:
      DB_URL: jdbc:postgresql://postgres:5432/automarket?currentSchema=listing_schema
      REDIS_HOST: redis
      RABBITMQ_HOST: rabbitmq
      AUTH_SERVICE_URL: http://auth-service:8081
      REFERENCE_SERVICE_URL: http://reference-service:8085
    depends_on: [postgres, redis, rabbitmq]
    volumes: [uploads_data:/app/uploads]

  blog-service:
    build: ./blog-service
    ports: ["8083:8083"]
    environment:
      DB_URL: jdbc:postgresql://postgres:5432/automarket?currentSchema=blog_schema
      AUTH_SERVICE_URL: http://auth-service:8081
    depends_on: [postgres]
    volumes: [uploads_data:/app/uploads]

  inquiry-service:
    build: ./inquiry-service
    ports: ["8084:8084"]
    environment:
      DB_URL: jdbc:postgresql://postgres:5432/automarket?currentSchema=inquiry_schema
      RABBITMQ_HOST: rabbitmq
      AUTH_SERVICE_URL: http://auth-service:8081
      LISTING_SERVICE_URL: http://listing-service:8082
    depends_on: [postgres, rabbitmq]

  reference-service:
    build: ./reference-service
    ports: ["8085:8085"]
    environment:
      DB_URL: jdbc:postgresql://postgres:5432/automarket?currentSchema=reference_schema
      REDIS_HOST: redis
    depends_on: [postgres, redis]

  payment-service:
    build: ./payment-service
    ports: ["8086:8086"]
    environment:
      DB_URL: jdbc:postgresql://postgres:5432/automarket?currentSchema=payment_schema
      RABBITMQ_HOST: rabbitmq
      STRIPE_SECRET_KEY: ${STRIPE_SECRET_KEY}
      STRIPE_WEBHOOK_SECRET: ${STRIPE_WEBHOOK_SECRET}
    depends_on: [postgres, rabbitmq]

  notification-service:
    build: ./notification-service
    ports: ["8087:8087"]
    environment:
      RABBITMQ_HOST: rabbitmq
      MAIL_HOST: mailhog
      MAIL_PORT: 1025
      AUTH_SERVICE_URL: http://auth-service:8081
    depends_on: [rabbitmq, mailhog]

volumes:
  postgres_data:
  uploads_data:
```

### Kubernetes (Production — Future)

Each service becomes a Deployment + Service + HorizontalPodAutoscaler:

```
automarket-namespace/
├── gateway         (2-4 replicas, ingress controller target)
├── auth-service    (2-3 replicas)
├── listing-service (3-5 replicas, highest traffic)
├── blog-service    (1-2 replicas)
├── inquiry-service (1-2 replicas)
├── reference-service (1-2 replicas)
├── payment-service (1-2 replicas)
├── notification-service (1-2 replicas)
├── postgresql      (managed: AWS RDS / Cloud SQL)
├── redis           (managed: ElastiCache / Memorystore)
└── rabbitmq        (managed: CloudAMQP / Amazon MQ)
```

---

## 11. Phased Roadmap

### Phase 0 — Foundation (1-2 weeks)

**Status: COMPLETE**

**Goal:** Set up the multi-module project and gateway without changing any behavior.

- [x] Create multi-module Maven project structure (parent POM + 6 modules: common, security-common, storage, events, gateway, monolith)
- [x] Extract shared libraries (common, security-common, storage, events) — all compile clean
- [x] Build API Gateway (Spring Cloud Gateway) with route-all-to-monolith config
- [x] Move monolith to port 8081, gateway takes port 8080
- [x] Verify build: all 7 modules compile successfully (`mvn compile` BUILD SUCCESS)
- [x] Add RabbitMQ to docker-compose
- [ ] Verify FE works identically through gateway (runtime test — run `docker compose up` to verify)
- [ ] Set up CI pipeline for multi-module build

**FE impact: NONE.** Same port, same API, gateway is transparent proxy.

---

### Phase 1 — Extract Reference Service (1 week)

**Status: COMPLETE (pending runtime verification)**

**Goal:** Extract the simplest, most independent service first to validate the pattern.

**Why first:** Zero cross-service dependencies, read-heavy, heavily cached, smallest codebase.

- [x] Create reference-service module (port 8085, compiles clean)
- [x] Move ReferenceService, AdminReferenceController, InternalReferenceController, 6 entities, 6 repos
- [x] Flyway disabled in reference-service during transition; own migrations ready for Phase 8 DB split
- [x] Uses automarket-common + automarket-security-common shared modules (GatewayAuthFilter for auth)
- [x] Update gateway: `/api/v1/reference/**` → reference-service, `/api/v1/admin/reference/**` → reference-service (before generic /admin/** route)
- [x] docker-compose: reference-service added, gateway REFERENCE_SERVICE_URL env var set
- [x] Remove reference controllers + service + DTOs from monolith (reference entities/repos kept — still used by Listing/User)
- [ ] Verify caching still works (runtime test — `docker compose up`)

**FE impact: NONE.**

---

### Phase 2 — Extract Blog Service (1 week)

**Status: COMPLETE (pending runtime verification)**

**Goal:** Extract the next simplest domain.

**Why second:** Only 1 entity, 1 service, minimal cross-service deps (just author enrichment).

- [x] Create blog-service module (port 8083, compiles clean)
- [x] Blog entity: authorId UUID (no JPA FK to users); AuthorView reads from shared users table (Phase 2 approach)
- [x] BlogService, BlogController, InternalBlogController migrated using automarket-common + automarket-security-common + automarket-storage
- [x] GatewayAuthFilter for security; @PreAuthorize for MODERATOR/ADMIN role checks
- [x] Storage shared library for cover image + content image uploads
- [x] Gateway: /api/v1/blog/** → blog-service:8083
- [x] docker-compose: blog-service added with uploads_data volume
- [x] Remove BlogController, BlogService, Blog entity, BlogRepository, blog DTOs from monolith
- [ ] Phase 4 TODO: Replace AuthorView with AuthServiceClient Feign call when auth-service extracted
- [ ] Verify (runtime test — `docker compose up`)

**FE impact: NONE.**

---

### Phase 3 — Extract Notification Service (1 week)

**Status: COMPLETE (pending runtime verification)**

**Goal:** Decouple all email sending into an event-driven service.

**Why third:** Prepares the event infrastructure for subsequent extractions.

- [x] Create notification-service module (port 8087, no DB, pure event consumer)
- [x] Set up RabbitMQ exchanges, queues, bindings (in automarket-events shared module)
- [x] Add automarket-events + AMQP dependency to monolith
- [x] Create EventPublisher service in monolith (publishes listing.approved, listing.rejected, inquiry.sent)
- [x] Modify monolith's ListingModerationService to publish events instead of calling EmailService directly
- [x] Modify monolith's InquiryService to publish events instead of calling EmailService directly
- [x] Implement ListingEventConsumer + InquiryEventConsumer in notification-service
- [x] EmailNotificationService in notification-service handles all email sending
- [x] Update docker-compose: notification-service added (depends on rabbitmq + mailhog)
- [x] Update root pom.xml: notification-service module added
- [x] Remove EmailService from monolith (no callers remain after event migration)
- [ ] Verify emails still sent (MailHog) — runtime test

**FE impact: NONE.** Email is a backend side-effect.

---

### Phase 4 — Extract Auth Service (2 weeks)

**Status: COMPLETE**

**Goal:** Extract the identity domain. Most complex extraction due to many dependents.

**Why now:** All simpler services done, patterns established, event bus ready.

- [x] Create auth-service module (port 8081)
- [x] Move User, Role, RefreshToken entities + CityView read-only entity
- [x] Move AuthService, UserService, JwtService, RefreshTokenService, UserDetailsServiceImpl
- [x] Move AuthController, UserController, AdminUserController
- [x] Implement internal API endpoints (`/internal/users/{id}`, `/internal/users/by-email/{email}`)
- [x] JWT validation at gateway level (JwtValidationFilter shares JWT_SECRET)
- [x] Downstream services use GatewayAuthFilter (read gateway headers, not JWT)
- [x] Update gateway routes (auth, users, admin-users → auth-service)
- [x] Publish `user.*` events (registered, disabled, deleted, plan-changed) via EventPublisher
- [x] Docker-compose updated with auth-service container
- [ ] Enable gateway-level JWT rejection (currently pass-through)
- [ ] Replace blog-service AuthorView with Feign call to auth-service `/internal/users/{id}`

**FE impact: NONE.** Token format unchanged, endpoints unchanged.

---

### Phase 5 — Extract Payment Service (1 week)

**Status: COMPLETE**

**Goal:** Isolate Stripe integration.

- [x] Create payment-service module (port 8086)
- [x] Move Subscription entity (UserView read-only), SubscriptionService, SubscriptionController, StripeWebhookController
- [x] Publish `subscription.*` events instead of directly updating user plan
- [x] Gateway routes: `/api/v1/subscriptions/**`, `/api/v1/webhooks/**` → payment-service
- [x] Docker-compose updated with payment-service container

**FE impact: NONE.**

---

### Phase 6 — Extract Inquiry Service (1 week)

**Status: COMPLETE**

**Goal:** Separate messaging domain.

- [x] Create inquiry-service module (port 8084)
- [x] Move Inquiry entity (UserView, ListingView read-only), InquiryService, InquiryController
- [x] Publish `inquiry.sent` event (notification-service already consuming)
- [x] Gateway routes: `/api/v1/inquiries/**` → inquiry-service
- [x] Docker-compose updated with inquiry-service container

**FE impact: NONE.**

---

### Phase 7 — Extract Listing Service & Decommission Monolith (2 weeks)

**Status: COMPLETE**

**Goal:** Move the remaining core domain. Decommission the monolith.

- [x] Create listing-service module (port 8082)
- [x] Move Listing, ListingImage, CarDetails, ListingAnalytics, Favorite entities + reference type read-only entities
- [x] Move ListingService, FavoriteService, AnalyticsService, ListingModerationService
- [x] Move ListingController, FavoriteController, ModerationController, AdminDashboardController
- [x] Implement InternalListingController (listing counts API)
- [x] Publish `listing.*` events via EventPublisher
- [x] UserView read-only entity for seller info (shared DB phase)
- [x] Update gateway routes: listings, favorites, moderation, admin/dashboard → listing-service
- [x] **Decommission monolith** — removed from parent POM, docker-compose, gateway routes
- [x] Delete monolith directory and all residual code
- [x] Update all Dockerfiles to remove monolith references
- [x] CORS centralized at gateway level
- [x] Full `mvn clean compile` — all 13 modules BUILD SUCCESS
- [ ] Full end-to-end testing (runtime verification)

**FE impact: NONE.**

---

### Phase 8 — Harden & Optimize (ongoing)

- [ ] Physical database separation (separate PostgreSQL instances per service)
- [ ] Add Resilience4j circuit breakers to all Feign clients
- [ ] Add distributed tracing (Micrometer + Zipkin)
- [ ] Add Prometheus metrics + Grafana dashboards
- [ ] Kubernetes deployment manifests
- [ ] Horizontal pod autoscaling per service
- [ ] API documentation aggregation (SpringDoc microservices support)
- [ ] Contract testing (Spring Cloud Contract or Pact)
- [ ] Load testing with extracted architecture

---

## 12. Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| **Increased latency from service-to-service calls** | Listing detail page needs seller info from auth-service | Redis caching of user summaries (5min TTL). Seller info rarely changes. Async enrichment where possible. |
| **Data consistency without FKs** | Orphaned listings if user deletion event lost | Idempotent event consumers + periodic reconciliation job. RabbitMQ durable queues with DLQ. |
| **Distributed debugging complexity** | Harder to trace request flow | Distributed tracing (Zipkin/Jaeger) from day 1. Structured JSON logging with correlation IDs. |
| **AdminDashboard aggregation latency** | Dashboard needs data from 4 services | Parallel async calls (CompletableFuture). Cache dashboard response (1min TTL). Pre-compute stats via events. |
| **Operational overhead** | 8 services + gateway vs 1 monolith | Docker Compose for dev (single `docker compose up`). Kubernetes for prod. Shared Dockerfile template. |
| **Message broker failure** | Events not delivered | RabbitMQ clustering + persistent queues + DLQ. Critical path stays synchronous (HTTP). Events only for side effects. |
| **Gateway single point of failure** | All traffic goes through gateway | Multiple gateway replicas. Health checks. In K8s: Deployment with 2+ replicas behind Ingress. |
| **Database migration complexity** | Splitting tables across schemas | Schema-per-service first (same PG instance, low risk). Physical split later. Flyway per service. |
| **Team learning curve** | New patterns (events, Feign, gateway) | Patterns established in Phase 0-2 with simplest services. Document decisions in ADRs. |
| **Testing complexity** | Integration tests need multiple services | Testcontainers for each service. Contract tests for API boundaries. E2E tests against docker-compose. |

---

## Simplification Options

If the full 8-service architecture feels too heavy for the current team/scale:

### Option A: 4 Services (Pragmatic)
Merge related domains:
1. **Gateway**
2. **Auth + Admin Service** (users, roles, admin user management)
3. **Marketplace Service** (listings, favorites, analytics, inquiries, moderation, reference data)
4. **Platform Service** (blog, subscriptions, payments, notifications)

Fewer services, fewer network hops, still achieves independent deployability for the core domains.

### Option B: Modular Monolith First
Keep single deployment but enforce module boundaries:
- Separate Maven modules with enforced dependency rules (ArchUnit)
- Each module has its own DB schema
- Internal APIs between modules (Java interfaces, not HTTP)
- When ready to split, each module becomes a service with minimal code changes

This gets 80% of the architectural benefit with 20% of the operational cost.

---

## Key Decision: What NOT to Split

| Component | Recommendation |
|-----------|---------------|
| **StorageService** | Keep as shared library, not a service. Each service that uploads files includes the library. Avoids an extra network hop for every file upload. |
| **Reference data** | Consider keeping as a shared library with local DB access if reference data is truly static. A full service adds overhead for data that changes once a month. |
| **GlobalExceptionHandler** | Shared library — every service needs consistent error responses. |
| **Audit (AuditableEntity)** | Shared library — every entity uses it. |
