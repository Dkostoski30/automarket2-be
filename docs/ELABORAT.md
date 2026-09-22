# AutoMarket — Микросервисна REST API платформа за продажба на автомобили

**GitHub репозиториум:** https://github.com/Dkostoski30/automarket2-be/tree/feature/devops-setup

---

## 1. Опис на апликацијата

AutoMarket е REST API платформа за онлајн продажба и купување на автомобили, изградена со **Spring Boot 3.2.3** и **Java 21**. Апликацијата е реализирана како **микросервисна архитектура** составена од 7 независни сервиси, API Gateway, и 4 инфраструктурни компоненти. Системот поддржува CRUD операции за огласи, корисници, блог објави, пораки меѓу купувач и продавач, Stripe плаќања, и известувања преку email.

Како база на податоци се користи **PostgreSQL 16** со JPA/Hibernate ORM за пристап до податоците. Конфигурацијата е екстернализирана преку **ConfigMap** и **Secret** ресурси во Kubernetes, а environment variables се користат за сите сервиси. За мониторинг се користи **Prometheus** и **Grafana**, а за асинхрона комуникација меѓу сервисите **RabbitMQ**.

### Технологии

| Категорија | Технологија |
|---|---|
| Јазик / Framework | Java 21, Spring Boot 3.2.3 |
| API Gateway | Spring Cloud Gateway |
| База на податоци | PostgreSQL 16 Alpine |
| Кеширање | Redis 7 Alpine |
| Асинхрони настани | RabbitMQ 3 (AMQP) |
| Email (dev) | MailHog |
| Мониторинг | Prometheus + Grafana |
| Контејнеризација | Docker, Docker Compose |
| Оркестрација | Kubernetes (k3d) |
| CI/CD | GitHub Actions |
| Плаќања | Stripe API |

---

## 2. Архитектура на системот

Системот се состои од следниве компоненти:

```
                                    ┌─────────────────┐
                                    │   Frontend (FE)  │
                                    │   Angular :4200  │
                                    └────────┬────────┘
                                             │
                                    ┌────────▼────────┐
                              ┌─────│  NGINX Ingress   │─────┐
                              │     │ automarket.local  │     │
                              │     └────────┬────────┘     │
                              │              │              │
                         /api, /uploads      │           /  │
                              │              │              │
                     ┌────────▼────────┐     │    ┌────────▼────────┐
                     │   API Gateway    │     │    │    Frontend     │
                     │   :8080         │     │    │    :80 (nginx)  │
                     │  JWT валидација  │     │    └─────────────────┘
                     │  CORS, рутирање │     │
                     └──┬──┬──┬──┬──┬──┘
                        │  │  │  │  │
           ┌────────────┘  │  │  │  └────────────┐
           │        ┌──────┘  │  └──────┐        │
           ▼        ▼         ▼         ▼        ▼
     ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
     │  Auth    │ │ Listing  │ │  Blog    │ │ Inquiry  │ │ Payment  │
     │ Service  │ │ Service  │ │ Service  │ │ Service  │ │ Service  │
     │  :8081   │ │  :8082   │ │  :8083   │ │  :8084   │ │  :8086   │
     └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘
          │            │            │            │            │
          └─────┬──────┴──────┬─────┴──────┬─────┴──────┬─────┘
                │             │            │            │
          ┌─────▼─────┐ ┌────▼─────┐ ┌────▼─────┐ ┌───▼────────────┐
          │ PostgreSQL │ │  Redis   │ │ RabbitMQ │ │  Notification  │
          │   :5432    │ │  :6379   │ │  :5672   │ │   Service      │
          └────────────┘ └──────────┘ └──────────┘ │    :8087       │
                                                   └───────┬────────┘
                                                           │
                                                    ┌──────▼──────┐
                                                    │   MailHog   │
                                                    │ SMTP :1025  │
                                                    │ UI   :8025  │
                                                    └─────────────┘
```

### Мулти-модулна структура (Maven)

```
automarket-platform (parent POM)
├── automarket-common/           — Споделени DTO, исклучоци, PageResponse
├── automarket-security-common/  — GatewayAuthFilter за downstream сервиси
├── automarket-storage/          — Апстракција за складирање слики (local/S3)
├── automarket-events/           — RabbitMQ конфигурација и event DTO-а
├── gateway/                     — Spring Cloud Gateway, порт 8080
├── auth-service/                — Корисници, улоги, JWT автентикација, порт 8081
├── listing-service/             — Огласи, слики, омилени, аналитика, референтни податоци, порт 8082
├── blog-service/                — Блог објави, порт 8083
├── inquiry-service/             — Пораки купувач-продавач, порт 8084
├── payment-service/             — Stripe претплати, порт 8086
└── notification-service/        — Event-driven email известувања, порт 8087
```

---

## 3. API Gateway и рутирање

API Gateway-от (Spring Cloud Gateway) е единствената влезна точка за сите клиентски барања. Тој ги извршува следните функции:

- **JWT валидација** — го парсира JWT токенот и ги инјектира `X-User-Email`, `X-User-Id`, `X-User-Roles` хедерите кон downstream сервисите
- **CORS** — централизирана конфигурација за cross-origin барања
- **Рутирање** — го препраќа секое барање кон соодветниот микросервис

### Табела на рути

| Патека | Метод | Целен сервис | Опис |
|---|---|---|---|
| `/api/v1/auth/**` | * | auth-service:8081 | Регистрација, најава, refresh, logout |
| `/api/v1/users/**` | * | auth-service:8081 | Кориснички профили |
| `/api/v1/admin/users/**` | * | auth-service:8081 | Админ управување со корисници |
| `/api/v1/listings/**` | * | listing-service:8082 | Огласи, слики, омилени, аналитика |
| `/api/v1/favorites/**` | * | listing-service:8082 | Листа на омилени огласи |
| `/api/v1/moderation/**` | * | listing-service:8082 | Модерација на огласи |
| `/api/v1/admin/dashboard/**` | * | listing-service:8082 | Админ статистики |
| `/api/v1/reference/**` | * | listing-service:8082 | Референтни податоци (марки, горива...) |
| `/api/v1/admin/reference/**` | * | listing-service:8082 | Админ управување со референтни податоци |
| `/api/v1/blog/**` | * | blog-service:8083 | Блог објави |
| `/api/v1/inquiries/**` | * | inquiry-service:8084 | Пораки меѓу купувач и продавач |
| `/api/v1/subscriptions/**` | * | payment-service:8086 | Stripe претплати |
| `/api/v1/webhooks/**` | * | payment-service:8086 | Stripe webhook |
| `/uploads/**` | GET | listing-service:8082 | Статички слики |

### Безбедносен тек (Security Flow)

```
┌────────┐     JWT токен     ┌─────────────┐  X-User-Email   ┌──────────────┐
│ Клиент │ ───────────────► │  Gateway     │ ──────────────► │  Downstream  │
│  (FE)  │                  │  :8080       │  X-User-Id      │   Сервис     │
└────────┘                  │              │  X-User-Roles   │              │
                            │ JwtValidation│                 │ GatewayAuth  │
                            │    Filter    │                 │   Filter     │
                            └──────────────┘                 └──────────────┘
```

1. Клиентот испраќа JWT токен во `Authorization: Bearer <token>` хедерот
2. Gateway-от го валидира токенот (HMAC-SHA256) и ги извлекува email, userId и roles
3. Ги инјектира како доверливи хедери (`X-User-Email`, `X-User-Id`, `X-User-Roles`)
4. Downstream сервисите преку `GatewayAuthFilter` ги читаат хедерите и го пополнуваат `SecurityContext`
5. Контролерите пристапуваат до автентицираниот корисник преку `@AuthenticationPrincipal String email`

---

## 4. REST API Endpoints

### 4.1 Auth Service (порт 8081)

| Метод | Патека | Опис |
|---|---|---|
| POST | `/api/v1/auth/register` | Регистрација на нов корисник |
| POST | `/api/v1/auth/login` | Најава и добивање JWT токени |
| POST | `/api/v1/auth/refresh` | Обновување на access token |
| POST | `/api/v1/auth/logout` | Одјава и поништување на refresh токени |
| GET | `/api/v1/users/{id}` | Јавен профил на корисник |
| GET | `/api/v1/users/me` | Профил на тековниот корисник |
| PUT | `/api/v1/users/me` | Ажурирање на профил |
| PUT | `/api/v1/users/me/password` | Промена на лозинка |
| GET | `/api/v1/admin/users` | Листа на сите корисници (пагинирана) |
| PUT | `/api/v1/admin/users/{id}/roles` | Промена на улоги на корисник |
| DELETE | `/api/v1/admin/users/{id}` | Мека бришење на корисник |
| GET | `/internal/users/{id}` | Интерен — корисник по ID |
| GET | `/internal/users/by-email/{email}` | Интерен — корисник по email |

### 4.2 Listing Service (порт 8082)

| Метод | Патека | Опис |
|---|---|---|
| GET | `/api/v1/listings` | Пребарување огласи со филтри (јавно) |
| GET | `/api/v1/listings/{id}` | Детали за оглас по ID |
| GET | `/api/v1/listings/slug/{slug}` | Детали за оглас по SEO slug |
| GET | `/api/v1/listings/featured` | Истакнати огласи |
| GET | `/api/v1/listings/my` | Огласи на тековниот корисник |
| POST | `/api/v1/listings` | Креирање нов оглас |
| PUT | `/api/v1/listings/{id}` | Ажурирање на оглас |
| DELETE | `/api/v1/listings/{id}` | Бришење на оглас |
| POST | `/api/v1/listings/{id}/images` | Прикачување слики (multipart, макс. 10) |
| DELETE | `/api/v1/listings/{listingId}/images/{imageId}` | Бришење на слика |
| POST/DELETE | `/api/v1/listings/{id}/favorite` | Додавање/отстранување од омилени |
| GET | `/api/v1/listings/{id}/analytics` | Аналитика за оглас |
| GET | `/api/v1/favorites` | Сите омилени огласи на корисникот |
| GET | `/api/v1/admin/dashboard` | Админ статистики |
| GET | `/api/v1/reference/{type}` | Референтни податоци (car-brands, fuel-types, body-types, condition-types, transmission-types, cities) |
| POST/DELETE | `/api/v1/admin/reference/car-brands` | CRUD за марки (админ) |
| GET | `/api/v1/moderation/listings` | Огласи за одобрување |
| POST | `/api/v1/moderation/listings/{id}/approve\|reject` | Одобрување/одбивање |

### 4.3 Blog Service (порт 8083)

| Метод | Патека | Опис |
|---|---|---|
| GET | `/api/v1/blog` | Листа блог објави (пагинирана, јавно) |
| GET | `/api/v1/blog/{id}` или `/slug/{slug}` | Блог објава по ID или slug |
| POST | `/api/v1/blog` | Креирање блог објава (модератор/админ) |
| PUT | `/api/v1/blog/{id}` | Ажурирање блог објава |
| DELETE | `/api/v1/blog/{id}` | Бришење блог објава (админ) |
| POST | `/api/v1/blog/{id}/cover-image` | Прикачување насловна слика |
| POST | `/api/v1/blog/images` | Прикачување inline слика |

### 4.4 Inquiry Service (порт 8084)

| Метод | Патека | Опис |
|---|---|---|
| POST | `/api/v1/inquiries` | Започнување разговор со продавач од оглас |
| GET | `/api/v1/conversations` | Разговори на корисникот (пагинирано) |
| GET | `/api/v1/conversations/unread-count` | Број непрочитани пораки |
| GET | `/api/v1/conversations/{id}` | Еден разговор со пораките (пагинирано) |
| POST | `/api/v1/conversations/{id}/messages` | Одговор во разговор |
| POST | `/api/v1/conversations/{id}/read` | Означи го разговорот како прочитан |

### 4.5 Payment Service (порт 8086)

| Метод | Патека | Опис |
|---|---|---|
| GET | `/api/v1/subscriptions/plans` | Достапни планови за претплата |
| POST | `/api/v1/subscriptions/checkout` | Креирање Stripe checkout сесија |
| POST | `/api/v1/webhooks/stripe` | Прием на Stripe webhook настани |

### 4.6 Notification Service (порт 8087)

Нема REST контролери — работи event-driven преку RabbitMQ, испраќа email известувања преку SMTP (MailHog во dev).

---

## 5. База на податоци

**PostgreSQL 16 Alpine** — единствена инстанца, заедничка база `automarket`. JPA/Hibernate ORM, HikariCP pool (3-5 конекции по сервис).

| Табела | Сервис | Опис |
|---|---|---|
| `users`, `roles`, `user_roles`, `refresh_tokens` | auth-service | Корисници, улоги (USER/MODERATOR/ADMIN), JWT refresh |
| `listings`, `listing_images`, `favorites`, `listing_analytics` | listing-service | Огласи, слики, омилени, аналитика |
| `car_brands`, `fuel_types`, `body_types`, `condition_types`, `transmission_types`, `cities` | listing-service | Референтни податоци |
| `blogs` | blog-service | Блог објави |
| `inquiries` | inquiry-service | Пораки купувач-продавач |
| `subscriptions` | payment-service | Stripe претплати |

---

## 6. Event-Driven архитектура (RabbitMQ)

**Exchange:** `automarket.events` (topic, durable) | **Формат:** JSON

| Routing Key | Consumers |
|---|---|
| `user.registered` | notification-service → welcome email |
| `user.disabled` | listing-service → деактивира огласи |
| `user.deleted` | listing-service, inquiry-service, blog-service |
| `user.plan-changed` | listing-service → ажурира лимити |
| `listing.approved/rejected` | notification-service → email до продавач |
| `inquiry.sent` | notification-service → email до продавач |
| `subscription.activated/cancelled` | auth-service → ажурира план на корисник |

---

## 7. Dockerfile и Docker Compose

### Multi-stage Dockerfile

Секој микросервис има **multi-stage Dockerfile**:
- **Stage 1 (Build):** `maven:3.9-eclipse-temurin-21-alpine` — dependency caching (`--mount=type=cache`), компилација, Spring Boot layertools extract
- **Stage 2 (Runtime):** `eclipse-temurin:21-jre-alpine` — non-root корисник (`appuser`), layered COPY, `SerialGC` + `256k` stack, `HEALTHCHECK` со Actuator

### Docker Compose

| Сервис | Меморија | Зависности |
|---|---|---|
| postgres | 256 MB | - |
| redis | 48 MB | - |
| rabbitmq | 200 MB | - |
| mailhog | 32 MB | - |
| auth-service | 256 MB | postgres, redis, rabbitmq |
| listing-service | 300 MB | postgres, redis, rabbitmq |
| blog-service | 200 MB | postgres |
| inquiry-service | 210 MB | postgres, rabbitmq |
| payment-service | 220 MB | postgres, rabbitmq |
| notification-service | 160 MB | rabbitmq, mailhog |
| gateway | 220 MB | сите сервиси |
| prometheus + grafana | 96+96 MB | monitoring профил |

Сите сервиси користат `env_file: .env`, `healthcheck` + `depends_on: condition: service_healthy`. Мониторинг стекот се стартува со `docker compose --profile monitoring up`.

---

## 8. GitHub Actions — CI

**Workflow:** [.github/workflows/ci.yml](https://github.com/Dkostoski30/automarket2-be/blob/feature/devops-setup/.github/workflows/ci.yml)

При секој `push` на `master` или `feature/microservice-migration`:
1. **Matrix strategy** — билда сите 7 сервиси **паралелно** на `ubuntu-latest`
2. Најава на DockerHub (`secrets.DOCKERHUB_USERNAME/TOKEN`)
3. `docker/build-push-action@v6` — билдање и push
4. Два тага по image: `:latest` и `:<git-sha>` за traceability

---

## 9. Kubernetes

Оркестрација со **k3d** (K3s во Docker). Манифести во [`k8s/`](https://github.com/Dkostoski30/automarket2-be/tree/feature/devops-setup/k8s).

### Конфигурација

- **Namespace:** `automarket`
- **ConfigMap** (`automarket-config`): DB_URL, REDIS_HOST, RABBITMQ_HOST, сервисни URL-а, storage конфигурација
- **Secret** (`automarket-secret`): DB_PASSWORD, JWT_SECRET, RABBITMQ_PASSWORD, Stripe клучеви
- Сервисите читаат преку `envFrom: [configMapRef, secretRef]`

### Инфраструктура

| Компонента | Тип | Клучни детали |
|---|---|---|
| PostgreSQL 16 | StatefulSet | PVC 1Gi, shared_buffers=64MB, 128-256Mi RAM |
| Redis 7 | Deployment | maxmemory 32mb, allkeys-lru, 24-48Mi RAM |
| RabbitMQ 3 | Deployment | management plugin, 200-350Mi RAM |
| MailHog | Deployment | dev SMTP :1025, UI :8025 |
| Prometheus | Deployment | scrape на секои 10s, 7-дневна ретенција |
| Grafana | Deployment | auto-provisioned Prometheus datasource |

### Апликациски сервиси

Сите 7 микросервиси следат ист шаблон: `imagePullPolicy: Never` (k3d import), `envFrom` за конфигурација, три типа проби:
- **startupProbe** — макс. 5 мин. за JVM startup (30 × 10s)
- **readinessProbe** — подготвеност за сообраќај
- **livenessProbe** — рестартирање при неодговарање

**PVC:** `uploads-pvc` (1Gi) — споделен меѓу listing-service и blog-service за слики.

### Ingress

NGINX Ingress за `automarket.local`: `/api` и `/uploads` → Gateway :8080, `/` → Frontend :80.

### Deployment скрипта ([deploy.sh](https://github.com/Dkostoski30/automarket2-be/blob/feature/devops-setup/k8s/deploy.sh))

1. k3d cluster create (порт 80+443, без Traefik)
2. Docker build за сите сервиси + frontend
3. k3d image import
4. kubectl apply: namespace → configmap/secret → инфраструктура → сервиси → ingress
5. Верификација: `kubectl wait` + `kubectl get pods`

**Пристап:**
```
Frontend:    http://automarket.local
API:         http://automarket.local/api/v1/reference/car-brands
Prometheus:  kubectl port-forward svc/prometheus 9090:9090
Grafana:     kubectl port-forward svc/grafana 3000:3000  (admin/admin)
```

Потребно: `127.0.0.1 automarket.local` во `C:\Windows\System32\drivers\etc\hosts`

**Вкупно: 38+ Kubernetes ресурси** (1 Namespace, 4 ConfigMaps, 1 Secret, 1 StatefulSet, 12 Deployments, 15 Services, 2 PVCs, 1 Ingress)
