# ── Stage 1: Build ──────────────────────────────────────────────
FROM maven:3.9-eclipse-temurin-21-alpine AS build
WORKDIR /app

COPY pom.xml ./pom.xml
COPY automarket-common/pom.xml ./automarket-common/pom.xml
COPY automarket-security-common/pom.xml ./automarket-security-common/pom.xml
COPY automarket-storage/pom.xml ./automarket-storage/pom.xml
COPY automarket-events/pom.xml ./automarket-events/pom.xml
COPY gateway/pom.xml ./gateway/pom.xml
COPY auth-service/pom.xml ./auth-service/pom.xml
COPY listing-service/pom.xml ./listing-service/pom.xml
COPY blog-service/pom.xml ./blog-service/pom.xml
COPY inquiry-service/pom.xml ./inquiry-service/pom.xml
COPY reference-service/pom.xml ./reference-service/pom.xml
COPY payment-service/pom.xml ./payment-service/pom.xml
COPY notification-service/pom.xml ./notification-service/pom.xml

RUN --mount=type=cache,target=/root/.m2 \
    mvn dependency:go-offline -pl inquiry-service -am -B 2>/dev/null || true

COPY automarket-common/src ./automarket-common/src
COPY automarket-security-common/src ./automarket-security-common/src
COPY automarket-events/src ./automarket-events/src
COPY inquiry-service/src ./inquiry-service/src

RUN --mount=type=cache,target=/root/.m2 \
    mvn package -pl inquiry-service -am -DskipTests -B && \
    java -Djarmode=layertools -jar inquiry-service/target/*.jar extract --destination inquiry-service/target/extracted

# ── Stage 2: Runtime ────────────────────────────────────────────
FROM eclipse-temurin:21-jre-alpine AS runtime
WORKDIR /app

RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

COPY --from=build /app/inquiry-service/target/extracted/dependencies/ ./
COPY --from=build /app/inquiry-service/target/extracted/spring-boot-loader/ ./
COPY --from=build /app/inquiry-service/target/extracted/snapshot-dependencies/ ./
COPY --from=build /app/inquiry-service/target/extracted/application/ ./

EXPOSE 8084

HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD wget -qO- http://localhost:8084/actuator/health || exit 1

ENTRYPOINT ["java", \
  "-XX:+UseContainerSupport", \
  "-XX:MaxRAMPercentage=75.0", \
  "-Djava.security.egd=file:/dev/./urandom", \
  "org.springframework.boot.loader.launch.JarLauncher"]
