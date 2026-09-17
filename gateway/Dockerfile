# ── Stage 1: Build ──────────────────────────────────────────────
FROM maven:3.9-eclipse-temurin-21-alpine AS build
WORKDIR /app

# The whole reactor is copied in one step. Listing module paths here instead
# meant every new Maven module silently broke the build — the parent pom
# declares it, Maven fails loading the reactor, and no image builds.
# .dockerignore keeps the context small; the /root/.m2 cache mount below is
# what keeps dependency downloads off the critical path.
COPY . .

RUN --mount=type=cache,target=/root/.m2,sharing=locked \
    mvn package -pl gateway -am -DskipTests -B && \
    java -Djarmode=layertools -jar gateway/target/*.jar extract --destination gateway/target/extracted

# ── Stage 2: Runtime ────────────────────────────────────────────
FROM eclipse-temurin:21-jre-alpine AS runtime
WORKDIR /app

RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

COPY --from=build /app/gateway/target/extracted/dependencies/ ./
COPY --from=build /app/gateway/target/extracted/spring-boot-loader/ ./
COPY --from=build /app/gateway/target/extracted/snapshot-dependencies/ ./
COPY --from=build /app/gateway/target/extracted/application/ ./

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=3 \
  CMD wget -qO- http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", \
  "-XX:+UseContainerSupport", \
  "-XX:MaxRAMPercentage=75.0", \
  "-XX:+UseSerialGC", \
  "-Xss256k", \
  "-Djava.security.egd=file:/dev/./urandom", \
  "org.springframework.boot.loader.launch.JarLauncher"]
