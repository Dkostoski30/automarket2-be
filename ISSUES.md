# AutoMarket2 BE — Post-Migration Issues Report

Re-verified against the working tree on branch `feature/devops-setup` (2026-09-17).

> **Update 2026-09-17 — RabbitMQ was replaced with Kafka.** This changes three items below:
> - **#23** (RabbitMQ connection retry) is **superseded** — the Kafka producer uses
>   `acks=all`, `retries=5`, `enable.idempotence=true`.
> - **#27** (bound queues with no consumer growing forever) is **resolved by the model
>   change** — an unconsumed Kafka topic ages out under retention instead of filling the broker.
> - **#29** (notification failures silently dropped) is **fixed** — the consumer lets
>   exceptions propagate to a `DefaultErrorHandler` that retries 3× then dead-letters to
>   `<topic>-dlt`.
>
> See `ARCHITECTURE.md` §3 for the topic layout, keying and delivery semantics.

Every item from the original report was re-checked against the actual files rather
than carried forward. **14 of the original 17 were already fixed** in the working
tree; the rest are now fixed. Re-verification also surfaced **7 issues the original
report missed**, two of which prevent the stack from starting at all.

**Legend:** ✅ verified fixed · 🔧 fixed in this pass · ⚠️ open, needs a decision

---

## Original report — verified status

| # | Severity | Status | Evidence |
|---|----------|--------|----------|
| 1 | CRITICAL | ✅ | `JwtValidationFilter` returns 401 on both the missing-token (`:90-93`) and invalid-token (`:126-130`) paths. |
| 2 | CRITICAL | ✅ | `k8s/secret.yml` untracked and gitignored; `k8s/secret.yml.example` committed in its place. |
| 3 | CRITICAL | ✅ | `k8s/argocd/application.yml` → `targetRevision: master`. |
| 4 | HIGH | ✅ | `.github/workflows/ci.yml` triggers on `[master, feature/devops-setup]`. |
| 5 | HIGH | ✅ | Split into `listing-uploads-pvc` and `blog-uploads-pvc`; each deployment mounts its own. |
| 6 | HIGH | ✅ (code) ⚠️ (source) | Removed from the CI matrix and from `pom.xml` modules, **but the `reference-service/` directory is still in the repo** — see #22. |
| 7 | MEDIUM | ✅ | `InquiryService.mapWithBatchLookup()` batches both lookups into 2 `IN` queries. Dead N+1 helper removed in #24. |
| 8 | MEDIUM | ✅ | `BlogService.list()` batch-fetches authors into a `Map` before mapping. |
| 9 | MEDIUM | ✅ (partly) ⚠️ | `ddl-auto: validate` + Flyway enabled with a `V1__baseline.sql` per service. **The shared-schema half was not addressed, and the fix introduced a fatal bug** — see #18 and #26. |
| 10 | MEDIUM | ✅ | RabbitMQ is now a StatefulSet with a `volumeClaimTemplates` PVC at `/var/lib/rabbitmq`. |
| 11 | MEDIUM | ✅ | `/actuator/` removed from `PUBLIC_PREFIXES`; only `/actuator/health` is public (exact match, GET only). |
| 12 | MEDIUM | ✅ | All live services set `show-details: when-authorized`. (`reference-service` still has `always` — dead module, see #22.) |
| 13 | MEDIUM | ✅ | `cache-from`/`cache-to: type=gha` per matrix scope, plus `setup-buildx-action`. |
| 14 | LOW | ✅ | `initialDelaySeconds: 30` present on liveness probes. |
| 15 | LOW | ✅ | CPU limits (`500m`) present on service deployments. |
| 16 | LOW | 🔧 | **Was still open.** Fixed — see #23. |
| 17 | LOW | ✅ | `BlogService.update(id, request, callerEmail, isAdmin)` enforces authorship and bypasses for admins. |

One correction to the original report: it did not flag `GET /api/v1/users/{id}` being
public at the gateway. That one is fine — `UserProfileDto` exposes only id, name, city
and join date, with no email or phone. Intentional public seller profile.

---

## Fixed in this pass

---

### 18. 🔧 CRITICAL — All five services share one Flyway history table, so only the first one ever boots

**Files:** `{auth,blog,inquiry,listing,payment}-service/src/main/resources/application.yml`

The fix for issue #9 enabled Flyway on five services that all point at the **same
database and the same schema** (`DB_URL` defaults to one `automarket` DB everywhere),
each shipping its own `V1__baseline.sql`. None overrode `spring.flyway.table`, so all
five wrote to the default `flyway_schema_history`.

Startup on a fresh database:

1. Whichever service wins the race creates `flyway_schema_history` and records
   version `1`, description `baseline`, with *its* checksum.
2. Every other service resolves its own `V1__baseline.sql` — same version, same
   description, **different checksum**.
3. `validateOnMigrate` (on by default) throws
   `FlywayValidateException: Migration checksum mismatch for migration version 1`.
4. Those four services never start. In Kubernetes: permanent `CrashLoopBackOff`.

This is not self-healing. Unlike a startup-ordering race it fails identically on every
restart, forever.

**Fix applied** — each service gets its own history table, the supported way to run
several Flyway-managed modules against one schema:

```yaml
  flyway:
    enabled: true
    table: flyway_history_auth      # _blog, _inquiry, _listing, _payment
    baseline-on-migrate: true
    baseline-version: 0
```

Verified that each of the five baselines only `CREATE TABLE IF NOT EXISTS` its own
tables, so they stay idempotent and non-overlapping.

---

### 19. 🔧 HIGH — Reference data seed was lost when `reference-service` merged into `listing-service`

**File:** `listing-service/src/main/resources/db/migration/V2__seed_reference_data.sql` (new)

`listing-service`'s `V1__baseline.sql` creates `cities`, `car_brands`, `fuel_types`,
`body_types`, `condition_types` and `transmission_types` — and contains **zero INSERT
statements**. The seed lived in `reference-service/.../V2__seed_reference_data.sql`,
which never ran: that service has `flyway.enabled: false` and is no longer built.

On any fresh deployment every reference dropdown renders empty, and listings cannot be
created because `condition_type_id`, `fuel_type_id` and friends have no rows to
reference.

The old seed could not be copied verbatim. It used bare
`INSERT INTO cities (name) VALUES (...)`, but these tables declare
`id UUID PRIMARY KEY` **with no DEFAULT** (Hibernate assigns ids application-side), so
those inserts would fail on a NOT NULL violation. The new migration generates ids:

```sql
INSERT INTO cities (id, name)
SELECT gen_random_uuid(), name FROM (VALUES
    ('Skopje'), ('Bitola'), ...
) AS v(name)
ON CONFLICT (name) DO NOTHING;
```

`ON CONFLICT DO NOTHING` keeps it re-runnable and safe against a database already
seeded by the old monolith. `gen_random_uuid()` is built in from PostgreSQL 13.

---

### 20. 🔧 CRITICAL — `.env` with real credentials was committed to Git

**File:** `.env`

The original report caught `k8s/secret.yml` but missed that `.env` was still tracked.
It is listed in `.gitignore`, which does nothing for already-tracked files. It holds 26
keys including `DB_PASSWORD`, `JWT_SECRET`, `AWS_SECRET_ACCESS_KEY`,
`STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET` and `RABBITMQ_PASSWORD`.

**Fix applied:** `git rm --cached .env` (file kept on disk), plus a committed
`.env.example` documenting every key with empty values.

> ⚠️ **The values remain in Git history.** Untracking does not remove them. Rotate
> every credential in that file — the Stripe and AWS keys especially — and consider
> `git filter-repo` to purge the blob if this repo is or will become public.

---

### 21. 🔧 MEDIUM — Compiled build artifacts committed to Git

245 files under `*/target/` were tracked, including `.class` files and a
`target/classes/application.yml` that shadows the real config when opened by mistake.
`target/` was already in `.gitignore` but, as with `.env`, that has no effect on paths
already in the index.

**Fix applied:** `git rm -r --cached` on all twelve `*/target` directories (files kept
on disk). This is also why `git status` was previously unreadable.

---

### 22. ⚠️ HIGH — `reference-service/` is dead code still in the repo

57 tracked files. It is **not** in `pom.xml` modules, **not** in the CI matrix, has
**no** K8s manifests, and all `/api/v1/reference/**` gateway routes point at
`listing-service`. Its entities (`City`, `CarBrand`, `BodyType`, …) duplicate
`listing-service`'s, and its `application.yml` still carries the exact anti-patterns
the report flagged elsewhere: `ddl-auto: update`, `flyway.enabled: false`,
`show-details: always`.

Only `.idea/*.xml` still references it.

**Status:** deletion was attempted but blocked by the sandbox. Everything else is done;
the directory just needs removing:

```bash
git rm -r reference-service
```

Its only unique content — the reference seed data — was carried over in #19, so nothing
is lost, and it stays recoverable from Git history regardless.

---

### 23. 🔧 LOW — No RabbitMQ connection resilience *(original issue #16)*

Kubernetes applies no startup ordering, so services routinely boot before the broker is
accepting connections. No service configured a connection timeout or retry.

**Fix applied.** Publishers (`auth`, `inquiry`, `listing`, `payment`):

```yaml
    connection-timeout: 30000
    template:
      retry:
        enabled: true
        initial-interval: 1000ms
        max-attempts: 5
        max-interval: 10000ms
        multiplier: 2.0
```

The consumer (`notification-service`) additionally gets `missing-queues-fatal: false`
and listener-level retry, so a broker that is still starting up no longer kills the
listener container permanently.

---

### 24. 🔧 LOW — Dead N+1 method left behind in `InquiryService`

The single-argument `toDto(Inquiry)` that issue #7 identified was still present after
the batch-lookup fix — unreferenced but intact, a trap for the next caller. Removed.
All remaining call sites use the three-argument overload.

---

### 25. 🔧 TRIVIAL — Stale "monolith" comment in the gateway

`JwtValidationFilter:47` still described public routes as "forwarded to the
monolith/downstream service". Corrected.

---

## Open — architectural, needs your decision

---

### 26. ⚠️ HIGH — Services read each other's tables directly, and `ddl-auto: validate` makes that a boot-order race

This is the core piece of monolith coupling left in the design. Five services share one
schema and reach directly into tables they do not own, through `@Immutable` JPA views:

| Service | Owns | Reads from another service |
|---------|------|----------------------------|
| auth | `users`, `roles`, `user_roles`, `refresh_tokens` | `cities` (listing) |
| listing | `cities`, `car_brands`, `listings`, `favorites`, … | `users` (auth) |
| blog | `blogs` | `users` (auth) |
| inquiry | `inquiries` | `users` (auth), `listings` (listing) |
| payment | `subscriptions` | `users` (auth) |

Two consequences:

1. **Boot-order race.** `ddl-auto: validate` validates *every* mapped entity, foreign
   read-models included. `blog-service` starting before `auth-service` has migrated
   fails validation on a missing `users` table. Unlike #18 this *is* self-healing — the
   pod crash-loops until the owner catches up — but it makes every cold start noisy and
   slow, and it will read as an outage during an incident.
2. **No isolation.** Any service can read, and with a mistaken mapping write, any other
   service's data. There is no contract between them, so an owner renaming a column
   silently breaks consumers at runtime with nothing failing at build time.

The infrastructure to fix this **already exists and is unused for it**:
`automarket-events` defines a topic exchange plus
`UserEvent.REGISTERED/DISABLED/DELETED/PLAN_CHANGED` and per-service queues.

**Recommended direction** (the largest change here, so it is a decision rather than
something I applied): replace each `@Table(name = "users")` read-model with a
locally-owned projection table (`blog_author_view`, `inquiry_user_view`, …) created by
that service's own migration and kept current by a `@RabbitListener` on the user
events. Each service then owns every table it maps, `validate` becomes
order-independent, and per-service schemas
(`spring.jpa.properties.hibernate.default_schema`) become possible — the isolation the
original report asked for in #9.

Interim option if you want the noise gone sooner: set `ddl-auto: none` on the four
consumer services and let Flyway be the only schema authority. You lose drift detection
on owned tables, so I would not do this unless the projection work follows it.

---

### 27. ⚠️ MEDIUM — Two RabbitMQ queues are declared and bound but nothing consumes them

`automarket-events/RabbitConfig` declares and binds:

- `listing-service.user-events` ← `user.disabled`, `user.deleted`, `user.plan_changed`
- `auth-service.subscription-events` ← `subscription.activated`, `subscription.cancelled`

There is exactly **one** `@RabbitListener` in the entire repository
(`NotificationEventConsumer`, on `notification-service.events`). Both queues above
accumulate durable messages forever with no consumer. Against the broker's `350Mi`
memory limit and `1Gi` PVC this ends in a RabbitMQ outage, and it gets worse the longer
the system runs.

Two related problems in the same file:

- `QUEUE_INQUIRY_USER` and `QUEUE_BLOG_USER` are declared as constants but never turned
  into queues or bindings — leftovers from the migration plan.
- The class comment says "each service declares only the queues it consumes from", but
  `RabbitConfig` lives in the shared `automarket-events` module, so **every** service
  depending on it declares **all** queues and bindings. The stated design is not what
  the code does.

**Why I did not simply fix it:** the obvious mitigation — adding `x-message-ttl` or
`x-max-length` — would make every service fail at startup with `PRECONDITION_FAILED`
against an existing broker, because a durable queue's arguments cannot be changed in
place. Removing the `@Bean`s does not help either: the queues and bindings already exist
in the broker and keep filling.

Any real fix needs an operational step on the cluster. Pick one:

1. **Write the consumers** — the intended design, and what #26 needs anyway — then split
   `RabbitConfig` so each service declares only its own queues.
2. **Drop the queues** (`rabbitmqctl delete_queue`) and remove the bindings until there
   is a consumer.
3. **Recreate them bounded**, with a TTL and a dead-letter queue: delete first, then
   redeploy with the new arguments.

---

### 28. ⚠️ LOW — Seller profiles always report zero listings

`UserService.getPublicProfile()` returns `totalListings = 0` hardcoded, with
`// will be replaced with Feign call to listing-service`. The count lived in the
monolith and was never reconnected, so every public seller profile shows 0.

Fix alongside #26 — either a Feign call to `listing-service` or a counter maintained
from listing events. Do not add another direct cross-service table read.

---

### 29. ⚠️ LOW — `notification-service` silently discards failed events

`NotificationEventConsumer.handle()` wraps its whole body in
`catch (Exception e) { log.error(...) }` with the comment *"Do not rethrow — message is
acked to avoid poisoning the queue"*. Avoiding a poison-message loop is the right
instinct, but this form drops the event permanently: a mail-server blip loses the
notification with nothing but a log line.

With the listener retry added in #23, the safe shape is to let the exception propagate
and add a dead-letter queue, so exhausted messages are parked for inspection rather than
discarded. Needs the same broker-side queue work as #27.

---

## Summary

| # | Severity | Status | Area | Description |
|---|----------|--------|------|-------------|
| 18 | CRITICAL | 🔧 | Data / Flyway | Shared history table — only the first service ever boots |
| 20 | CRITICAL | 🔧 | Security | `.env` with live credentials tracked in Git (**rotate them**) |
| 19 | HIGH | 🔧 | Data | Reference seed data lost in the reference-service merge |
| 22 | HIGH | ⚠️ | Structure | `reference-service/` dead code still in repo — needs `git rm -r` |
| 26 | HIGH | ⚠️ | Architecture | Cross-service table reads + `validate` boot race |
| 21 | MEDIUM | 🔧 | Hygiene | 245 build artifacts tracked in Git |
| 27 | MEDIUM | ⚠️ | Messaging | Two bound queues with no consumer — unbounded growth |
| 23 | LOW | 🔧 | Resilience | RabbitMQ connection retry/timeout (was #16) |
| 24 | LOW | 🔧 | Cleanup | Dead N+1 `toDto` in `InquiryService` |
| 28 | LOW | ⚠️ | Logic | Seller profile `totalListings` hardcoded to 0 |
| 29 | LOW | ⚠️ | Messaging | Failed notification events silently dropped |
| 25 | TRIVIAL | 🔧 | Docs | Stale monolith comment in gateway |

**Verification note:** Maven is not on `PATH` in this environment, so nothing was
compiled. All seven touched `application.yml` files were parsed and their resulting
`flyway.*` and `rabbitmq.*` trees asserted programmatically; the Java edit removed one
unreferenced private method, and the remaining call sites and imports were checked by
inspection. Run a build before merging.
