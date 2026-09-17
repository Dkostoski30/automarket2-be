package com.automarket.messaging;

import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * Makes the outbox and inbox tables visible to services that include this module.
 *
 * <p>Both packages sit outside each service's own base package, so Spring Boot's
 * default entity and repository scanning (rooted at the @SpringBootApplication class)
 * would miss them. Scanning is widened to "com.automarket" - which still covers each
 * service's own entities, since declaring @EntityScan replaces the default root
 * rather than adding to it.
 *
 * <p>@EnableScheduling is required by OutboxRelay.
 */
@Configuration
@EntityScan(basePackages = "com.automarket")
@EnableJpaRepositories(basePackages = "com.automarket")
@EnableScheduling
public class MessagingConfiguration {
}
