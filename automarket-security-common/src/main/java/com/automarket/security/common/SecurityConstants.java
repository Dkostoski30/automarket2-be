package com.automarket.security.common;

/**
 * Shared security constants used by all services.
 * The gateway reads Authorization header, validates JWT, then forwards these trusted headers downstream.
 * Downstream services build their SecurityContext from the trusted headers (no JWT re-parsing needed).
 */
public final class SecurityConstants {

    private SecurityConstants() {}

    // Headers forwarded by the gateway after JWT validation
    public static final String USER_EMAIL_HEADER = "X-User-Email";
    public static final String USER_ROLES_HEADER  = "X-User-Roles";
    public static final String USER_ID_HEADER     = "X-User-Id";
    public static final String REQUEST_ID_HEADER  = "X-Request-Id";

    /**
     * Proves the identity headers above came from the gateway.
     *
     * <p>Without it the X-User-* headers are self-asserted: anything that can reach
     * a service's ClusterIP — any pod in the namespace, including a compromised one
     * — could send {@code X-User-Roles: ROLE_ADMIN} and be an admin. The gateway is
     * the only component that validates a JWT, so it is the only component allowed
     * to state who the caller is.
     */
    public static final String GATEWAY_AUTH_HEADER = "X-Gateway-Auth";

    public static final String TOKEN_PREFIX        = "Bearer ";
    public static final String AUTHORIZATION_HEADER = "Authorization";
}
