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
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

/**
 * Downstream service filter: reads trusted X-User-Email and X-User-Roles headers
 * injected by the API Gateway and populates the Spring SecurityContext.
 *
 * Services using this filter do NOT parse JWTs — the gateway already validated them.
 * This filter must only be active when traffic comes through the gateway (internal network).
 *
 * Usage: register as a Spring bean and add before UsernamePasswordAuthenticationFilter.
 */
@Slf4j
public class GatewayAuthFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(
            @NonNull HttpServletRequest request,
            @NonNull HttpServletResponse response,
            @NonNull FilterChain filterChain
    ) throws ServletException, IOException {

        String email = request.getHeader(SecurityConstants.USER_EMAIL_HEADER);
        String rolesHeader = request.getHeader(SecurityConstants.USER_ROLES_HEADER);

        if (StringUtils.hasText(email)) {
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
        } else {
            SecurityContextHolder.clearContext();
        }

        filterChain.doFilter(request, response);
    }
}
