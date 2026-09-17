package com.automarket.events;

import org.apache.kafka.common.TopicPartition;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.config.TopicBuilder;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.listener.DeadLetterPublishingRecoverer;
import org.springframework.kafka.listener.DefaultErrorHandler;
import org.apache.kafka.clients.admin.NewTopic;
import org.springframework.util.backoff.FixedBackOff;

/**
 * Event bus infrastructure: topic definitions and consumer error handling.
 *
 * <p>Declared in the shared module, so every service that depends on
 * automarket-events creates the topics if they are absent. That is safe and
 * idempotent — unlike the previous RabbitMQ setup, where every service declared
 * every queue and unconsumed queues then grew without bound. A Kafka topic with
 * no consumer simply ages out under the broker's retention policy.
 *
 * <p>Single broker in dev and for the thesis deployment, hence replicas = 1.
 * Raise the replication factor before running this anywhere real.
 */
@Configuration
public class KafkaConfig {

    private static final int PARTITIONS = 3;
    private static final short REPLICAS = 1;

    @Bean
    public NewTopic userEventsTopic() {
        return TopicBuilder.name(KafkaTopics.USER_EVENTS)
                .partitions(PARTITIONS).replicas(REPLICAS).build();
    }

    @Bean
    public NewTopic listingEventsTopic() {
        return TopicBuilder.name(KafkaTopics.LISTING_EVENTS)
                .partitions(PARTITIONS).replicas(REPLICAS).build();
    }

    @Bean
    public NewTopic inquiryEventsTopic() {
        return TopicBuilder.name(KafkaTopics.INQUIRY_EVENTS)
                .partitions(PARTITIONS).replicas(REPLICAS).build();
    }

    @Bean
    public NewTopic subscriptionEventsTopic() {
        return TopicBuilder.name(KafkaTopics.SUBSCRIPTION_EVENTS)
                .partitions(PARTITIONS).replicas(REPLICAS).build();
    }

    /**
     * Retries a failing record three times with a 2s backoff, then publishes it to
     * "<topic>-dlt" instead of discarding it.
     *
     * <p>This replaces the previous catch-and-log in the notification consumer,
     * which acknowledged failed messages and lost them permanently. Listeners can
     * now let exceptions propagate.
     *
     * <p>Partition is -1 so Kafka picks one on the dead-letter topic; the default
     * resolver reuses the source partition number, which fails when the DLT has
     * fewer partitions.
     */
    @Bean
    public DefaultErrorHandler kafkaErrorHandler(KafkaTemplate<String, Object> kafkaTemplate) {
        DeadLetterPublishingRecoverer recoverer = new DeadLetterPublishingRecoverer(
                kafkaTemplate,
                (record, exception) -> new TopicPartition(record.topic() + KafkaTopics.DLT_SUFFIX, -1));
        return new DefaultErrorHandler(recoverer, new FixedBackOff(2_000L, 3L));
    }
}
