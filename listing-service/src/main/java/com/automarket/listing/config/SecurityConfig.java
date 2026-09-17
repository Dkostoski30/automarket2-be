package com.automarket.listing.config;

import com.automarket.security.common.GatewayAuthFilter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {

    @Bean
    public GatewayAuthFilter gatewayAuthFilter() {
        return new GatewayAuthFilter();
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .csrf(AbstractHttpConfigurer::disable)
                .sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        // Public listing endpoints
                        .requestMatchers(HttpMethod.GET,
                                "/api/v1/listings",
                                "/api/v1/listings/featured",
                                "/api/v1/listings/slug/{slug}",
                                "/api/v1/listings/{id}"
                        ).permitAll()
                        // Public reference data endpoints
                        .requestMatchers(HttpMethod.GET, "/api/v1/reference/**").permitAll()
                        // Static uploads
                        .requestMatchers("/uploads/**").permitAll()
                        // Actuator & docs
                        .requestMatchers("/actuator/health").permitAll()
                        .requestMatchers("/v3/api-docs/**", "/swagger-ui/**", "/swagger-ui.html").permitAll()
                        // CORS preflight
                        .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
                        // Admin endpoints
                        .requestMatchers("/api/v1/admin/**").hasRole("ADMIN")
                        // Moderation endpoints
                        .requestMatchers("/api/v1/moderation/**").hasAnyRole("MODERATOR", "ADMIN")
                        // Everything else requires authentication
                        .anyRequest().authenticated()
                )
                .addFilterBefore(gatewayAuthFilter(), UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}
