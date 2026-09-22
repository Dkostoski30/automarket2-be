# AutoMarket — DevOps Setup

## 1. Project Overview

AutoMarket is a car marketplace platform built with a microservice architecture:

- **Frontend**: Angular 19 served via Nginx
- **Backend**: 6 Spring Boot microservices behind a Spring Cloud Gateway
- **Database**: PostgreSQL 16 — one shared database, each service owning its own tables
- **Cache**: Redis 7 — caching and gateway rate-limiter buckets
- **Message Broker**: Kafka 3.7, single-node KRaft (no ZooKeeper)
- **Mail**: MailHog (development SMTP)

### Architecture Diagram

```
                    ┌────────────────────────┐
                    │     Nginx (Frontend)   │ :80
                    └──────────┬─────────────┘
                               │ /api/, /uploads/
                    ┌──────────▼─────────────┐
                    │   Spring Cloud Gateway │ :8080
                    └──────────┬─────────────┘
          ┌────────┬───────────┴───┬─────────┬──────────────┐
          ▼        ▼               ▼         ▼              ▼
      auth     listing          blog     inquiry        payment      notification
      :8081    :8082            :8083     :8084          :8086          :8087
          │        │               │         │              │              │
          └────────┴───────────┬───┴─────────┴──────────────┘              │
                               ▼                                           ▼
                    ┌───────────────────┐                      ┌─────────────────┐
                    │   PostgreSQL      │                      │     Kafka       │
                    │   Redis           │                      │    MailHog      │
                    └───────────────────┘                      └─────────────────┘
```

The gateway is the only component that validates a JWT. It resolves the token into
`X-User-*` headers and signs the request with `GATEWAY_SHARED_SECRET`, which
`GatewayAuthFilter` verifies in each service before trusting those headers.

`notification-service` has no database — it is a pure Kafka consumer that sends mail.
Reference data was merged into `listing-service`; there is no `reference-service`.

## 2. Public Git Repository

The project is hosted on a public GitHub repository. The backend (all 8 microservices + gateway) is in a single monorepo with a multi-module Maven structure:

```
automarket2-BE/
├── pom.xml                          # Parent POM
├── automarket-common/               # Shared DTOs, exceptions
├── automarket-security-common/      # Gateway auth filter
├── automarket-storage/              # File storage abstraction (local / S3)
├── automarket-events/               # Kafka event payloads, topic names
├── automarket-messaging/            # Transactional outbox
├── gateway/                         # Spring Cloud Gateway (:8080)
├── auth-service/                    # Authentication & users (:8081)
├── listing-service/                 # Car listings + reference data (:8082)
├── blog-service/                    # Blog posts (:8083)
├── inquiry-service/                 # Buyer-seller inquiries (:8084)
├── payment-service/                 # Stripe subscriptions (:8086)
├── notification-service/            # Event-driven email (:8087)
├── docker-compose.yml
├── .env
└── k8s/                            # Kubernetes manifests
```

The frontend is in a separate repository (`automarket2-FE/`).

## 3. Dockerization

Each microservice has its own `Dockerfile` using a multi-stage build. All seven follow
the same pattern:

```dockerfile
# ── Stage 1: Build ───────────────────────────────────────────────
FROM maven:3.9-eclipse-temurin-21-alpine AS build
WORKDIR /app
COPY .. .
RUN --mount=type=cache,target=/root/.m2,sharing=locked \
    mvn package -pl <module> -am -DskipTests -B && \
    java -Djarmode=layertools -jar <module>/target/*.jar \
      extract --destination <module>/target/extracted

# ── Stage 2: Runtime ─────────────────────────────────────────────
FROM eclipse-temurin:21-jre-alpine AS runtime
WORKDIR /app
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser
COPY --from=build /app/<module>/target/extracted/dependencies/ ./
COPY --from=build /app/<module>/target/extracted/spring-boot-loader/ ./
COPY --from=build /app/<module>/target/extracted/snapshot-dependencies/ ./
COPY --from=build /app/<module>/target/extracted/application/ ./
EXPOSE <port>
HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=3 \
  CMD wget -qO- http://localhost:<port>/actuator/health || exit 1
ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", \
  "-XX:+UseSerialGC", "-Xss256k", \
  "org.springframework.boot.loader.launch.JarLauncher"]
```

Three decisions worth stating:

- **The whole reactor is copied in one `COPY . .`**, not module-by-module. Listing
  module paths individually meant every new Maven module silently broke the build.
  `.dockerignore` keeps the context small and the `/root/.m2` cache mount is what
  actually keeps dependency downloads off the critical path.
- **The build context is the repository root**, so images must be built from there:
  `docker build -f auth-service/Dockerfile -t ... .`
- **`layertools` extraction** puts dependencies in their own image layer, so a code-only
  change re-pushes kilobytes rather than the whole fat jar. The container runs as a
  non-root user and the `HEALTHCHECK` is what Compose's `depends_on: service_healthy`
  gates on.

The frontend (separate repository) uses an Nginx-based Dockerfile:

```dockerfile
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci --prefer-offline
COPY . .
RUN npm run build:prod

FROM nginx:1.25-alpine AS runtime
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist/automarket-frontend/browser /usr/share/nginx/html
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD wget -qO- http://localhost/health || exit 1
```

`nginx.conf` serves the SPA with an `index.html` fallback, exposes `/health` for the
probe, and sets long cache headers on hashed static assets.

> **Known wrinkle:** `nginx.conf` proxies `/api/` to `http://backend:8080`, but no service
> is named `backend` — in Kubernetes it is `gateway`. This is currently harmless because
> the Ingress routes `/api` and `/uploads` straight to the gateway and never lets those
> paths reach Nginx. It would bite if the frontend container were ever used standalone.

## 4. Docker Compose Orchestration

All services and infrastructure are orchestrated via `docker-compose.yml`:

```yaml
services:
  # Infrastructure
  postgres:        # PostgreSQL 16 — port 5433:5432, healthcheck with pg_isready
  redis:           # Redis 7 — port 6379, healthcheck with redis-cli ping
  kafka:           # Kafka 3.7 KRaft — 9092 (host) / 19092 (in-network)
  kafka-ui:        # Topic + consumer-lag browser → localhost:8090
  mailhog:         # MailHog — ports 1025 (SMTP) + 8025 (Web UI)
  prometheus:      # profile: monitoring → localhost:9090
  grafana:         # profile: monitoring → localhost:3000 (admin/admin)

  # Application services (all use .env for configuration)
  auth-service:          # Port 8081, depends on postgres + redis + kafka
  listing-service:       # Port 8082, mounts uploads volume
  blog-service:          # Port 8083, mounts uploads volume
  inquiry-service:       # Port 8084
  payment-service:       # Port 8086
  notification-service:  # Port 8087, no DB — Kafka consumer only
  gateway:               # Port 8080, waits for all five domain services to be healthy

volumes:
  postgres_data:   # Persistent database storage
  kafka_data:      # Kafka log directories
  uploads_data:    # Shared volume for listing/blog file uploads
  prometheus_data:
  grafana_data:
```

Kafka advertises **two listeners**: `INTERNAL` (`kafka:19092`) for other Compose
services, and `EXTERNAL` (`localhost:9092`) so a service started from the IDE can still
reach the broker. That is why `.env` and `.env.example` carry different values for
`KAFKA_BOOTSTRAP_SERVERS`.

The **frontend is not part of Compose** — it runs via `ng serve` during development and
is containerized only for the Kubernetes deployment.

### Running Locally

```bash
docker compose up --build -d
docker compose logs -f gateway      # starts last, once the services report healthy
```

Then, from the frontend repository, `npm install && npm start`.

- Frontend: `http://localhost:4200` (`ng serve`, talks directly to the gateway)
- API: `http://localhost:8080/api/v1/reference/car-brands`
- Swagger (all services aggregated): `http://localhost:8080/swagger-ui.html`
- Kafka UI: `http://localhost:8090`
- MailHog UI: `http://localhost:8025`
- PostgreSQL: `localhost:5433` (5432 inside the network)

Monitoring is opt-in via a Compose profile:

```bash
docker compose --profile monitoring up -d   # Prometheus :9090, Grafana :3000
```

### Running services from the IDE

Every service declares `spring.config.import: "optional:file:.env[.properties]"`, so an
IDE run picks up the same `.env` — whose hostnames (`postgres`, `redis`, `kafka:19092`,
`mailhog`) do not resolve from the host. The `application.yml` defaults are already
correct for localhost; `.env` is what breaks the run. Start infrastructure only
(`docker compose up -d postgres redis kafka mailhog`) and either point `.env` at host
values or override `DB_URL` / `KAFKA_BOOTSTRAP_SERVERS` / `REDIS_HOST` / `MAIL_HOST` per
run. Remember the database is on **5433** from the host.

## 5. CI Pipeline (GitHub Actions)

### Backend CI (`.github/workflows/ci.yml`)

Triggers on push to `master` or `feature/devops-setup`, **and on pull requests to
`master`**. Doc-only changes are skipped via `paths-ignore`.

Two jobs, in sequence:

**1. `verify` — compile and test**

```yaml
- uses: actions/setup-java@v4
  with:
    java-version: '21'
    distribution: temurin
    cache: maven
- run: ./mvnw -B --no-transfer-progress verify
```

This is the quality gate. The image builds pass `-DskipTests`, so without this job
no test source is ever compiled, let alone run. The tests use Testcontainers, which
needs a Docker daemon — `ubuntu-latest` provides one.

`./mvnw` is the committed Maven wrapper (`only-script` distribution, so there is no
jar in the repo), pinning Maven 3.9.9 for local, CI and image builds alike.

**2. `images` — build every service image**

Runs only if `verify` passed. Builds all seven Dockerfiles with `--output
type=cacheonly`: the images are **not pushed anywhere**, because nothing consumes a
registry copy — see below. The job exists to prove the Dockerfiles are valid, which
they had stopped being.

It is deliberately **one job rather than a matrix**. Each Dockerfile mounts a
`/root/.m2` BuildKit cache that is shared across builds on the same builder, so only
the first image pays for dependency resolution. A matrix gives every service its own
builder and re-downloads everything seven times.

### Deployment model: local build, no registry

There is no CD stage, and that is now explicit rather than accidental. Every
manifest sets `imagePullPolicy: Never`, and `k8s/deploy.sh` builds the images
locally and loads them with `k3d image import`. A registry push was previously part
of CI but no deployment ever pulled from it, so the `:<commit-sha>` tags — the only
thing that would make a deploy reproducible — were written and never read.

Consequences worth stating plainly:

- Deploying requires a local Docker daemon and the repo. There is no "promote this
  build" step.
- `:latest` is whatever was last built on that machine.
- Argo CD was removed (commit `fcd9b6d`); `k8s/argocd/` is left for reference.

Moving to registry-based deploys later means: push on CI, tag the manifests with the
sha, and switch `imagePullPolicy` to `IfNotPresent`.

The `verify` job also uploads Surefire XML reports as an artifact, so a failure can be
read without re-running the build locally.

### Frontend CI

The frontend repository currently has **no CI workflow** — there is no `.github/`
directory in it. Its image is built only by `k8s/deploy.sh`, from local sources.

Adding one means: `npm ci`, `npm run build:prod`, and a `docker build`. There is no
reason to push it to a registry until the backend does the same (see below).

### Required GitHub Secrets

**None.** The backend workflow pushes nothing, and there is no frontend workflow.

## 6. Kubernetes Manifests

All manifests are in `k8s/` and deploy to the `automarket` namespace.

### Directory Structure

```
k8s/
├── namespace.yml                          # Namespace: automarket
├── configmap.yml                          # Shared app config (DB_URL, REDIS_HOST, etc.)
├── secret.yml                             # Sensitive data (DB_PASSWORD, JWT_SECRET, etc.)
├── infrastructure/
│   ├── postgres-configmap.yml             # POSTGRES_DB, POSTGRES_USER
│   ├── postgres-statefulset.yml           # StatefulSet with 1Gi PVC
│   ├── postgres-service.yml               # Headless service (clusterIP: None)
│   ├── redis-deployment.yml
│   ├── redis-service.yml
│   ├── kafka-statefulset.yml               # Single-node KRaft broker
│   ├── kafka-service.yml
│   ├── mailhog-deployment.yml
│   ├── mailhog-service.yml
│   ├── prometheus-configmap.yml            # Scrape config for Spring Boot services
│   ├── prometheus-rules-configmap.yml      # Alerting rules
│   ├── prometheus-deployment.yml
│   ├── prometheus-service.yml
│   ├── grafana-datasources.yml             # Auto-provision Prometheus datasource
│   ├── grafana-dashboards-configmap.yml
│   ├── grafana-deployment.yml
│   └── grafana-service.yml
├── services/
│   ├── uploads-pvc.yml                    # Shared PVC for listing uploads
│   ├── blog-uploads-pvc.yml               # Separate PVC for blog uploads
│   ├── frontend-deployment.yml
│   ├── frontend-service.yml
│   ├── gateway-deployment.yml
│   ├── gateway-service.yml
│   ├── auth-service-deployment.yml
│   ├── auth-service-service.yml
│   ├── listing-service-deployment.yml
│   ├── listing-service-service.yml
│   ├── blog-service-deployment.yml
│   ├── blog-service-service.yml
│   ├── inquiry-service-deployment.yml
│   ├── inquiry-service-service.yml
│   ├── payment-service-deployment.yml
│   ├── payment-service-service.yml
│   ├── notification-service-deployment.yml
│   └── notification-service-service.yml
├── ingress.yml                            # Nginx Ingress for automarket.local
├── autoscaling.yml                        # HPAs + PodDisruptionBudgets
├── networkpolicy.yml                      # Opt-in traffic restrictions
├── deploy.sh                              # Deployment script
└── argocd/                                # Unused — kept for reference only
    ├── install.yml
    └── application.yml
```

`secret.yml` is gitignored. Copy `secret.yml.example` to `secret.yml` and fill in
`DB_PASSWORD`, `JWT_SECRET`, `GATEWAY_SHARED_SECRET`, the Stripe keys, and
`RESEND_API_KEY` (only needed if `MAIL_PROVIDER` is switched to `resend`).

### 6.1 ConfigMap & Secret

**ConfigMap** (`automarket-config`) holds all non-sensitive configuration:
- Database URL and username
- Redis host/port
- `KAFKA_BOOTSTRAP_SERVERS` — the StatefulSet pod DNS name,
  `kafka-0.kafka.automarket.svc.cluster.local:9092`
- Mail server settings (`MAIL_PROVIDER: smtp` → MailHog)
- Storage configuration (`STORAGE_PROVIDER: local`, uploads at `/app/uploads`)
- `FRONTEND_URL: http://automarket.local` — also the gateway's allowed CORS origin
- Inter-service URLs (e.g., `AUTH_SERVICE_URL=http://auth-service:8081`)

**Secret** (`automarket-secret`) holds sensitive values using `stringData`:
- `DB_PASSWORD`
- `JWT_SECRET`
- `GATEWAY_SHARED_SECRET` — without this the `X-User-*` headers are self-asserted and
  any pod that can reach a service port could claim `ROLE_ADMIN`
- `RESEND_API_KEY`
- `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`

Every Deployment pulls both in wholesale via `envFrom`, so adding a variable means
editing one ConfigMap rather than eight manifests.

### 6.2 PostgreSQL StatefulSet

PostgreSQL uses a **StatefulSet** (not a Deployment) for stable storage:

- Image: `postgres:16-alpine`
- Config from `postgres-config` ConfigMap (`POSTGRES_DB`, `POSTGRES_USER`)
- Password from `automarket-secret`
- `volumeClaimTemplates`: 1Gi `ReadWriteOnce` persistent volume
- **Headless Service** (`clusterIP: None`) for stable DNS (`postgres.automarket.svc.cluster.local`)
- Health probes: `pg_isready -U automarket -d automarket`

### 6.3 Application Deployments & Services

All 8 application services (7 BE + 1 FE) follow this pattern:

| Service | Image | Port | Extra |
|---------|-------|------|-------|
| frontend | automarket/automarket-frontend | 80 | Probe on `/health`; 32Mi/10m requests |
| gateway | automarket/automarket-gateway | 8080 | Explicit service URL env vars |
| auth-service | automarket/automarket-auth-service | 8081 | — |
| listing-service | automarket/automarket-listing-service | 8082 | Mounts uploads PVC |
| blog-service | automarket/automarket-blog-service | 8083 | Mounts blog-uploads PVC |
| inquiry-service | automarket/automarket-inquiry-service | 8084 | — |
| payment-service | automarket/automarket-payment-service | 8086 | — |
| notification-service | automarket/automarket-notification-service | 8087 | No DB |

Each backend Deployment:
- 1 replica baseline, scaled by an HPA (§6.5)
- `imagePullPolicy: Never` — images are built locally and k3d-imported, never pulled
- `envFrom` referencing both `automarket-config` (ConfigMap) and `automarket-secret` (Secret)
- Resources: requests 256Mi/100m, limits 512Mi/500m

**Three probes, not two.** A JVM with Flyway migrations can take well over a minute to
come up, and a liveness probe with a generous `initialDelaySeconds` is a bad way to cover
that — it either fires too early during a slow start or reacts too slowly to a genuine
hang afterwards.

- `startupProbe`: `/actuator/health`, `failureThreshold: 30` × `periodSeconds: 10` —
  up to five minutes to boot. Liveness does not run until it passes.
- `readinessProbe`: `/actuator/health` every 10s — gates traffic.
- `livenessProbe`: `/actuator/health`, 15s period, 3 failures — restarts a wedged pod.

**Graceful shutdown** is wired end to end: each service sets
`server.shutdown: graceful` and `spring.lifecycle.timeout-per-shutdown-phase: 30s`, and
each pod sets `terminationGracePeriodSeconds: 45` so the JVM finishes in-flight requests
before SIGKILL. The rolling update strategy is `maxUnavailable: 0, maxSurge: 1`, because
at one replica the default (25% → 1) leaves a gap with no pod serving.

### 6.4 Ingress

Uses the Nginx Ingress controller, installed by `deploy.sh` (k3d's bundled Traefik is
disabled at cluster creation so the two do not fight over ports 80/443):

```yaml
spec:
  ingressClassName: nginx
  rules:
    - host: automarket.local
      http:
        paths:
          - path: /api       → gateway:8080
          - path: /uploads   → gateway:8080
          - path: /           → frontend:80
```

Annotation `proxy-body-size: 50m` for file uploads.

Note that `/api` and `/uploads` are routed to the gateway by the Ingress itself, so they
never reach the frontend's Nginx. Only `/` does.

### 6.5 Autoscaling and Disruption Budgets

`k8s/autoscaling.yml` adds an HPA and a PodDisruptionBudget per workload. Before it,
every workload sat at `replicas: 1` with neither, so any node drain or rolling update
was a full outage for that service and load could not be absorbed at all.

**HPAs** scale 1→3 on CPU at 75% utilization. CPU is a weak signal for services that are
I/O bound on Postgres and Kafka, but it is the only one available without a custom
metrics adapter. Scale-down uses a 300s stabilization window against a 60s scale-up
window: a JVM needs ~30s to warm up, so flapping costs more than holding a spare pod for
five minutes. HPAs need metrics-server, which k3s ships by default.

**PDBs** use `maxUnavailable: 1` rather than `minAvailable: 1`, deliberately. At one
replica a `minAvailable` of 1 blocks every voluntary eviction, so the node can never be
drained. `maxUnavailable: 1` does permit losing the only pod, but once the HPA has scaled
out it guarantees they are not all taken at once — the case that actually matters during
a cluster upgrade.

### 6.6 Network Policies (opt-in)

`k8s/networkpolicy.yml` restricts backend services to traffic from the gateway and
Prometheus. It is **off by default**:

```bash
APPLY_NETWORK_POLICIES=1 bash k8s/deploy.sh
```

NetworkPolicy enforcement depends on the CNI, and if the kubelet's probes get caught by
a policy every pod fails readiness at once — a confusing way to lose a demo. Turn it on
deliberately and confirm pods stay ready. The shared-secret check in `GatewayAuthFilter`
is the actual authorization control; this is defence in depth on top of it.

### 6.7 Deployment Script

`k8s/deploy.sh` automates the full deployment using **k3d** (k3s-in-Docker):

1. Creates a k3d cluster with ports 80/443 mapped to localhost, Traefik disabled
2. Rewrites `host.docker.internal` to `127.0.0.1` in the kubeconfig — on Windows that
   name often does not resolve, and without the fix every `kubectl` call fails
3. Installs the nginx ingress controller
4. Builds the seven backend images plus the frontend, then `k3d image import`s them.
   The frontend repo is located at `$HOME/WebstormProjects/automarket2-FE`, overridable
   with `FE_DIR`; if it is missing, the frontend build is skipped with a warning
5. Applies manifests in order: namespace → config/secrets → infrastructure → waits for
   postgres/redis/kafka readiness → application services → ingress → autoscaling
6. Optionally applies network policies (§6.6)
7. Prints hosts-file instructions and the monitoring port-forward commands

It is idempotent: re-running against an existing cluster reuses it and re-applies.

### 6.8 Monitoring (Prometheus + Grafana)

Prometheus scrapes metrics from all Spring Boot services via their `/actuator/prometheus` endpoint. Grafana provides dashboards with Prometheus as a pre-configured datasource.

**Prometheus** (`prom/prometheus:v2.53.0`):
- ConfigMap `prometheus-config` scrapes all seven backend services (auth, listing, blog,
  inquiry, payment, notification, gateway) every 10 seconds
- `prometheus-rules-configmap.yml` supplies alerting rules, mounted at
  `/etc/prometheus/rules/`
- 7-day data retention
- Accessible inside the cluster at `prometheus:9090`

**Alerting rules** cover the failure modes this architecture actually has:

| Alert | Condition |
|---|---|
| `OutboxRelayStalled` | `automarket_outbox_oldest_pending_seconds > 120` |
| `OutboxBacklogGrowing` | `automarket_outbox_pending > 500` |
| `DeadLetteredRecords` | any increase in `automarket_dlt_records_total` over 10m |
| `KafkaConsumerLagGrowing` | `kafka_consumer_fetch_manager_records_lag_max > 1000` |
| `ServiceDown` | `up == 0` |
| `HighServerErrorRate` | sustained 5xx rate |

The first three are the ones worth watching: a stalled outbox relay means writes are
committing to Postgres but the corresponding events never reach Kafka, which is silent
until someone notices a projection is stale.

**Grafana** (`grafana/grafana:11.1.0`):
- Auto-provisions Prometheus as default datasource via `grafana-datasources` ConfigMap
- Dashboards provisioned from `grafana-dashboards-configmap.yml`
- Default credentials: `admin` / `admin`
- Accessible inside the cluster at `grafana:3000`

**Accessing the UIs:**
```bash
# Prometheus
kubectl -n automarket port-forward svc/prometheus 9090:9090
# Open http://localhost:9090

# Grafana
kubectl -n automarket port-forward svc/grafana 3000:3000
# Open http://localhost:3000 (admin/admin)
```

The services already carry `micrometer-registry-prometheus` and expose `prometheus` via
`management.endpoints.web.exposure.include`, so no extra configuration is needed.

## 7. Deploying with k3d

**Prerequisites:** Docker Desktop and [k3d](https://k3d.io/) installed, and
`k8s/secret.yml` created from `secret.yml.example`.

```bash
# Run the deployment script (first run builds 8 images — allow 10+ minutes)
bash k8s/deploy.sh

# Add to hosts file
# On Windows: add to C:\Windows\System32\drivers\etc\hosts
# 127.0.0.1 automarket.local

# Verify everything is running
kubectl -n automarket get pods
kubectl -n automarket get svc
kubectl -n automarket get ingress

# Access the application
# Frontend: http://automarket.local
# API:      http://automarket.local/api/v1/reference/car-brands

# Monitoring (run in separate terminals)
kubectl -n automarket port-forward svc/prometheus 9090:9090
kubectl -n automarket port-forward svc/grafana 3000:3000

# Cleanup when done
k3d cluster delete automarket
```

### Expected Output

```
NAME                                    READY   STATUS    RESTARTS
postgres-0                              1/1     Running   0
redis-xxxxx                             1/1     Running   0
kafka-0                                 1/1     Running   0
mailhog-xxxxx                           1/1     Running   0
auth-service-xxxxx                      1/1     Running   0
listing-service-xxxxx                   1/1     Running   0
blog-service-xxxxx                      1/1     Running   0
inquiry-service-xxxxx                   1/1     Running   0
payment-service-xxxxx                   1/1     Running   0
notification-service-xxxxx              1/1     Running   0
gateway-xxxxx                           1/1     Running   0
frontend-xxxxx                          1/1     Running   0
prometheus-xxxxx                        1/1     Running   0
grafana-xxxxx                           1/1     Running   0
```
