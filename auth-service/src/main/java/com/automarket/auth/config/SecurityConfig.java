package com.automarket.auth.config;

import com.automarket.security.common.GatewayAuthFilter;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final UserDetailsService userDetailsService;

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
                        .requestMatchers("/api/v1/auth/**").permitAll()
                        // Order matters, and this pair has to stay in this order: the
                        // public-profile pattern below is a single path variable, so it
                        // also matches the literal "me". With only that rule every method
                        // on /users/me was permitAll here, so a request whose identity
                        // headers the gateway filter dropped reached the controller
                        // anonymously and came back 404 "User not found" — an
                        // authentication failure wearing a data error's status code.
                        // It is now a 403, which says what actually went wrong. The
                        // gateway still rejects a missing or invalid JWT with a 401
                        // before anything reaches this service, so a 403 here means
                        // specifically that the X-Gateway-Auth secret did not match.
                        .requestMatchers("/api/v1/users/me", "/api/v1/users/me/**").authenticated()
                        .requestMatchers(HttpMethod.GET, "/api/v1/users/{id}").permitAll()
                        .requestMatchers("/api/v1/webhooks/**").permitAll()
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
                        .requestMatchers("/api/v1/admin/**").hasRole("ADMIN")
                        .anyRequest().authenticated()
                )
                .authenticationProvider(authenticationProvider())
                .addFilterBefore(gatewayAuthFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(12);
    }

    @Bean
    public AuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider provider = new DaoAuthenticationProvider();
        provider.setUserDetailsService(userDetailsService);
        provider.setPasswordEncoder(passwordEncoder());
        return provider;
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }
}
