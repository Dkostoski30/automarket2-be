# AutoMarket — Микросервисна REST API платформа за продажба на автомобили

**GitHub репозиториум:** https://github.com/Dkostoski30/automarket2-be/tree/feature/devops-setup

---

## 1. Опис на апликацијата

AutoMarket е REST API платформа за онлајн продажба и купување на автомобили, изградена со **Spring Boot 3.2.3** и **Java 21**. Апликацијата е реализирана како **микросервисна архитектура** составена од 6 независни бизнис сервиси, API Gateway, и инфраструктурни компоненти (PostgreSQL, Redis, Kafka, MinIO, MailHog). Системот поддржува CRUD операции за огласи, корисници, блог објави, разговори меѓу купувач и продавач, Stripe плаќања, и известувања преку email.

Како база на податоци се користи **PostgreSQL 16** со JPA/Hibernate ORM. Секој сервис поседува **своја PostgreSQL шема** во заедничка инстанца — со сопствена Flyway history табела и `search_path` ограничен само на неговата шема, така што ниту еден сервис не чита туѓи табели. Конфигурацијата е екстернализирана преку **ConfigMap** и **Secret** ресурси во Kubernetes. За мониторинг се користи **Prometheus** и **Grafana**, а за асинхрона комуникација меѓу сервисите **Apache Kafka**.

### Технологии

| Категорија | Технологија |
|---|---|
| Јазик / Framework | Java 21, Spring Boot 3.2.3 |
| API Gateway | Spring Cloud Gateway 2023.0.1 |
| База на податоци | PostgreSQL 16 Alpine (шема по сервис) |
| Миграции | Flyway (по една history табела за секој сервис) |
| Кеширање / Rate limiting | Redis 7 Alpine |
| Асинхрони настани | Apache Kafka 3.7 (KRaft, без ZooKeeper) |
| Складирање слики | MinIO (S3-компатибилен) / AWS S3 SDK |
| Автентикација | Spring Security + JWT (RS256, JJWT 0.12.5) |
| Email (dev) | MailHog |
| Мониторинг | Prometheus + Grafana |
| Документација | SpringDoc OpenAPI 2.3 (агрегиран Swagger UI) |
| Контејнеризација | Docker, Docker Compose |
| Оркестрација | Kubernetes (k3d) |
| GitOps | ArgoCD |
| CI/CD | GitHub Actions |
| Плаќања | Stripe API 24.3.0 |
| Frontend | Angular 19 (одделен репозиториум, Nginx) |

---

## 2. Архитектура на системот

Системот се состои од следниве компоненти:

```
                                    ┌─────────────────┐
                                    │   Frontend (FE) │
                                    │   Angular 19    │
                                    └────────┬────────┘
                                             │
                                    ┌────────▼────────┐
                              ┌─────│  NGINX Ingress  │─────┐
                              │     │automarket.local │     │
                              │     └────────┬────────┘     │
                              │              │              │
                         /api, /uploads      │           /  │
                              │              │              │
                     ┌────────▼────────┐     │    ┌────────▼────────┐
                     │   API Gateway   │     │    │    Frontend     │
                     │   :8080         │     │    │    :80 (nginx)  │
                     │  JWT валидација │     │    └─────────────────┘
                     │  CORS, рутирање │     │
                     │  Rate limiting  │     │
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
        ┌───────▼──────┐ ┌────▼─────┐ ┌───▼──────┐ ┌───▼────────────┐
        │  PostgreSQL  │ │  Redis   │ │  MinIO   │ │     Kafka      │
        │   :5432      │ │  :6379   │ │  :9000   │ │    :9092       │
        │ шема/сервис  │ │          │ │  слики   │ │ 4 topics + DLT │
        └──────────────┘ └──────────┘ └──────────┘ └───────┬────────┘
                                                           │
                                                  ┌────────▼───────┐
                                                  │  Notification  │
                                                  │    Service     │
                                                  │     :8087      │
                                                  │   (без база)   │
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
├── automarket-storage/          — Апстракција за складирање слики (local / S3-MinIO)
├── automarket-events/           — Kafka конфигурација, topic имена и event DTO-а
├── automarket-messaging/        — Transactional outbox + inbox (идемпотентност)
├── gateway/                     — Spring Cloud Gateway, порт 8080
├── auth-service/                — Корисници, улоги, JWT автентикација, порт 8081
├── listing-service/             — Огласи, слики, омилени, аналитика, референтни податоци, порт 8082
├── blog-service/                — Блог објави, порт 8083
├── inquiry-service/             — Разговори купувач-продавач, порт 8084
├── payment-service/             — Stripe претплати, порт 8086
└── notification-service/        — Event-driven email известувања, порт 8087
```

Не постои `reference-service` — референтните податоци се спојени во `listing-service`.

---

## 3. API Gateway и рутирање

API Gateway-от (Spring Cloud Gateway) е единствената влезна точка за сите клиентски барања. Тој ги извршува следните функции:

- **JWT валидација** — го валидира токенот со **RS256** (само јавен клуч) и ги инјектира `X-User-Email`, `X-User-Id`, `X-User-Roles` хедерите кон downstream сервисите
- **Потпис на барањето** — додава `X-Gateway-Auth` хедер, HMAC потпис со `GATEWAY_SHARED_SECRET`
- **CORS** — централизирана конфигурација за cross-origin барања
- **Rate limiting** — Redis-based `RequestRateLimiter` (replenishRate 20, burstCapacity 40)
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
| `/api/v1/inquiries/**` | * | inquiry-service:8084 | Започнување разговор од оглас |
| `/api/v1/conversations/**` | * | inquiry-service:8084 | Разговори и пораки |
| `/api/v1/subscriptions/**` | * | payment-service:8086 | Stripe претплати |
| `/api/v1/webhooks/**` | * | payment-service:8086 | Stripe webhook |
| `/uploads/**` | GET | listing-service:8082 | Статички слики |
| `/api-docs/{сервис}` | GET | сите сервиси | Агрегиран OpenAPI за Swagger UI |

### Безбедносен тек (Security Flow)

```
┌────────┐   JWT (RS256)   ┌─────────────┐  X-User-Email    ┌──────────────┐
│ Клиент │ ──────────────► │   Gateway   │ ───────────────► │  Downstream  │
│  (FE)  │                 │    :8080    │  X-User-Id       │    Сервис    │
└────────┘                 │             │  X-User-Roles    │              │
                           │JwtValidation│  X-Gateway-Auth  │ GatewayAuth  │
                           │   Filter    │  (HMAC потпис)   │    Filter    │
                           └─────────────┘                  └──────────────┘
```

1. Клиентот испраќа JWT токен во `Authorization: Bearer <token>` хедерот
2. Gateway-от го валидира токенот (**RS256**, асиметрично — потпишува само `auth-service` со приватниот клуч, а gateway-от верификува со јавниот) и ги извлекува email, userId и roles
3. Ги инјектира како хедери (`X-User-Email`, `X-User-Id`, `X-User-Roles`) и го потпишува барањето со `X-Gateway-Auth`
4. Downstream сервисите преку `GatewayAuthFilter` **прво го проверуваат потписот**, па дури потоа им веруваат на хедерите и пополнуваат `SecurityContext` — така директен повик кон сервис што го обиколува gateway-от е невозможен
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
| DELETE | `/api/v1/admin/users/{id}` | Меко бришење на корисник |
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
| POST | `/api/v1/moderation/listings/{id}/approve` и `/reject` | Одобрување/одбивање |

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

Нема REST контролери и **нема сопствена база** — работи чисто event-driven како Kafka consumer и испраќа email известувања преку SMTP (MailHog во dev, Resend во production).

---

## 5. База на податоци

**PostgreSQL 16 Alpine** — единствена инстанца, база `automarket`, но **шема по сервис**. Секој сервис има `search_path` и Hibernate `default_schema` поставени на својата шема, и сопствена Flyway history табела (`flyway_history_auth`, `flyway_history_listing`, …). JPA/Hibernate ORM, HikariCP pool (1–5 конекции по сервис).

| Шема | Сервис | Табели |
|---|---|---|
| `auth` | auth-service | `users`, `roles`, `user_roles`, `refresh_tokens` |
| `listing` | listing-service | `listings`, `listing_images`, `favorites`, `listing_analytics` + референтни: `car_brands`, `fuel_types`, `body_types`, `condition_types`, `transmission_types`, `cities` |
| `blog` | blog-service | `blogs` |
| `inquiry` | inquiry-service | `conversations`, `messages`, `inquiries` |
| `payment` | payment-service | `subscriptions` |

### Локални проекции (read models)

Бидејќи сервисите не смеат да читаат туѓи табели, секој сервис на кој му требаат надворешни податоци држи **локална проекција** што се полни од Kafka настани:

| Табела | Сервис | Проектира |
|---|---|---|
| `auth_city_view`, `auth_listing_view` | auth-service | градови и огласи од listing-service |
| `listing_user_view` | listing-service | корисници од auth-service |
| `blog_author_view` | blog-service | автори од auth-service |
| `inquiry_user_view`, `inquiry_listing_view` | inquiry-service | корисници и огласи |
| `payment_user_view` | payment-service | корисници |

### Outbox / Inbox

Секој сервис што објавува настани има и `outbox` и `processed_event` табели (модул `automarket-messaging`) — види поглавје 6.

---

## 6. Event-Driven архитектура (Apache Kafka)

**Kafka 3.7 во KRaft режим** (без ZooKeeper). Еден topic по агрегат, а конкретниот настан се носи во `eventType` полето на `EventEnvelope`-от. Пораките се клучирани по id на агрегатот, така што сите настани за еден ентитет паѓаат на иста партиција и редоследот е гарантиран.

### Topics

| Topic | Producer | Consumer групи |
|---|---|---|
| `automarket.user-events` | auth-service | listing-service, blog-service, inquiry-service, payment-service |
| `automarket.listing-events` | listing-service | auth-service, inquiry-service, notification-service |
| `automarket.inquiry-events` | inquiry-service | notification-service |
| `automarket.subscription-events` | payment-service | auth-service |

Секој topic има и `-dlt` (dead-letter) верзија; `DeadLetterMonitor` во notification-service ги следи сите четири.

### Настани и реакции

| Настан | Реакција |
|---|---|
| `user.registered` | listing-service, blog-service, inquiry-service, payment-service → полнат локална проекција на корисникот |
| `user.plan-changed` | listing-service → ажурира лимити за огласи |
| `user.deleted` | listing-service → чисти податоци на корисникот |
| `listing.created` | auth-service, inquiry-service → проекција на огласот |
| `listing.approved` / `listing.rejected` | notification-service → email до продавачот; auth-service, inquiry-service → ажурираат проекција |
| `listing.deleted` | inquiry-service → ја отстранува проекцијата |
| `inquiry.sent` | notification-service → email до продавачот |
| `inquiry.replied` | notification-service → email до примачот |
| `subscription.activated` / `subscription.cancelled` | auth-service → ажурира план на корисникот |

### Гаранции за доставување

- **Transactional outbox** (`OutboxRecorder` → `OutboxRelay`) — настанот се запишува во `outbox` табелата во **истата транзакција** како бизнис промената, а посебен relay го објавува на Kafka. Ако падне брокерот, настанот не се губи.
- **Inbox / идемпотентност** (`InboxGuard` + `processed_event`) — секој обработен event id се памети, така што повторна достава (at-least-once) не предизвикува дупло email или дупла промена.
- **Dead-letter topics** — пораки што повторено фрлаат грешка завршуваат во `-dlt` topic наместо да блокираат партицијата.
- **Метрики** (`OutboxMetrics`) — изложени на Prometheus (заостанување на outbox, објавени/неуспешни настани).

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
| db-schema-split (еднократен job) | - | postgres |
| redis | 48 MB | - |
| kafka | 1 GB | - |
| minio (+ `minio-init` job) | 512 MB | - |
| mailhog | 32 MB | - |
| kafka-ui | 256 MB | kafka |
| auth-service | 256 MB | postgres, db-schema-split, redis, kafka |
| listing-service | 300 MB | postgres, redis, kafka, minio |
| blog-service | 200 MB | postgres, kafka, minio |
| inquiry-service | 210 MB | postgres, kafka |
| payment-service | 220 MB | postgres, kafka |
| notification-service | 160 MB | kafka, mailhog |
| gateway | 220 MB | сите сервиси |
| prometheus + grafana | 96+96 MB | monitoring профил |

Сите сервиси користат `env_file: .env`, `healthcheck` + `depends_on: condition: service_healthy`. Job-овите (`db-schema-split`, `minio-init`, `uploads-migrate`) се чекаат со `condition: service_completed_successfully`. Мониторинг стекот се стартува со `docker compose --profile monitoring up`.

**Изложени портови:** Gateway :8080, Swagger UI :8080/swagger-ui.html, MailHog UI :8025, Kafka UI :8090, MinIO конзола :9001, PostgreSQL :5433 (на хост), Prometheus :9090, Grafana :3000.

---

## 8. GitHub Actions — CI

**Workflow:** [.github/workflows/ci.yml](https://github.com/Dkostoski30/automarket2-be/blob/feature/devops-setup/.github/workflows/ci.yml)

При секој `push` на `master` или `feature/devops-setup` и при секој pull request кон `master`:
1. `actions/checkout@v4`
2. **JDK 21** (Temurin) со Maven dependency кеширање
3. `./mvnw -B package -DskipTests` — компилација на сите 12 модули
4. `concurrency` група со `cancel-in-progress` — нов push го откажува претходниот run
5. `paths-ignore` за `**/*.md` и `*.pdf` — промена во документација не троши CI минути

**Моментална состојба:** pipeline-от е **build-only**. Извршувањето на тестовите и билдањето/push-ањето на Docker images кон registry е привремено исклучено додека тест-сетовите не се стабилизираат, така што CI паѓа само кога кодот навистина не се компилира. Images моментално се градат локално и се внесуваат во k3d кластерот преку `k3d image import` (`imagePullPolicy: Never`).

---

## 9. Kubernetes

Оркестрација со **k3d** (K3s во Docker). Манифести во [`k8s/`](https://github.com/Dkostoski30/automarket2-be/tree/feature/devops-setup/k8s).

### Конфигурација

- **Namespace:** `automarket`
- **ConfigMap** (`automarket-config`): `DB_URL`, `REDIS_HOST`, `KAFKA_BOOTSTRAP_SERVERS`, `JWT_PUBLIC_KEY`, `STORAGE_PROVIDER=s3`, `CDN_URL`, сервисни URL-а, mail конфигурација
- **Secret** (`automarket-secret`): `DB_PASSWORD`, `JWT_PRIVATE_KEY`, `GATEWAY_SHARED_SECRET`, Stripe клучеви, `RESEND_API_KEY`; одделен `automarket-storage-secret` за MinIO креденцијали
- Сервисите читаат преку `envFrom: [configMapRef, secretRef]`

### Инфраструктура

| Компонента | Тип | Клучни детали |
|---|---|---|
| PostgreSQL 16 | StatefulSet | PVC 1Gi, shared_buffers=64MB, 128-256Mi RAM |
| Kafka 3.7 | StatefulSet | KRaft (combined controller+broker), headless service |
| MinIO | StatefulSet | PVC 2Gi, API :9000 / конзола :9001, init Job за bucket |
| Redis 7 | Deployment | maxmemory 32mb, allkeys-lru, 24-48Mi RAM |
| MailHog | Deployment | dev SMTP :1025, UI :8025 |
| Prometheus | Deployment | scrape на секои 10s, alerting rules преку ConfigMap |
| Grafana | Deployment | auto-provisioned datasource + dashboards |

### Апликациски сервиси

Сите 7 pod-а (6 сервиси + gateway) плус frontend следат ист шаблон: `imagePullPolicy: Never` (k3d import), `envFrom` за конфигурација, три типа проби:
- **startupProbe** — макс. 5 мин. за JVM startup (30 × 10s)
- **readinessProbe** — подготвеност за сообраќај
- **livenessProbe** — рестартирање при неодговарање

### Отпорност и скалирање

- **HorizontalPodAutoscaler** — 8 HPA ресурси, `minReplicas: 1`, `maxReplicas: 3`, праг 75% CPU
- **PodDisruptionBudget** — 8 PDB ресурси, задржуваат достапност при drain на node
- **NetworkPolicy** — 6 политики; default-deny со explicit allow само за дозволените патеки (пр. само gateway смее кон сервисите, само сервисите кон PostgreSQL)

### Складирање на слики

Сликите веќе **не** се држат на споделен PVC — преминато е на **MinIO** (S3-компатибилен), преку `automarket-storage` апстракцијата, така што `local` ↔ `s3` е само промена на `STORAGE_PROVIDER`. Постои и миграционен Job (`k8s/migrations/migrate-uploads-job.yml`) што ја префрла старата содржина од `listing-uploads-pvc` / `blog-uploads-pvc` во MinIO.

### Ingress

NGINX Ingress за `automarket.local`: `/api` и `/uploads` → Gateway :8080, `/` → Frontend :80.

### GitOps (ArgoCD)

`k8s/argocd/install.yml` го инсталира ArgoCD, а `k8s/argocd/application.yml` дефинира `Application` ресурс што ја следи `k8s/` папката во репозиториумот — декларативен continuous deployment наместо рачен `kubectl apply`.

### Deployment скрипта ([deploy.sh](https://github.com/Dkostoski30/automarket2-be/blob/feature/devops-setup/k8s/deploy.sh))

1. `k3d cluster create` (порт 80+443, без Traefik) + инсталација на NGINX ingress controller
2. Docker build за сите 7 сервиси + frontend
3. `k3d image import`
4. `kubectl apply`: namespace → configmap/secret → инфраструктура → migration job-ови → сервиси → ingress → autoscaling / PDB / NetworkPolicy
5. Верификација: `kubectl wait` + `kubectl get pods`

**Пристап:**
```
Frontend:    http://automarket.local
API:         http://automarket.local/api/v1/reference/car-brands
Prometheus:  kubectl port-forward svc/prometheus 9090:9090
Grafana:     kubectl port-forward svc/grafana 3000:3000  (admin/admin)
MinIO:       kubectl port-forward svc/minio 9001:9001
```

Потребно: `127.0.0.1 automarket.local` во `C:\Windows\System32\drivers\etc\hosts`

**Вкупно: 67 Kubernetes ресурси** — 1 Namespace, 6 ConfigMaps, 5 Secrets, 3 StatefulSets, 12 Deployments, 15 Services, 8 HPA, 8 PodDisruptionBudgets, 6 NetworkPolicies, 2 Jobs, 1 Ingress (плус ArgoCD `Application`).
