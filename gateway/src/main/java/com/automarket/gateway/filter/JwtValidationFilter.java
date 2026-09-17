package com.automarket.gateway.filter;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Set;

/**
 * Global gateway filter that validates JWT tokens and forwards user identity as trusted headers.
 *
 * Public routes (defined in PUBLIC_PREFIXES / PUBLIC_EXACT) are forwarded without a token.
 * All other routes require a valid, non-expired JWT — missing or invalid tokens get a 401
 * immediately at the gateway level.
 *
 * On success, the validated identity is forwarded as trusted headers (X-User-Email,
 * X-User-Roles, X-User-Id). Downstream services read these headers via GatewayAuthFilter
 * and do not re-parse the JWT.
 *
 * Precedence: highest (Ordered.HIGHEST_PRECEDENCE) so JWT validation runs first.
 */
@Slf4j
@Component
public class JwtValidationFilter implements GlobalFilter, Ordered {

    private static final String BEARER_PREFIX = "Bearer ";

    /**
     * Paths that bypass JWT validation entirely (public routes).
     * These are forwarded to the downstream service without any token check.
     */
    // Duplicated from SecurityConstants rather than imported: that class lives in
    // automarket-security-common, which depends on spring-boot-starter-web, and
    // Spring MVC on the classpath makes Spring Cloud Gateway refuse to start. The
    // two copies must stay in sync — they are the contract with every service.
    private static final String USER_EMAIL_HEADER   = "X-User-Email";
    private static final String USER_ROLES_HEADER   = "X-User-Roles";
    private static final String USER_ID_HEADER      = "X-User-Id";
    private static final String GATEWAY_AUTH_HEADER = "X-Gateway-Auth";

    private static final Set<String> PUBLIC_PREFIXES = Set.of(
            "/api/v1/auth/",
            "/api/v1/reference/",
            "/api/v1/webhooks/",
            "/api/v1/subscriptions/plans",
            "/v3/api-docs",
            // Aggregated OpenAPI documents proxied to each service; see the
            // api-docs-* routes and springdoc.swagger-ui.urls.
            "/api-docs/",
            "/swagger-ui",
            "/uploads/"
    );

    private static final Set<String> PUBLIC_EXACT = Set.of(
            "/api/v1/listings",
            "/api/v1/blog",
            "/swagger-ui.html",
            "/actuator/health",
            // Prometheus scrapes the gateway like any other service. Without this
            // the scrape got a 401 and the gateway had no metrics at all.
            "/actuator/prometheus"
    );

    @Value("${automarket.jwt.secret}")
    private String jwtSecret;

    @Value("${automarket.gateway.shared-secret:}")
    private String gatewaySharedSecret;

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        String path = exchange.getRequest().getPath().value();

        // Strip authorization header from previously-injected gateway headers for security
        ServerHttpRequest cleanRequest = exchange.getRequest().mutate()
                .headers(headers -> {
                    headers.remove(USER_EMAIL_HEADER);
                    headers.remove(USER_ROLES_HEADER);
                    headers.remove(USER_ID_HEADER);
                    // A client that supplies its own gateway secret must not have it
                    // forwarded, or stripping the identity headers achieves nothing.
                    headers.remove(GATEWAY_AUTH_HEADER);
                })
                .build();

        HttpMethod method = exchange.getRequest().getMethod();

        if (isPublic(path, method)) {
            return chain.filter(exchange.mutate().request(cleanRequest).build());
        }

        String authHeader = exchange.getRequest().getHeaders().getFirst(HttpHeaders.AUTHORIZATION);

        if (!StringUtils.hasText(authHeader) || !authHeader.startsWith(BEARER_PREFIX)) {
            exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
            return exchange.getResponse().setComplete();
        }

        String token = authHeader.substring(BEARER_PREFIX.length());

        try {
            Claims claims = Jwts.parser()
                    .verifyWith(getSigningKey())
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();

            String email = claims.getSubject();
            String userId = claims.getId() != null ? claims.getId() : "";

            // Extract roles claim (stored as List<String> in JWT)
            Object rolesClaim = claims.get("roles");
            String rolesHeader = "";
            if (rolesClaim instanceof List<?> rolesList) {
                rolesHeader = String.join(",", rolesList.stream()
                        .map(Object::toString)
                        .toList());
            }

            // Forward trusted headers to downstream service
            // The secret is what makes these headers trustworthy downstream: the
            // gateway is the only component that validated a JWT, so it is the only
            // one entitled to assert an identity.
            ServerHttpRequest mutatedRequest = cleanRequest.mutate()
                    .header(USER_EMAIL_HEADER, email)
                    .header(USER_ROLES_HEADER, rolesHeader)
                    .header(USER_ID_HEADER, userId)
                    .header(GATEWAY_AUTH_HEADER, gatewaySharedSecret)
                    .build();

            log.debug("JWT validated: email={}, roles={}", email, rolesHeader);
            return chain.filter(exchange.mutate().request(mutatedRequest).build());

        } catch (JwtException | IllegalArgumentException e) {
            log.warn("Invalid JWT token on {}: {}", path, e.getMessage());
            exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
            return exchange.getResponse().setComplete();
        }
    }

    private boolean isPublic(String path, HttpMethod method) {
        if (PUBLIC_EXACT.contains(path) && method == HttpMethod.GET) return true;
        // GET /api/v1/listings/{id} and /api/v1/listings/slug/{slug} are public
        if (method == HttpMethod.GET && path.startsWith("/api/v1/listings/") && !path.contains("/favorite") && !path.contains("/images") && !path.contains("/analytics") && !path.equals("/api/v1/listings/my")) return true;
        if (method == HttpMethod.GET && path.startsWith("/api/v1/blog/") && !path.contains("/images") && !path.contains("/cover-image")) return true;
        if (method == HttpMethod.GET && path.startsWith("/api/v1/users/") && !path.equals("/api/v1/users/me")) return true;
        return PUBLIC_PREFIXES.stream().anyMatch(path::startsWith);
    }

    private SecretKey getSigningKey() {
        return Keys.hmacShaKeyFor(jwtSecret.getBytes(StandardCharsets.UTF_8));
    }

    @Override
    public int getOrder() {
        return Ordered.HIGHEST_PRECEDENCE;
    }
}
