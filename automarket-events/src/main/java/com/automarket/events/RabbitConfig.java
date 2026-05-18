package com.automarket.events;

import org.springframework.amqp.core.*;
import org.springframework.amqp.rabbit.connection.ConnectionFactory;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.amqp.support.converter.Jackson2JsonMessageConverter;
import org.springframework.amqp.support.converter.MessageConverter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * RabbitMQ infrastructure: topic exchange + per-service queues with bindings.
 *
 * Exchange: automarket.events (topic)
 * Each service declares only the queues it consumes from.
 * Publishers use routing keys like "user.registered", "listing.approved", etc.
 */
@Configuration
public class RabbitConfig {

    public static final String EXCHANGE = "automarket.events";

    // Queue names — each service declares what it needs
    public static final String QUEUE_NOTIFICATION   = "notification-service.events";
    public static final String QUEUE_LISTING_USER   = "listing-service.user-events";
    public static final String QUEUE_INQUIRY_USER   = "inquiry-service.user-events";
    public static final String QUEUE_BLOG_USER      = "blog-service.user-events";
    public static final String QUEUE_AUTH_SUBSCRIPTION = "auth-service.subscription-events";

    @Bean
    public TopicExchange automarketExchange() {
        return ExchangeBuilder.topicExchange(EXCHANGE).durable(true).build();
    }

    // --- Notification service queues ---
    @Bean
    public Queue notificationQueue() {
        return QueueBuilder.durable(QUEUE_NOTIFICATION).build();
    }

    @Bean
    public Binding notificationListingApproved(Queue notificationQueue, TopicExchange automarketExchange) {
        return BindingBuilder.bind(notificationQueue).to(automarketExchange).with(ListingEvent.APPROVED);
    }

    @Bean
    public Binding notificationListingRejected(Queue notificationQueue, TopicExchange automarketExchange) {
        return BindingBuilder.bind(notificationQueue).to(automarketExchange).with(ListingEvent.REJECTED);
    }

    @Bean
    public Binding notificationInquirySent(Queue notificationQueue, TopicExchange automarketExchange) {
        return BindingBuilder.bind(notificationQueue).to(automarketExchange).with(InquiryEvent.SENT);
    }

    @Bean
    public Binding notificationUserRegistered(Queue notificationQueue, TopicExchange automarketExchange) {
        return BindingBuilder.bind(notificationQueue).to(automarketExchange).with(UserEvent.REGISTERED);
    }

    // --- Listing service: user events ---
    @Bean
    public Queue listingUserQueue() {
        return QueueBuilder.durable(QUEUE_LISTING_USER).build();
    }

    @Bean
    public Binding listingUserDisabled(Queue listingUserQueue, TopicExchange automarketExchange) {
        return BindingBuilder.bind(listingUserQueue).to(automarketExchange).with(UserEvent.DISABLED);
    }

    @Bean
    public Binding listingUserDeleted(Queue listingUserQueue, TopicExchange automarketExchange) {
        return BindingBuilder.bind(listingUserQueue).to(automarketExchange).with(UserEvent.DELETED);
    }

    @Bean
    public Binding listingUserPlanChanged(Queue listingUserQueue, TopicExchange automarketExchange) {
        return BindingBuilder.bind(listingUserQueue).to(automarketExchange).with(UserEvent.PLAN_CHANGED);
    }

    // --- Auth service: subscription events ---
    @Bean
    public Queue authSubscriptionQueue() {
        return QueueBuilder.durable(QUEUE_AUTH_SUBSCRIPTION).build();
    }

    @Bean
    public Binding authSubscriptionActivated(Queue authSubscriptionQueue, TopicExchange automarketExchange) {
        return BindingBuilder.bind(authSubscriptionQueue).to(automarketExchange).with(SubscriptionEvent.ACTIVATED);
    }

    @Bean
    public Binding authSubscriptionCancelled(Queue authSubscriptionQueue, TopicExchange automarketExchange) {
        return BindingBuilder.bind(authSubscriptionQueue).to(automarketExchange).with(SubscriptionEvent.CANCELLED);
    }

    // --- JSON message converter (all services use Jackson) ---
    @Bean
    public MessageConverter jsonMessageConverter() {
        return new Jackson2JsonMessageConverter();
    }

    @Bean
    public RabbitTemplate rabbitTemplate(ConnectionFactory connectionFactory) {
        RabbitTemplate template = new RabbitTemplate(connectionFactory);
        template.setMessageConverter(jsonMessageConverter());
        return template;
    }
}
