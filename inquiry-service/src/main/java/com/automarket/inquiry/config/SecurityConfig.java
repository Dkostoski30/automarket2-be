package com.automarket.inquiry.config;

import com.automarket.security.common.GatewayAuthFilter;
import org.springframework.beans.factory.annotation.Value;
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
    public GatewayAuthFilter gatewayAuthFilter(
            @Value("${automarket.gateway.shared-secret:}") String gatewaySharedSecret) {
        return new GatewayAuthFilter(gatewaySharedSecret);
    }

    @Bean
    public SecurityFilterChain securityFilterChain(
            HttpSecurity http, GatewayAuthFilter gatewayAuthFilter) throws Exception {
        http
                .csrf(AbstractHttpConfigurer::disable)
                .sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        // Health for the kubelet, prometheus for the scraper. Both
                        // were reachable only with credentials before, so every scrape
                        // returned 401 and no service metrics ever reached Prometheus
                        // (ARCHITECTURE.md #32). These pods are not internet-facing:
                        // the ingress routes only to the gateway and the frontend.
                        .requestMatchers(HttpMethod.GET,
                                "/actuator/health", "/actuator/health/**",
                                "/actuator/prometheus", "/actuator/info").permitAll()
                        .requestMatchers("/v3/api-docs/**", "/swagger-ui/**", "/swagger-ui.html").permitAll()
                        .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
                        .anyRequest().authenticated()
                )
                .addFilterBefore(gatewayAuthFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}
