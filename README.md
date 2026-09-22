# AutoMarket Backend

Car marketplace platform: six Spring Boot microservices behind a Spring Cloud Gateway,
communicating over Kafka. The Angular frontend lives in a separate repository
(`automarket2-FE`).

## Tech Stack

- **Java 21**, **Spring Boot 3.2.3**, **Spring Cloud 2023.0.1** (Gateway)
- **PostgreSQL 16** — one shared database, each service owning its own tables
- **Redis 7** — caching and gateway rate-limiter buckets
- **Kafka 3.7** (single-node KRaft, no ZooKeeper) — event bus
- **Flyway** — migrations, one history table per service
- **Spring Security + JWT** (JJWT 0.12.5) — validated at the gateway only
- **Stripe** (24.3.0), **AWS S3 SDK**, **MapStruct**, **Lombok**, **SpringDoc OpenAPI 2.3**

## Modules

| Module | Port | Owns |
|---|---|---|
| `gateway` | 8080 | Routing, JWT validation, CORS, rate limiting — the only entry point |
| `auth-service` | 8081 | Users, roles, refresh tokens, login/registration |
| `listing-service` | 8082 | Listings, images, favorites, analytics, moderation, reference data |
| `blog-service` | 8083 | Blog posts |
| `inquiry-service` | 8084 | Buyer–seller inquiries |
| `payment-service` | 8086 | Subscriptions, Stripe integration |
| `notification-service` | 8087 | Email on events. No database — pure Kafka consumer |

Five shared libraries back them: `automarket-common` (DTOs, exceptions),
`automarket-security-common` (`GatewayAuthFilter`), `automarket-storage` (local/S3
abstraction), `automarket-events` (event payloads, topic names), `automarket-messaging`
(transactional outbox).

There is no `reference-service` — reference data was merged into `listing-service`.

## Running Everything in Docker

The quickest path. `.env` is already written for this mode (it uses Docker-internal
hostnames: `postgres`, `redis`, `kafka:19092`, `mailhog`).

```bash
docker compose up --build -d     # first run builds 7 images — slow
docker compose logs -f gateway   # the gateway starts last, once services are healthy
```

Startup is gated on healthchecks, so expect a few minutes before the gateway answers.

Then start the frontend from its own repository:

```bash
cd ../automarket2-FE     # or wherever you cloned it
npm install              # first time only
npm start                # → http://localhost:4200
```

`src/environments/environment.ts` points at `http://localhost:8080/api/v1`, straight at
the gateway. The gateway allows CORS from `${FRONTEND_URL}` (`http://localhost:4200`), so
no dev-server proxy is needed.

Note that the frontend is **not** part of `docker-compose.yml` — it is containerized only
for the Kubernetes deployment.

### What is exposed

| URL | Service |
|---|---|
| http://localhost:4200 | Frontend (`ng serve`) |
| http://localhost:8080 | Gateway — the only API entry point |
| http://localhost:8080/swagger-ui.html | Aggregated Swagger; pick a service from the dropdown |
| http://localhost:8025 | MailHog inbox |
| http://localhost:8090 | Kafka UI |
| `localhost:5433` | PostgreSQL — **5433** on the host, 5432 inside the network |
| `localhost:9092` | Kafka — `kafka:19092` inside the network |

Monitoring is behind a Compose profile:

```bash
docker compose --profile monitoring up -d   # Prometheus :9090, Grafana :3000 (admin/admin)
```

A quick smoke test once the gateway is up:

```bash
curl http://localhost:8080/api/v1/reference/car-brands
```

## Running Services from the IDE

Infrastructure in Docker, services on the host:

```bash
docker compose up -d postgres redis kafka mailhog
```

**The `.env` trap:** every service declares
`spring.config.import: "optional:file:.env[.properties]"`, so an IDE run picks up the
same `.env` — with `postgres`, `redis`, `kafka:19092` and `mailhog` as hostnames, none of
which resolve from the host. The defaults baked into each `application.yml` are already
correct for localhost; it is `.env` that breaks the run.

Either point `.env` at host values while working this way:

```properties
DB_URL=jdbc:postgresql://localhost:5433/automarket
KAFKA_BOOTSTRAP_SERVERS=localhost:9092
REDIS_HOST=localhost
MAIL_HOST=localhost
```

…or override per run:

```bash
./mvnw spring-boot:run -pl auth-service \
  -Dspring-boot.run.jvmArguments="-DDB_URL=jdbc:postgresql://localhost:5433/automarket -DKAFKA_BOOTSTRAP_SERVERS=localhost:9092 -DREDIS_HOST=localhost -DMAIL_HOST=localhost"
```

Start the domain services first, the gateway last. Order among the services does not
matter: they share one `automarket` database but each keeps a private Flyway history
table (`flyway_history_auth`, `flyway_history_listing`, …), so migrations never collide.

## Configuration

Copy `.env.example` to `.env` and fill it in. The variables that matter most:

| Variable | Default | Description |
|---|---|---|
| `DB_URL` | `jdbc:postgresql://localhost:5432/automarket` | JDBC URL. Host access via Compose is port **5433** |
| `DB_USERNAME` / `DB_PASSWORD` | `automarket` / — | Database credentials |
| `REDIS_HOST` / `REDIS_PORT` | `localhost` / `6379` | Redis |
| `KAFKA_BOOTSTRAP_SERVERS` | `localhost:9092` | `kafka:19092` from inside Compose |
| `JWT_SECRET` | *(insecure default)* | ≥32 chars. Must match between gateway and auth-service |
| `GATEWAY_SHARED_SECRET` | `dev-insecure-gateway-secret` | Proves a request came through the gateway. Must be identical in the gateway **and all six services** |
| `FRONTEND_URL` | `http://localhost:4200` | Allowed CORS origin |
| `STORAGE_PROVIDER` | `local` | `local` or `s3` |
| `LOCAL_UPLOAD_DIR` | `./uploads` | Upload directory in local mode |
| `MAIL_PROVIDER` | `smtp` | `smtp` (MailHog) or `resend` (placeholder — logs only) |
| `MAIL_HOST` / `MAIL_PORT` | `localhost` / `1025` | SMTP target |
| `STRIPE_ENABLED` | `false` | Enables the Stripe integration |

`GATEWAY_SHARED_SECRET` is absent from the committed `.env`, so everything falls back to
the same development default and works locally. If you set it, set it **everywhere** — a
mismatch makes services reject gateway traffic with 401.

## Seed Data

`seed.sql` is not mounted anywhere. Load it by hand once the services have run their
migrations:

```bash
docker compose exec -T postgres psql -U automarket -d automarket < seed.sql
```

## Security Model

The gateway is the only component that validates a JWT. It resolves the token into
`X-User-*` headers and signs the request with `GATEWAY_SHARED_SECRET`;
`GatewayAuthFilter` in each service verifies that secret before trusting the headers.
Services are therefore never exposed directly — anything that can reach a service port
can assert any identity if the shared secret is known.

Rate limiting is applied at the gateway, backed by Redis: 20 req/s sustained (bursting to
40) keyed per authenticated user, falling back to client IP. `/api/v1/auth/**` gets a
tighter per-IP bucket so login cannot be used as a password oracle.

## Tests

```bash
./mvnw verify
```

Tests use Testcontainers, so a running Docker daemon is required.

## Building Images

Each service has its own Dockerfile that builds the whole Maven reactor and extracts
layers with `jarmode=layertools`. Build from the **repository root** — the build context
is the reactor, not the module directory:

```bash
docker build -f auth-service/Dockerfile -t automarket/automarket-auth-service:latest .
```

## Kubernetes

```bash
bash k8s/deploy.sh
```

Creates a k3d cluster, builds and imports every image (including the frontend, found at
`$HOME/WebstormProjects/automarket2-FE` or wherever `FE_DIR` points), and applies the
manifests. Add `127.0.0.1 automarket.local` to your hosts file, then open
http://automarket.local. Teardown: `k3d cluster delete automarket`.

See [devops.md](docs/devops.md) for the full DevOps setup: CI, manifests, autoscaling and
monitoring. [ARCHITECTURE.md](docs/ARCHITECTURE.md) covers service boundaries and event flows.
