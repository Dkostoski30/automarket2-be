package com.automarket.security.common;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.lang.NonNull;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

/**
 * Builds the SecurityContext from the identity headers the gateway injects.
 *
 * <p>Services do not parse JWTs — the gateway already validated one. What they must
 * do is establish that the headers actually came from the gateway. Previously they
 * did not: {@code X-User-Email} and {@code X-User-Roles} were trusted on sight, so
 * any workload that could reach a service's ClusterIP could assert
 * {@code ROLE_ADMIN} for any address it liked. Service ports are not exposed through
 * the ingress, but "not routable from the internet" is not an authorization check.
 *
 * <p>The gateway now signs each forwarded request with a shared secret in
 * {@link SecurityConstants#GATEWAY_AUTH_HEADER}. A request whose secret is absent or
 * wrong is treated as anonymous: the identity headers are ignored rather than the
 * request rejected, so public endpoints keep working for direct callers and only
 * privileged ones start refusing.
 *
 * <p>Comparison is constant-time. A byte-by-byte {@code equals} on a secret leaks
 * its prefix to anything that can time responses.
 *
 * <p>This is one half of the fix. A NetworkPolicy (k8s/networkpolicy.yml) restricts
 * who can open the connection at all; the secret covers what the policy cannot,
 * such as a compromised pod that is allowed to talk to the service.
 */
@Slf4j
public class GatewayAuthFilter extends OncePerRequestFilter {

    /** Matches the fallback in each service's application.yml. */
    private static final String DEV_DEFAULT_SECRET = "dev-insecure-gateway-secret";

    private final byte[] expectedSecret;

    public GatewayAuthFilter(String sharedSecret) {
        this.expectedSecret = sharedSecret == null
                ? new byte[0]
                : sharedSecret.getBytes(StandardCharsets.UTF_8);

        if (DEV_DEFAULT_SECRET.equals(sharedSecret)) {
            log.warn("GATEWAY_SHARED_SECRET is unset — using the built-in development "
                    + "value. Set it before deploying anywhere real, or service-to-service "
                    + "identity is guessable.");
        } else if (expectedSecret.length == 0) {
            log.error("No gateway shared secret configured. Every request will be "
                    + "treated as anonymous, so authenticated endpoints will return 403.");
        }
    }

    @Override
    protected void doFilterInternal(
            @NonNull HttpServletRequest request,
            @NonNull HttpServletResponse response,
            @NonNull FilterChain filterChain
    ) throws ServletException, IOException {

        String email = request.getHeader(SecurityConstants.USER_EMAIL_HEADER);

        if (!StringUtils.hasText(email)) {
            SecurityContextHolder.clearContext();
            filterChain.doFilter(request, response);
            return;
        }

        if (!fromGateway(request)) {
            // Deliberately not a 401: an unauthenticated request is a legitimate way
            // to reach a public endpoint. Dropping the claimed identity is enough.
            log.warn("Ignoring identity headers on {} {} — no valid gateway secret. "
                            + "Claimed identity was {}",
                    request.getMethod(), request.getRequestURI(), email);
            SecurityContextHolder.clearContext();
            filterChain.doFilter(request, response);
            return;
        }

        String rolesHeader = request.getHeader(SecurityConstants.USER_ROLES_HEADER);
        List<SimpleGrantedAuthority> authorities = StringUtils.hasText(rolesHeader)
                ? Arrays.stream(rolesHeader.split(","))
                    .map(String::trim)
                    .filter(StringUtils::hasText)
                    .map(SimpleGrantedAuthority::new)
                    .toList()
                : Collections.emptyList();

        UsernamePasswordAuthenticationToken auth =
                new UsernamePasswordAuthenticationToken(email, null, authorities);

        SecurityContextHolder.getContext().setAuthentication(auth);
        log.debug("Gateway auth: email={}, roles={}", email, rolesHeader);

        filterChain.doFilter(request, response);
    }

    private boolean fromGateway(HttpServletRequest request) {
        if (expectedSecret.length == 0) {
            return false;
        }
        String presented = request.getHeader(SecurityConstants.GATEWAY_AUTH_HEADER);
        if (presented == null) {
            return false;
        }
        return MessageDigest.isEqual(presented.getBytes(StandardCharsets.UTF_8), expectedSecret);
    }
}
