# AutoMarket2 BE — Architecture Status

Living status of the microservice architecture. Companion to `ISSUES.md` (defects);
this file tracks **what exists, what is half-built, and what is only a placeholder**.

Last reviewed: 2026-09-17, branch `feature/devops-setup`.

**Decisions taken** (2026-09-17):
- Target data architecture: **schema-per-service** in one PostgreSQL instance
- Deployment context: **thesis / academic project** — prioritise a working, defensible demo
- Event bus: **Kafka replaces RabbitMQ** ✅ done
- `/internal/**` HTTP API: **delete it, go event-only**
- Stripe: wire a **sandbox (test mode)** — see §6

**Decisions taken** (2026-09-17, second pass — see §8):
- listing-service: **keep as a modular monolith core**, documented as a deliberate
  design rather than split (#43)
- Dual write: implement the **transactional outbox** (#39)
- Event contracts: **fat events, producer-side projections** — producers source data
  from their own projection of `user-events`, never a cross-service read (#40)
- Schema evolution: **tolerant-reader policy**, additive-only, no registry (#45)

**Legend**
- ✅ **Implemented** — working, wired end to end
- 🟡 **Partial** — works, but with a known gap or shortcut
- 🔌 **Abstracted only** — the shape exists (interface, endpoint, event, config) but nothing uses it
- ❌ **Missing** — referenced by the design but absent
- 💥 **Broken** — present and wired, but does not work

---

## 1. System map

| Service | Port | Owns (tables) | Reads from others | Events out | Events in |
|---|---|---|---|---|---|
| gateway | 8080 | — | — | — | — |
| auth-service | 8081 | `users`, `roles`, `user_roles`, `refresh_tokens` | `cities` | user.* | ❌ none |
| listing-service | 8082 | `cities`, `car_brands`, `body_types`, `fuel_types`, `transmission_types`, `condition_types`, `listings`, `listing_images`, `listing_analytics`, `favorites` | `users` | listing.approved/rejected | ❌ none |
| blog-service | 8083 | `blogs` | `users` | — | ❌ none |
| inquiry-service | 8084 | `conversations`, `messages`, `inquiries` (archive) | `users`, `listings` | inquiry.sent, inquiry.replied | ❌ none |
| payment-service | 8086 | `subscriptions` | `users` | subscription.* | ❌ none |
| notification-service | 8087 | — | — | — | ✅ listing + inquiry topics |

`reference-service` was merged into `listing-service`. Its directory is still in the
repo and must be deleted — `ISSUES.md` #22.

All seven services share **one PostgreSQL database and one schema**. Target is one
schema per service (§5, Phase 3).

---

## 2. Feature status

### Core domain

| Capability | Status | Notes |
|---|---|---|
| Register / login / refresh / logout | ✅ | JWT + refresh tokens |
| Role-based authorization | ✅ | USER / MODERATOR / ADMIN via `X-User-Roles` |
| Listing CRUD + slug + search | ✅ | JPA Specifications |
| Listing images (multipart) | ✅ | |
| Favorites | ✅ | |
| Listing moderation (approve/reject) | ✅ | Publishes events, emails sent |
| Reference data (brands, cities, …) | ✅ | Redis-cached; seed restored in `V2` |
| Blog CRUD | ✅ | Fixed — finding #30 |
| Blog authorship enforcement | ✅ | `ISSUES.md` #17 |
| Inquiries | ✅ | |
| Email notifications | ✅ | Failures now retried then dead-lettered |
| Stripe checkout | 🟡 | Real implementation, flag-disabled; sandbox pending (§6) |
| Stripe webhook → subscription row | ✅ | Fixed — finding #30 |
| Paid plan actually upgrades the user | 💥 | **Still broken** — finding #31, needs the consumer |
| Free-plan listing cap (3) | ✅ | Reads `users.plan` directly |
| Seller public profile | ✅ | Counted from `auth_listing_view` — finding #28 |
| Admin dashboard | 🟡 | Listing counts only |
| Admin user management | ✅ | |
| Welcome email on registration | ❌ | `user.registered` published, no handler exists |

### Cross-cutting

| Concern | Status | Notes |
|---|---|---|
| API gateway routing | ✅ | All 14 routes resolve to real services |
| JWT validation at edge | ✅ | `ISSUES.md` #1 |
| Header-based downstream auth | 🟡 | Trusts headers unconditionally — finding #33 |
| CORS | ✅ | Centralised at gateway |
| Redis caching | 🟡 | Real in listing-service; `@EnableCaching` unused in auth-service |
| Rate limiting | 🔌 | Gateway pulls `data-redis-reactive` for it; never wired — finding #36 |
| Storage abstraction (local + S3) | ✅ | Both providers genuinely implemented |
| Flyway migrations | ✅ | Per-service history tables (`ISSUES.md` #18) |
| JPA auditing | ✅ | Fixed — finding #30 |
| **Event bus (Kafka)** | ✅ | Migrated from RabbitMQ — §3 |
| Dead-letter handling | ✅ | `DefaultErrorHandler` → `<topic>-dlt` |
| Prometheus metrics | 💥 | Scrapes return 401 — finding #32 |
| Grafana | 🟡 | Datasource provisioned, no dashboards committed |
| Distributed tracing | ❌ | None |
| Automated tests | ❌ | **0 test files across 11 modules** — finding #35 |
| CI build + push | ✅ | 7 services, GHA cache |
| CI tests / lint / scan | ❌ | Build only |
| ArgoCD GitOps | ✅ | Tracks `master` |
| NetworkPolicy | ❌ | Finding #33 |
| HPA / PodDisruptionBudget | ❌ | All `replicas: 1` — finding #38 |

### Service-to-service HTTP API — **slated for deletion**

An `/internal/**` API was designed for cross-service calls. The server side exists;
**no client does** — there is no Feign, `RestTemplate`, `WebClient` or `RestClient`
anywhere in the repository. Decision: delete it and rely on events.

| Endpoint | Action |
|---|---|
| `GET /internal/users/{id}` | delete — replaced by local projections |
| `GET /internal/users/by-email/{email}` | delete |
| `GET /internal/listings/count-by-user/{userId}` | delete — `totalListings` from projection |
| `GET /internal/listings/stats` | delete |
| `GET /internal/blogs/count` | delete |

Until removed, every one is `permitAll()` on its service — see finding #33.

---

## 3. Event bus — Kafka

Migrated from RabbitMQ on 2026-09-17. Single-node **KRaft** (no ZooKeeper) in both
docker-compose and Kubernetes.

### Topics

One topic per aggregate; the specific event is carried in `EventEnvelope.eventType`.
Records are **keyed by aggregate id**, so all events about one entity share a partition
and are consumed in publication order.

| Topic | Key | Event types | Producer | Consumer group |
|---|---|---|---|---|
| `automarket.user-events` | userId | user.registered, user.disabled, user.deleted, user.plan-changed | auth | *(none yet — Phase 1)* |
| `automarket.listing-events` | listingId | listing.approved, listing.rejected | listing | `notification-service` ✅ |
| `automarket.inquiry-events` | conversationId | inquiry.sent, inquiry.replied | inquiry | `notification-service` ✅ |
| `automarket.subscription-events` | userId | subscription.activated, subscription.cancelled | payment | *(none yet — finding #31)* |

Each topic also has a `<topic>-dlt` companion, created on first failure.

### Why this fixes two previous findings

- **`ISSUES.md` #27 (queues growing forever) is resolved by the model change.** Under
  RabbitMQ, a bound queue with no consumer accumulated durable messages until the
  broker died. A Kafka topic with no consumer just ages out under retention
  (`KAFKA_LOG_RETENTION_HOURS=168`). The shared module can therefore declare every
  topic in every service harmlessly — which was never true of queues and bindings.
- **`ISSUES.md` #29 (silently dropped events) is properly fixed.** The consumer no
  longer swallows exceptions. `DefaultErrorHandler` retries 3× at 2s, then
  `DeadLetterPublishingRecoverer` parks the record on `<topic>-dlt`. Unrecognised event
  types return normally rather than throwing, so they are not dead-lettered as noise.

`ISSUES.md` #23 (RabbitMQ connection retry) is **superseded**: the producer now uses
`acks=all`, `retries=5` and `enable.idempotence=true`; the consumer uses
`auto-offset-reset=earliest` with manual (record-level) acks.

### Ordering note

`subscription-events` is keyed by **userId, not subscription id** — deliberately. If
`activated` and `cancelled` for one user landed on different partitions, a stale
activation could overtake a cancellation and leave a non-paying user on PREMIUM.

### Delivery semantics

Kafka is **at-least-once**. Every consumer written from here on must be idempotent.
`EventEnvelope.eventId` exists for exactly this — dedupe on it, or make the write
naturally idempotent (e.g. "set plan to PREMIUM" rather than "increment").

### Local access

- Services inside compose: `kafka:19092`
- From the IDE / host: `localhost:9092`
- Kafka UI (topics, messages, consumer lag): **http://localhost:8090**

---

## 4. Findings (continuing `ISSUES.md` numbering)

### 30. ✅ FIXED — `@EnableJpaAuditing` missing in blog-service and payment-service

`AuditableEntity` populates `created_at`/`updated_at` through `@CreatedDate` /
`@LastModifiedDate`, which fire **only** when `@EnableJpaAuditing` is in that service's
context. auth and listing had it; blog and payment did not. Both
`blogs.created_at/updated_at` and `subscriptions.created_at/updated_at` are
`NOT NULL` with **no DB default**, so Hibernate threw `PropertyValueException` at flush.

**Every blog post creation failed. Every subscription persist failed.**

inquiry-service also lacks the annotation but is unaffected — `Inquiry` does not extend
`AuditableEntity` and sets `createdAt` via `@Builder.Default`.

**Fixed:** `@EnableJpaAuditing` added to `BlogServiceApplication` and
`PaymentServiceApplication`, plus an `AuditorAwareConfig` in each.

---

### 31. 💥 CRITICAL — Paid upgrades never take effect *(open)*

```
Stripe webhook → payment-service writes `subscriptions`      ✅ fixed by #30
               → publishes subscription.activated            ✅ now on Kafka
               → topic automarket.subscription-events
               → ❌ no consumer
               → users.plan stays FREE
               → listing-service still enforces max-per-free-user: 3
```

A customer can complete checkout, be charged, and receive nothing. Needs a
`SubscriptionEventConsumer` in auth-service under group `auth-service`, idempotent on
`eventId` or on the target state.

---

### 32. 💥 HIGH — Prometheus scraping returns 401 on every service *(open)*

Hardening `/actuator/` (`ISSUES.md` #11/#12) left each service permitting only
`/actuator/health`; `/actuator/prometheus` now falls to `anyRequest().authenticated()`.
Prometheus scrapes services **directly**, sending no `X-User-*` headers, so every scrape
401s and all dashboards are blank.

Services are not in the ingress, so permitting `/actuator/prometheus` at service level
is acceptable — ideally with the NetworkPolicy from #33.

---

### 33. ⚠️ HIGH — Any pod in the namespace can impersonate an admin *(open)*

`GatewayAuthFilter` trusts `X-User-Email` / `X-User-Roles` unconditionally. The gateway
strips them inbound, so the boundary holds for gateway traffic — but services are
reachable on their ClusterIP, there is **no NetworkPolicy**, and `/internal/**` is
`permitAll()` everywhere:

```bash
curl -H "X-User-Roles: ROLE_ADMIN" http://listing-service:8082/api/v1/admin/...
curl http://auth-service:8081/internal/users/by-email/admin@automarket.com
```

**Fix:** NetworkPolicy (gateway → services, Prometheus → actuator), plus a shared secret
header the gateway injects and `GatewayAuthFilter` verifies. Deleting `/internal/**`
removes half the surface on its own.

The gateway's own actuator is also unprotected: `JwtValidationFilter` is a
`GlobalFilter`, and those run only for **routed** requests — `/actuator/**` matches no
route. Masked today only because the ingress does not map `/actuator`.

---

### 34. ⚠️ MEDIUM — Liveness probes use the aggregate health endpoint *(open)*

All three probes on all eight deployments hit `/actuator/health`, which aggregates DB,
Redis and Kafka health. A transient Postgres blip fails **liveness**, so Kubernetes
restarts every pod at once — which cannot fix a remote dependency and hammers the
database on recovery.

**Fix:** `management.endpoint.health.probes.enabled: true`, liveness →
`/actuator/health/liveness`, readiness → `/actuator/health/readiness`.

---

### 35. ⚠️ MEDIUM — No automated tests anywhere *(open)*

0 test files across 11 modules. Findings #30 and #31 would each have been caught by a
single slice test.

---

### 36. 🔌 MEDIUM — No rate limiting; the gateway's Redis dependency is unused *(open)*

`gateway/pom.xml` pulls `spring-boot-starter-data-redis-reactive` and configures
`spring.data.redis`, but there is no `RequestRateLimiter`. `/api/v1/auth/login` and
`/register` are public and unthrottled.

---

### 37. 🔌 LOW — `listing.created` declared but never published *(open)*

`ListingEvent.CREATED` is a constant with no publisher.

---

### 38. ⚠️ LOW — Single replica everywhere, no HPA or PodDisruptionBudget *(open)*

For a thesis deployment this is acceptable; document it as a deliberate trade-off
rather than an oversight.

---

## 5. Plan

> **Superseded by §8 (Plan v2)** after the deep architecture review of 2026-09-17.
> Phases 0–1 below still stand; Phase 2 onwards is restructured there.

Reprioritised for a thesis project: correctness and a defensible architecture story
first; operational hardening becomes documentation rather than work.

### Phase 0 — Make it work ✅ complete
1. ✅ Per-service Flyway history tables — `ISSUES.md` #18
2. ✅ Restore reference seed data — `ISSUES.md` #19
3. ✅ `@EnableJpaAuditing` in blog + payment — #30
4. ✅ Kafka replaces RabbitMQ
5. ⬜ `git rm -r reference-service` — `ISSUES.md` #22
6. ⬜ Smoke test: register → listing → approve → inquire → blog → checkout

### Phase 1 — Close the event loops *(next)*
7. **`SubscriptionEventConsumer` in auth-service** — #31, idempotent on `eventId`
8. **`UserEventConsumer` in listing-service** — `user.disabled`/`deleted` unpublish listings
9. Welcome email handler for `user.registered`, or drop the event
10. Decide `listing.created`: publish it or delete the constant (#37)

### Phase 2 — Data ownership (the core thesis contribution)
11. Local projection tables per consumer (`blog_author_view`, `inquiry_user_view`, …),
    populated from `user-events` / `listing-events`
12. Delete every cross-service `@Table` read-model — `ISSUES.md` #26
13. Delete the `/internal/**` controllers
14. `hibernate.default_schema` + `flyway.schemas` per service → **schema-per-service**
15. #28 — `totalListings` from the listing projection

> Order matters: projections must exist and be populated **before** the schema split,
> or the cross-service reads break with nothing to replace them.

### Phase 3 — Security perimeter
16. #32 — permit `/actuator/prometheus` at service level, restore monitoring
17. #33 — NetworkPolicy + shared gateway secret header
18. #36 — Redis `RequestRateLimiter` on `/api/v1/auth/**`
19. Rotate the credentials leaked in `.env` — `ISSUES.md` #20

### Phase 4 — Demonstrable quality
20. #35 — tests covering the Phase 0/1 regressions; add a CI test gate
21. #34 — split liveness/readiness probes
22. Grafana dashboards committed; Kafka consumer-lag panel
23. #38 — document single-replica as a deliberate thesis-scope trade-off

---

## 6. Stripe sandbox

Nothing in the code is live-mode specific, so the sandbox is **configuration only**.

1. **Keys** — Stripe Dashboard in *Test mode* → Developers → API keys:
   `STRIPE_SECRET_KEY=sk_test_...`
2. **Price** — create a Product with a recurring Price in test mode:
   `STRIPE_PRICE_PREMIUM=price_...`
3. **Webhook secret** — Stripe cannot reach `automarket.local`, so forward with the CLI:
   ```bash
   stripe login
   stripe listen --forward-to http://localhost:8080/api/v1/webhooks/stripe
   ```
   It prints `whsec_...` → `STRIPE_WEBHOOK_SECRET`.
4. **Enable** — `STRIPE_ENABLED=true`
5. **Test card** — `4242 4242 4242 4242`, any future expiry, any CVC.

**The flow only completes end to end once #31 is done.** Today the webhook is received
and the `subscriptions` row is written (after #30), but nothing applies the plan change
to `users.plan`.

Route check: `/api/v1/webhooks/**` is public at both the gateway (`PUBLIC_PREFIXES`) and
payment-service (`permitAll`), so the callback reaches the controller. Signature
verification uses the raw body, and the gateway's only default filter adds a header —
it does not touch the body, so verification holds.

---

## 7. Open questions

1. **Kafka resource budget** — the broker asks 768Mi/1Gi versus RabbitMQ's 200–350Mi. On
   a single-node k3d cluster alongside Postgres, Redis, Prometheus and Grafana, is there
   headroom, or should the thesis demo run on docker-compose only?
2. **Welcome email** — implement it, or drop `user.registered`?
3. **Schema split timing** — before or after the thesis deadline? It is the most
   interesting chapter but also the largest change.

---

## 8. Deep architecture review (2026-09-17, second pass)

The first pass catalogued defects. This pass interrogates the **design**: whether the
decomposition is right, whether the contracts hold, and what specifically keeps this a
distributed monolith rather than a set of services.

### 8.1 The core claim

> The system pays the full cost of distribution while remaining coupled at three
> mechanical points. None of them is "it shares a database" — that is a symptom.

**A. Event contracts force the coupling they were meant to remove.**

`ListingEvent.Approved(listingId, sellerId, sellerEmail, listingTitle)` carries the
seller's **email**. listing-service can only populate that by reading auth-service's
`users` table:

```java
// ListingModerationService.approve()
eventPublisher.publishListingApproved(
        listing.getId(),
        listing.getSeller().getId(),
        listing.getSeller().getEmail(),   // <- reads auth-service's table
        listing.getTitle());
```

The event payload was designed as a **notification DTO**, not a domain event — it
carries exactly what notification-service needs to render an email. So the cross-service
read cannot be deleted until the event contract changes. **This blocks the schema split
and nothing else in the plan reveals that dependency.**

**B. JPA associations cross service boundaries.**

`Listing.seller` is not a lookup — it is a mapped relationship into another service's
table:

```java
@ManyToOne(fetch = FetchType.LAZY)
@JoinColumn(name = "seller_id", nullable = false)
private UserView seller;          // -> @Table(name = "users"), owned by auth-service
```

A schema split breaks this at the database level, not just the ORM level. Every
`listing.getSeller().getEmail()` is a cross-context join that must become a local
projection read.

**C. Four shared modules couple the services at build time.**

`automarket-common`, `automarket-events`, `automarket-security-common`,
`automarket-storage`. Changing `automarket-events` forces a rebuild and redeploy of all
seven services — they cannot evolve independently, which is most of the point of
services. With Kafka carrying shared Java records there is also no schema-evolution
story: a field added to `UserEvent.Registered` is a lockstep deploy.

### 8.2 The decomposition is lopsided

| Service | Java files | Controllers | Bounded contexts |
|---|---|---|---|
| listing-service | **50** | **7** | catalog, reference data, moderation, engagement |
| auth-service | 29 | 4 | identity |
| blog-service | 13 | 2 | content |
| inquiry-service | 13 | 1 | messaging |
| payment-service | 12 | 2 | billing |
| notification-service | 3 | 0 | delivery |
| gateway | 2 | 0 | edge |

listing-service is larger than blog + inquiry + payment + notification **combined**, and
spans at least four distinct contexts with different actors and lifecycles:

- **Catalog** — listings, images, car details, search (seller-driven)
- **Reference data** — cities, brands, fuel types (admin-driven, read-mostly, cached)
- **Moderation** — approve/reject workflow (moderator-driven, different lifecycle)
- **Engagement** — favorites, analytics (buyer-driven, high write volume)

The migration extracted the *peripheral* concerns and left the **core domain
untouched**. That is the classic half-migration: full distribution cost, decomposition
benefit only where change is least frequent.

This is not automatically wrong — a deliberate "modular monolith core + satellite
services" is a defensible architecture. But it should be a stated decision, not an
accident of which parts were easiest to lift out.

### 8.3 New findings

---

#### 39. CRITICAL — Dual write: every event is published inside an open DB transaction

Every publisher call sits inside `@Transactional`:

| Service | Method | Location |
|---|---|---|
| auth | `register()` | `AuthService:73` |
| auth | `deleteUser()` | `UserService:104` |
| inquiry | `startOrAppend()` / `reply()` | `ConversationService` |
| listing | `approve()` / `reject()` | `ListingModerationService:41,55` |
| payment | webhook handlers | `SubscriptionService:217,242` |

Two divergence modes:

1. **Event published, transaction rolls back** — consumers act on state that does not
   exist. A rolled-back `register()` still sends a welcome email; a rolled-back
   `publishSubscriptionActivated` still upgrades a user who never paid.
2. **Transaction commits, publish fails** — state changed, nobody hears. Listing
   approved, seller never notified. Subscription active, plan never upgraded.

**The Kafka migration made mode 2 worse, and this is worth stating plainly.**
`KafkaTemplate.send()` returns a `CompletableFuture` that none of the publishers check,
so a send failure after the producer's internal retries is **silent**. The previous
`rabbitTemplate.convertAndSend()` at least threw inside the transaction.

**Fix:** the transactional outbox pattern — write the event to an `outbox` table in the
same transaction as the state change, and relay it to Kafka separately (a poller, or
Debezium CDC). A lighter variant that removes mode 1 only:
`@TransactionalEventListener(phase = AFTER_COMMIT)`, publishing after commit. That still
leaves mode 2, but it is a two-line change and a reasonable thesis-scope compromise if
the full outbox is too much.

---

#### 40. HIGH — Event payloads are notification DTOs, not domain events

See 8.1 A. `ListingEvent.Approved` carries `sellerEmail`; `InquiryEvent.Sent` carries
nine fields including `senderName`, `senderEmail`, `sellerEmail` and `listingTitle`.

Consequences:
- Producers must read other services' data to publish — the coupling we are removing.
- Payloads carry point-in-time copies: an email changed after publication is stale in
  the event, and stale in the DLT forever.
- Adding a second consumer means either fattening the payload further or that consumer
  doing its own lookup.

**Recommended shape:** keep events reasonably fat (event-carried state transfer is a
legitimate choice, and it keeps notification-service stateless with no database) — but
the producer must source that data from **its own local projection** of `user-events`,
never from a cross-service table read. That resolves the coupling without adding a
database to notification-service.

---

#### 41. HIGH — `Listing.seller` is a JPA association into another service's table

See 8.1 B. Must become `sellerId` (a plain `UUID`) plus a local `listing_seller_view`
projection before any schema split. This is the single largest code change in Phase 3.
The same applies to `UserView` / `AuthorView` / `ListingView` in blog, inquiry and
payment.

---

#### 42. HIGH — JWT secret blast radius is all seven services

Tokens are signed **HS256 (symmetric)** — `Keys.hmacShaKeyFor(jwtSecret)` in both
`JwtService` (auth) and `JwtValidationFilter` (gateway). `JWT_SECRET` lives in the
shared `automarket-secret`, which **every** deployment mounts via `envFrom: secretRef`.

So blog-service, inquiry-service and notification-service all hold the key that mints
admin tokens, despite none of them needing to sign or verify anything. Combined with
finding #33 (no NetworkPolicy), one compromised service is total system compromise.

**Fix:** move to **RS256**. auth-service holds the private key and signs; the gateway
holds only the public key and verifies; no other service gets either. Reduces the blast
radius from seven services to one, and is a clean, demonstrable improvement to write up.

---

#### 43. MEDIUM — listing-service is a mini-monolith

See 8.2. Either split it (catalog / reference / engagement) or **document the modular
monolith core as a deliberate decision**. Both are defensible; silence is not.

Lowest-effort meaningful split: extract **reference data** back out. It is read-mostly,
independently cacheable, has a different change cadence and a different actor, and it
already lived as its own service once. Note this would partly reverse the
reference-service merge — worth saying explicitly rather than quietly re-splitting.

---

#### 44. BROKEN — Listing analytics silently records nothing

Four compounding defects in `AnalyticsService.recordView()`:

1. **`@Async` is a no-op** — there is no `@EnableAsync` anywhere in the codebase, so the
   method runs inline on the request thread.
2. **It therefore joins a read-only transaction.** `ListingService.getById()` is
   `@Transactional(readOnly = true)`; `recordView` is `@Transactional` (REQUIRED), so it
   joins the caller's read-only transaction. Hibernate sets `FlushMode.MANUAL` and marks
   loaded entities read-only, so the `save()` and the `setViewCount()` dirty check
   **emit no SQL and throw nothing**.
3. **The `catch (Exception e)` guarantees silence** even in the cases that do throw.
4. **`getById` is `@Cacheable`** — on a cache hit the method body never runs at all, so
   the view is not counted regardless.

Even once 1–4 are fixed, `viewCount` is a read-modify-write with no locking: concurrent
views lose updates.

**Fix:** add `@EnableAsync` — or better, publish a `listing.viewed` event and count it in
a consumer, which fits now that Kafka is in place. Move `recordView` out of the cached
method, and make the increment atomic:
`UPDATE listing_analytics SET view_count = view_count + 1 WHERE ...`.

---

#### 45. MEDIUM — No schema evolution story for events

Shared Java records over JSON means producer and consumer must be deployed in lockstep.
Options, in increasing order of effort:

1. **Tolerant reader** — consumers already use `objectMapper.readTree` and ignore
   unknown fields; document additive-only evolution as the rule. Nearly free.
2. **Schema registry + Avro/Protobuf** — real compatibility enforcement at publish time.
   Meaningful work, and a strong thesis chapter on contract evolution.

---

### 8.4 Plan v2 (supersedes section 5 from Phase 2 onward)

Phases 0 and 1 in section 5 are unchanged. What follows replaces Phase 2 onward.

**Phase 2 — Correctness under distribution** — ✅ **COMPLETE**, see §9
1. ✅ #39 — transactional outbox (`automarket-messaging`) — see §9.1
2. ✅ #31 — `SubscriptionEventConsumer` in auth-service, idempotent on `eventId` — §9.3
3. ✅ #44 — analytics fixed — §9.4
4. ✅ Inbox/dedup table keyed on `eventId` — §9.2

**Phase 3 — Break the coupling** — ✅ steps 5–7 **COMPLETE** (§10); step 8 held for a separate release (§10.6)
5. ✅ #40 — all six cross-service reads replaced by local projections — §10.1
6. ✅ #41 — `Listing.seller` now associates to listing-service's own read model — §10.1
7. ✅ Deleted the `/internal/**` controllers and their permitAll rules — §10.7
8. ⬜ `hibernate.default_schema` + `flyway.schemas` per service — **separate release**, see §10.6

**Phase 4 — Security architecture**
9. #42 — RS256; auth signs with the private key, gateway verifies with the public key
10. #32 — restore Prometheus scraping
11. #33 — NetworkPolicy + shared gateway header
12. #36 — rate limiting on `/api/v1/auth/**`

**Phase 5 — Structure and evolution** *(thesis material)*
13. #43 — split listing-service, or document the modular-monolith core as a decision
14. #45 — schema registry, or a documented tolerant-reader policy
15. #35 — tests; CI test gate

### 8.5 What is genuinely good here

Worth stating, because a review that only lists problems misrepresents the system:

- **Gateway design is correct** — validate once at the edge, forward identity as trusted
  headers, downstream services never re-parse JWTs. Clean and conventional.
- **Storage abstraction is real** — `StorageService` with working local and S3
  implementations selected by config, not a stub.
- **Stripe integration is real** — Checkout Sessions, webhook signature verification,
  customer reconciliation. Not a mock.
- **Caching is thoughtful** — `@Cacheable` / `@CacheEvict` on the right read paths with
  named cache regions (the analytics interaction in #44 notwithstanding).
- **Kafka keying is now correct** — subscription events keyed by user id specifically to
  preserve activate/cancel ordering.
- **Flyway per-service baselines** are well-formed and idempotent.

---

## 9. Phase 2 — Correctness under distribution (implemented 2026-09-17)

All four Phase 2 items are done. New module: **`automarket-messaging`**, depended on by
auth, inquiry, listing and payment (blog publishes and consumes nothing, so it stays out).

### 9.1 Transactional outbox (#39 — fixed)

**Before:** all six publisher call sites ran inside `@Transactional`, and
`KafkaTemplate.send()` returns a future nobody checked. The database could commit while
the publish failed, silently.

**Now:** producers call `OutboxRecorder.record(topic, key, envelope)`, which writes a
row to the `outbox` table in the caller's transaction. Nothing reaches the broker during
the business transaction, so the state change and the intent to publish commit or roll
back as one. `OutboxRelay` publishes afterwards on a fixed delay.

| Component | Responsibility |
|---|---|
| `OutboxEvent` | `outbox` row — id (= `eventId`), source service, topic, key, type, payload, attempts, last error |
| `OutboxRecorder` | Serializes the envelope and saves it. No Kafka call. |
| `OutboxRelay` | `@Scheduled` poller; claims a batch, publishes, marks published |
| `OutboxRepository.claimPending` | `FOR UPDATE SKIP LOCKED` so replicas never double-publish |

Details worth knowing:

- **`source_service` column** rather than per-service table names. All four services
  share one schema today, so each relay must poll only its own rows. After the
  schema-per-service split the column is redundant but harmless — and the table name
  never has to change.
- **The relay re-parses the stored JSON to a `JsonNode` before sending.** Sending the
  raw `String` through the configured `JsonSerializer` would publish a double-encoded
  JSON string that consumers could not read as an event.
- **A failed publish leaves `published_at` null**, so the next tick retries it.
  `attempts` and `last_error` are recorded for diagnosis.
- **Delivery is at-least-once by construction** — if the broker acknowledges but the
  relay transaction then fails, the event is sent again. Hence the inbox below.

Tunables: `automarket.outbox.poll-interval-ms` (1000), `batch-size` (100),
`send-timeout-seconds` (10), `initial-delay-ms` (10000).

### 9.2 Consumer inbox / deduplication (#new — implemented)

`processed_event` keyed on (`event_id`, `consumer_group`), with `InboxGuard` exposing
`alreadyProcessed` / `markProcessed`. Neither method declares `@Transactional` on
purpose: both must join the consumer's transaction, so that if the handler rolls back,
the marker rolls back with it and the event is retried.

**Known limitation:** notification-service has no database and stays stateless by
design, so it cannot dedupe. A redelivered event there means a duplicate email. That is
an accepted trade-off, not an oversight — giving notification-service persistence to
avoid occasional duplicate mail is a poor exchange.

### 9.3 Subscription consumer (#31 — fixed)

`SubscriptionEventConsumer` in auth-service, consumer group `auth-service`, closes the
loop that left paying customers on FREE:

```
Stripe webhook -> subscriptions row + outbox row  (one transaction)
               -> OutboxRelay publishes subscription.activated
               -> auth-service consumes, sets users.plan = PREMIUM,
                  records user.plan-changed to its own outbox   (one transaction)
               -> listing-service stops applying the free-tier cap
```

The handler is `@Transactional`, so the plan change, the inbox marker and the outgoing
`user.plan-changed` event commit together. Two deliberate non-throwing paths: an
unknown event type and an unknown user id both return normally rather than burning the
retry budget and dead-lettering a record that no retry could fix.

It already emits `user.plan-changed` even though nothing consumes that yet — it is what
listing-service's projection will read in Phase 3, and emitting it now costs nothing.

### 9.4 Analytics (#44 — fixed)

All four compounding defects addressed:

| Defect | Fix |
|---|---|
| `@Async` inert (no `@EnableAsync` anywhere) | `AsyncConfig` with `@EnableAsync` and a **bounded** pool — the Spring default `SimpleAsyncTaskExecutor` is unbounded and this runs on every page view |
| Joined the caller's `readOnly` transaction, so writes emitted no SQL | `Propagation.REQUIRES_NEW`, so it can never inherit read-only even if the async proxy is removed |
| Called from inside a `@Cacheable` method, so cache hits skipped it | `recordView` moved to `ListingController`, outside the cached path |
| Read-modify-write lost updates under concurrency | Single atomic `INSERT … ON CONFLICT (listing_id, date) DO UPDATE SET view_count = view_count + 1` |

The `try/catch` around it is kept deliberately: view telemetry must never fail a page
load. That is different from the notification consumer, where swallowing meant losing a
user-visible email.

Saturation policy is `CallerRunsPolicy` — under a queue-full spike the request thread
records the view itself, applying backpressure rather than discarding the measurement.

### 9.5 Migrations added

| Service | Migration |
|---|---|
| auth-service | `V2__outbox_and_inbox.sql` |
| inquiry-service | `V2__outbox_and_inbox.sql` |
| payment-service | `V2__outbox_and_inbox.sql` |
| listing-service | `V3__outbox_and_inbox.sql` (V2 is the reference seed) |

All use `CREATE TABLE IF NOT EXISTS`, so the four services creating the same shared
table is idempotent — consistent with the existing baselines.

### 9.6 Note on entity scanning

`MessagingConfiguration` declares `@EntityScan("com.automarket")` and
`@EnableJpaRepositories("com.automarket")`. The outbox and inbox packages sit outside
each service's own base package, so Boot's default scanning (rooted at the
`@SpringBootApplication` class) would miss them. The scan is widened rather than
narrowed deliberately: declaring `@EntityScan` **replaces** the default root, so naming
only the messaging package would have hidden each service's own entities.

### 9.7 What Phase 2 did not change

- Cross-service table reads are untouched — that is Phase 3.
- `ListingEvent.Approved` still carries `sellerEmail` sourced from auth's `users` table.
  The outbox makes publication reliable; it does not make the payload independent.
- notification-service remains stateless and therefore non-deduplicating.

---

## 10. Phase 3 — Breaking the coupling (implemented 2026-09-17)

**Steps 5–7 complete. Step 8 (the schema split) is deliberately held for a separate
release — see §10.6, which is a correctness argument, not caution.**

### 10.1 Result

Every service now reads only tables it owns. Before this phase there were six
cross-context table mappings; there are none.

| Consumer | Was reading | Now reads | Fed by |
|---|---|---|---|
| listing-service | `users` (auth) | `listing_user_view` | `user-events` |
| blog-service | `users` (auth) | `blog_author_view` | `user-events` |
| inquiry-service | `users` (auth) | `inquiry_user_view` | `user-events` |
| payment-service | `users` (auth) | `payment_user_view` | `user-events` |
| inquiry-service | `listings` (listing) | `inquiry_listing_view` | `listing-events` |
| auth-service | `cities` (listing) | `auth_city_view` | seeded copy (§10.4) |

`Listing.seller` is still a JPA `@ManyToOne`, but it now points at
`listing_user_view` — a table listing-service owns. An association to your own read
model is ordinary CQRS; the problem was never the association, it was that the target
belonged to another service.

### 10.2 The event contracts had to change first

This is the dependency §8.1 identified, and it drove the order of work.

`ListingEvent.Approved` carries `sellerEmail`, so listing-service had to read auth's
`users` table to publish it. **That read is now served by listing-service's own
projection.** The event payload is unchanged — notification-service still receives the
seller's email and stays stateless with no database — but the producer no longer
reaches into another service's schema to populate it. That is the "fat events,
producer-side projection" decision working as intended.

`UserEvent.Registered` and a new `UserEvent.Updated` now carry the full projectable
snapshot (email, name, phone, cityName, plan, createdAt) rather than just an id.
`ListingEvent` gained `Updated` and `Deleted`, and `Created` was enriched — previously
it was a constant with no publisher at all (old finding #37, now resolved).

`UserService.updateProfile` publishes `user.updated`; without it, every projection
would keep the name, phone and city captured at registration.

`auth-service` consumes `listing.created/updated/approved/rejected/deleted` into
`auth_listing_view`, purely to count a seller's active listings for the public
profile. It is the narrowest projection in the system — seller id and approval state,
nothing else — because everything else about a listing belongs to listing-service.

### 10.3 Projections need no dedup table

All the projection consumers are blind upserts of a snapshot, so applying the same
event twice produces the same row. `InboxGuard` is therefore used only by
`SubscriptionEventConsumer`, which has a side effect beyond its own state: it publishes
a downstream `user.plan-changed`.

Deletes are **soft** everywhere. `Listing.seller` associates onto
`listing_user_view`, so removing a row would break every listing that user posted; and
inquiries outlive the listing they were sent about.

### 10.4 auth-service and cities — a deliberate exception

`auth_city_view` is seeded by migration and has **no consumer and no event stream**.
Cities are static reference data: nothing in the system can mutate them
(`AdminReferenceController` exposes car brands only). Building an event pipeline for
data that never changes would be ceremony.

If cities ever become editable, listing-service should publish `reference.city.*` and
auth-service should consume them — the same pattern already used for users. That is
recorded here so the shortcut is a decision rather than an omission.

### 10.5 ⚠️ New failure mode: the eventual-consistency window

**This is the real cost of the change and it is worth stating plainly.**

Projections are populated asynchronously — outbox poll (≤1s) plus Kafka plus consumer
lag, so roughly 1–2 seconds. During that window a user exists in auth-service but not
yet in the other services' read models.

Concretely: a user registers and *immediately* creates a listing.
`ListingService.getUserByEmail` queries `listing_user_view`, finds nothing, and throws
`ResourceNotFoundException("User", email)`. Before this phase that read hit `users`
directly and was always consistent. The same applies to `BlogService.create`.

In practice the user must log in between registering and posting, which takes far
longer than the window. But it is a genuine new failure mode, not a theoretical one.

Options, cheapest first:
1. **Accept and document** — the window is short and the interleaving is unlikely.
2. **Retry at the edge** — a bounded retry on the "user not found in projection" path.
3. **Read-your-writes on registration** — have auth-service return only after the
   projections acknowledge, which reintroduces synchronous coupling and is the wrong
   trade.

Nothing is implemented for this yet; option 1 is the current state.

### 10.6 Why the schema split is a separate release

Not caution — the per-service migrations genuinely cannot do it in one step.

The backfills written this phase read the shared schema:

```sql
INSERT INTO listing_user_view (...)
SELECT u.id, u.email, ... FROM users u LEFT JOIN cities c ON c.id = u.city_id;
```

Services start **concurrently with no ordering**. If auth-service's split migration ran
`ALTER TABLE users SET SCHEMA auth` before blog-service had run its backfill,
blog-service's migration would fail on a missing table — and which one wins is a race.

The correct sequence is two releases:

1. **This release** — projections and backfills, shared schema. Deploy, then verify
   every projection table is populated and the consumers are keeping up.
2. **Next release** — `ALTER TABLE … SET SCHEMA` per owner, plus
   `spring.jpa.properties.hibernate.default_schema` and `spring.flyway.schemas` /
   `default-schema` per service. By then no migration reads another service's tables,
   so the race is gone.

Deliberately **no migration files were written for step 8** — Flyway would pick them up
on the next boot and run them in the same release as the backfills, which is the exact
failure above.

**Before starting release 2, verify:**
- `SELECT count(*) FROM listing_user_view` matches `users`, and likewise for the other
  four projections
- `SELECT count(*) FROM outbox WHERE published_at IS NULL` stays near zero
- Consumer lag is stable on all five groups (Kafka UI, `localhost:8090`)
- Registering a new user propagates to every projection

### 10.7 Also removed

- **`/internal/**` controllers deleted** — `InternalUserController`,
  `InternalBlogController`, `InternalListingController`, plus the
  `.requestMatchers("/internal/**").permitAll()` rule in all five `SecurityConfig`s.
  They had no clients and were an unauthenticated user-enumeration surface, so this
  also closes half of finding #33.
- **listing-service's `CityView` / `CityViewRepository`** — dead once `UserView`
  stopped associating to it.

### 10.8 Migrations added

| Service | Migration |
|---|---|
| auth-service | `V3__city_projection.sql` |
| blog-service | `V2__author_projection.sql` |
| inquiry-service | `V3__user_projection.sql`, `V4__listing_projection.sql` |
| listing-service | `V4__user_projection.sql` |
| payment-service | `V3__user_projection.sql` |

blog-service also gained `spring-kafka` and `automarket-events` — it previously had no
messaging at all.
