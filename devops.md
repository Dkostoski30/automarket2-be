# AutoMarket — DevOps Setup

## 1. Project Overview

AutoMarket is a car marketplace platform built with a microservice architecture:

- **Frontend**: Angular 19 served via Nginx
- **Backend**: 8 Spring Boot microservices behind a Spring Cloud Gateway
- **Database**: PostgreSQL 16
- **Cache**: Redis 7
- **Message Broker**: RabbitMQ 3
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
          ┌────────┬───────┬───┴────┬─────────┬──────────┬──────────┐
          ▼        ▼       ▼        ▼         ▼          ▼          ▼
      auth     listing   blog   inquiry  reference  payment  notification
      :8081    :8082     :8083   :8084    :8085      :8086    :8087
          │        │       │        │         │          │          │
          └────────┴───────┴────┬───┴─────────┴──────────┘          │
                                ▼                                   ▼
                    ┌───────────────────┐                ┌─────────────────┐
                    │   PostgreSQL      │                │    RabbitMQ     │
                    │   Redis           │                │    MailHog      │
                    └───────────────────┘                └─────────────────┘
```

## 2. Public Git Repository

The project is hosted on a public GitHub repository. The backend (all 8 microservices + gateway) is in a single monorepo with a multi-module Maven structure:

```
automarket2-BE/
├── pom.xml                          # Parent POM
├── automarket-common/               # Shared DTOs, exceptions
├── automarket-security-common/      # Gateway auth filter
├── automarket-storage/              # File storage abstraction
├── automarket-events/               # RabbitMQ event DTOs
├── gateway/                         # Spring Cloud Gateway (:8080)
├── auth-service/                    # Authentication & users (:8081)
├── listing-service/                 # Car listings (:8082)
├── blog-service/                    # Blog posts (:8083)
├── inquiry-service/                 # Buyer-seller inquiries (:8084)
├── reference-service/               # Lookup data (:8085)
├── payment-service/                 # Stripe subscriptions (:8086)
├── notification-service/            # Event-driven email (:8087)
├── docker-compose.yml
├── .env
└── k8s/                            # Kubernetes manifests
```

The frontend is in a separate repository (`automarket2-FE/`).

## 3. Dockerization

Each microservice has its own `Dockerfile` using a multi-stage build:

1. **Build stage**: Uses Maven to compile the service and its dependencies
2. **Runtime stage**: Uses a minimal JDK 21 image to run the resulting JAR

Example (all 8 services follow the same pattern):
```dockerfile
# Build stage
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
COPY <module>/pom.xml <module>/
COPY automarket-common/pom.xml automarket-common/
# ... copy sources and build ...
RUN mvn package -pl <module> -am -DskipTests

# Runtime stage
FROM eclipse-temurin:21-jre-alpine
COPY --from=build /app/<module>/target/*.jar app.jar
EXPOSE <port>
ENTRYPOINT ["java", "-jar", "app.jar"]
```

The frontend uses an Nginx-based Dockerfile:
```dockerfile
# Build stage
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json .
RUN npm ci
COPY . .
RUN npm run build --prod

# Runtime stage
FROM nginx:alpine
COPY --from=build /app/dist/automarket2/browser /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
```

Nginx proxies `/api/` requests to the gateway service.

## 4. Docker Compose Orchestration

All services and infrastructure are orchestrated via `docker-compose.yml`:

```yaml
services:
  # Infrastructure
  postgres:        # PostgreSQL 16 — port 5433:5432, healthcheck with pg_isready
  redis:           # Redis 7 — port 6379, healthcheck with redis-cli ping
  rabbitmq:        # RabbitMQ 3 — ports 5672 (AMQP) + 15672 (Management UI)
  mailhog:         # MailHog — ports 1025 (SMTP) + 8025 (Web UI)

  # Application services (all use .env for configuration)
  auth-service:          # Port 8081, depends on postgres + redis + rabbitmq
  listing-service:       # Port 8082, depends on postgres + redis + rabbitmq, mounts uploads volume
  blog-service:          # Port 8083, depends on postgres, mounts uploads volume
  inquiry-service:       # Port 8084, depends on postgres + rabbitmq
  reference-service:     # Port 8085, depends on postgres + redis
  payment-service:       # Port 8086, depends on postgres + rabbitmq
  notification-service:  # Port 8087, depends on rabbitmq + mailhog

  # Entry points
  gateway:         # Port 8080, routes to all backend services
  frontend:        # Port 80, depends on gateway

volumes:
  postgres_data:   # Persistent database storage
  uploads_data:    # Shared volume for listing/blog file uploads
```

### Running Locally

```bash
docker compose up --build
```

- Frontend: `http://localhost`
- API: `http://localhost/api/v1/references/brands`
- RabbitMQ UI: `http://localhost:15672` (automarket/secret)
- MailHog UI: `http://localhost:8025`

## 5. CI/CD Pipeline (GitHub Actions → DockerHub)

### Backend CI (`.github/workflows/ci.yml`)

Triggers on push to `master` or `feature/microservice-migration`.

Uses a **matrix strategy** to build all 8 services in parallel:

```yaml
strategy:
  matrix:
    service:
      - gateway
      - auth-service
      - listing-service
      - blog-service
      - inquiry-service
      - reference-service
      - payment-service
      - notification-service
```

Each job:
1. Checks out the code
2. Logs in to DockerHub (using repository secrets)
3. Builds and pushes the Docker image with two tags:
   - `automarket/automarket-<service>:latest`
   - `automarket/automarket-<service>:<commit-sha>`

### Frontend CI (`automarket2-FE/.github/workflows/ci.yml`)

Triggers on push to `main` or `master`. Single job that builds and pushes:
- `automarket/automarket-frontend:latest`
- `automarket/automarket-frontend:<commit-sha>`

### Required GitHub Secrets

Both repositories need these secrets configured:
- `DOCKERHUB_USERNAME` — DockerHub username
- `DOCKERHUB_TOKEN` — DockerHub access token

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
│   ├── rabbitmq-deployment.yml
│   ├── rabbitmq-service.yml
│   ├── mailhog-deployment.yml
│   ├── mailhog-service.yml
│   ├── prometheus-configmap.yml            # Scrape config for Spring Boot services
│   ├── prometheus-deployment.yml
│   ├── prometheus-service.yml
│   ├── grafana-datasources.yml             # Auto-provision Prometheus datasource
│   ├── grafana-deployment.yml
│   └── grafana-service.yml
├── services/
│   ├── uploads-pvc.yml                    # Shared PVC for file uploads
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
│   ├── reference-service-deployment.yml
│   ├── reference-service-service.yml
│   ├── payment-service-deployment.yml
│   ├── payment-service-service.yml
│   ├── notification-service-deployment.yml
│   └── notification-service-service.yml
├── ingress.yml                            # Nginx Ingress for automarket.local
├── deploy.sh                              # Deployment script
└── argocd/
    ├── install.yml                        # Argo CD namespace
    └── application.yml                    # Argo CD Application (GitOps)
```

### 6.1 ConfigMap & Secret

**ConfigMap** (`automarket-config`) holds all non-sensitive configuration:
- Database URL and username
- Redis host/port
- RabbitMQ host/port/username
- Mail server settings
- Storage configuration
- Inter-service URLs (e.g., `AUTH_SERVICE_URL=http://auth-service:8081`)

**Secret** (`automarket-secret`) holds sensitive values using `stringData`:
- `DB_PASSWORD`
- `JWT_SECRET`
- `RABBITMQ_PASSWORD`
- `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`

### 6.2 PostgreSQL StatefulSet

PostgreSQL uses a **StatefulSet** (not a Deployment) for stable storage:

- Image: `postgres:16-alpine`
- Config from `postgres-config` ConfigMap (`POSTGRES_DB`, `POSTGRES_USER`)
- Password from `automarket-secret`
- `volumeClaimTemplates`: 1Gi `ReadWriteOnce` persistent volume
- **Headless Service** (`clusterIP: None`) for stable DNS (`postgres.automarket.svc.cluster.local`)
- Health probes: `pg_isready -U automarket -d automarket`

### 6.3 Application Deployments & Services

All 9 application services (8 BE + 1 FE) follow this pattern:

| Service | Image | Port | Extra |
|---------|-------|------|-------|
| frontend | automarket/automarket-frontend | 80 | Probe on `/health` |
| gateway | automarket/automarket-gateway | 8080 | Explicit service URL env vars |
| auth-service | automarket/automarket-auth-service | 8081 | — |
| listing-service | automarket/automarket-listing-service | 8082 | Mounts uploads PVC |
| blog-service | automarket/automarket-blog-service | 8083 | Mounts uploads PVC |
| inquiry-service | automarket/automarket-inquiry-service | 8084 | — |
| reference-service | automarket/automarket-reference-service | 8085 | — |
| payment-service | automarket/automarket-payment-service | 8086 | — |
| notification-service | automarket/automarket-notification-service | 8087 | — |

Each backend Deployment:
- 1 replica
- `envFrom` referencing both `automarket-config` (ConfigMap) and `automarket-secret` (Secret)
- Readiness probe: `/actuator/health`, initialDelay 30s
- Liveness probe: `/actuator/health`, initialDelay 60s
- Resources: requests 256Mi/100m, limits 512Mi/500m

### 6.4 Ingress

Uses the Nginx Ingress controller (Minikube addon):

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

### 6.5 Argo CD (Continuous Deployment)

Argo CD provides GitOps-based continuous deployment. When manifests in the `k8s/` directory are updated in Git, Argo CD automatically syncs the changes to the cluster.

**How it works:**
1. The deploy script installs Argo CD on the Minikube cluster
2. An `Application` resource points to the `k8s/` directory in the GitHub repo
3. Argo CD watches for changes and auto-syncs with `prune` and `selfHeal` enabled

**Application manifest** (`k8s/argocd/application.yml`):
- Source: `https://github.com/Dkostoski30/automarket2-be.git` (branch: `feature/microservice-migration`, path: `k8s/`)
- Destination: `automarket` namespace on the local cluster
- Sync policy: automated with pruning and self-healing
- Excludes: `argocd/*` and `deploy.sh` (to avoid circular management)

**Accessing the Argo CD UI:**
```bash
kubectl port-forward svc/argocd-server -n argocd 9090:443
# Open https://localhost:9090
# Username: admin
# Password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### 6.6 Deployment Script

`k8s/deploy.sh` automates the full deployment using **k3d** (k3s-in-Docker):

1. Creates a k3d cluster with port 80/443 mapped to localhost
2. Installs the nginx ingress controller
3. Builds Docker images locally and imports them into the k3d cluster
4. Applies manifests in order: namespace → config/secrets → infrastructure → waits for infra readiness → application services → ingress
5. Installs Argo CD and creates the Application resource for GitOps
6. Prints hosts file instructions and Argo CD credentials

### 6.7 Monitoring (Prometheus + Grafana)

Prometheus scrapes metrics from all Spring Boot services via their `/actuator/prometheus` endpoint. Grafana provides dashboards with Prometheus as a pre-configured datasource.

**Prometheus** (`prom/prometheus:v2.53.0`):
- ConfigMap `prometheus-config` defines scrape targets for all 8 backend services
- Scrapes every 10 seconds from `/actuator/prometheus`
- 7-day data retention
- Accessible inside the cluster at `prometheus:9090`

**Grafana** (`grafana/grafana:11.1.0`):
- Auto-provisions Prometheus as default datasource via `grafana-datasources` ConfigMap
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

> **Note**: For the Spring Boot services to expose Prometheus metrics, they need the `micrometer-registry-prometheus` dependency and `management.endpoints.web.exposure.include=prometheus` in their configuration.

## 7. Deploying with k3d

**Prerequisites:** Docker Desktop and [k3d](https://k3d.io/) installed.

```bash
# Run the deployment script
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
rabbitmq-xxxxx                          1/1     Running   0
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
