package com.automarket.gateway.config;

import org.springframework.cloud.gateway.filter.ratelimit.KeyResolver;
import org.springframework.cloud.gateway.filter.ratelimit.RedisRateLimiter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import reactor.core.publisher.Mono;

import java.net.InetSocketAddress;

/**
 * Rate limiting at the gateway.
 *
 * <p>The Redis dependency for this was declared, and the comment next to it said
 * "for rate limiting", but no {@code RequestRateLimiter} was ever configured: all
 * fourteen routes were unlimited. Login was the sharp edge — {@code /api/v1/auth/login}
 * was an unmetered password oracle — but any endpoint could be used to exhaust a
 * service's Hikari pool (5 connections) from a single client.
 *
 * <p>Buckets are per identity where there is one and per IP otherwise. Keying on IP
 * alone would let one authenticated user behind a shared NAT consume the whole
 * allowance for everyone at that address; keying on identity alone gives anonymous
 * traffic no limit at all.
 *
 * <p>Note this makes Redis a hard dependency of the request path: RedisRateLimiter
 * denies requests it cannot score, so a Redis outage sheds traffic rather than
 * letting it through. That is the safer default of the two, and Redis is already
 * required for listing-service's caches.
 */
@Configuration
public class RateLimiterConfig {

    /**
     * Identity first, IP second.
     *
     * <p>Reads the header the gateway itself sets after validating the JWT, so it is
     * trustworthy here — unlike downstream, where the same header needs the shared
     * secret to be believed.
     */
    @Bean
    @Primary
    public KeyResolver userOrIpKeyResolver() {
        return exchange -> {
            String email = exchange.getRequest().getHeaders().getFirst("X-User-Email");
            if (email != null && !email.isBlank()) {
                return Mono.just("user:" + email);
            }
            return Mono.just("ip:" + clientIp(exchange.getRequest().getRemoteAddress()));
        };
    }

    /**
     * IP only — for the auth routes, where by definition there is no identity yet.
     */
    @Bean
    public KeyResolver clientIpKeyResolver() {
        return exchange -> Mono.just("ip:" + clientIp(exchange.getRequest().getRemoteAddress()));
    }

    /**
     * Tight bucket for credential endpoints: 5 requests/second, bursting to 10.
     *
     * <p>Generous for a human logging in, useless for enumerating passwords.
     */
    @Bean
    public RedisRateLimiter authRateLimiter() {
        return new RedisRateLimiter(5, 10, 1);
    }

    private static String clientIp(InetSocketAddress address) {
        // A missing remote address is grouped under one key rather than exempted,
        // so an unresolvable peer cannot bypass the limit.
        return address == null ? "unknown" : address.getAddress().getHostAddress();
    }
}
