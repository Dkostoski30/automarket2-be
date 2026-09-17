package com.automarket.notification.consumer;

import com.automarket.events.KafkaTopics;
import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import lombok.extern.slf4j.Slf4j;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.common.header.Header;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.support.KafkaHeaders;
import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;

/**
 * Makes dead-lettering visible.
 *
 * <p>Dead-lettering was implemented but unobservable: a record that failed three
 * retries landed on {@code <topic>-dlt} and stayed there, with nothing counting it,
 * alerting on it, or saying what went wrong. An event silently not being processed
 * is the failure this whole outbox/inbox design exists to prevent, so it should be
 * the loudest thing in the system, not the quietest.
 *
 * <p>This deliberately does not retry or repair anything. Replaying a dead letter
 * means deciding why it failed first — a poison payload must not be re-fed to the
 * consumer that already rejected it three times. The counter drives the alert; a
 * human then reads the log line and decides.
 *
 * <p>It runs in notification-service purely because that service already exists to
 * consume events and owns no domain data of its own.
 */
@Slf4j
@Component
public class DeadLetterMonitor {

    private final Counter deadLetters;

    public DeadLetterMonitor(MeterRegistry registry) {
        this.deadLetters = Counter.builder("automarket.dlt.records")
                .description("Records that exhausted retries and were dead-lettered")
                .register(registry);
    }

    @KafkaListener(
            topics = {
                    KafkaTopics.USER_EVENTS_DLT,
                    KafkaTopics.LISTING_EVENTS_DLT,
                    KafkaTopics.INQUIRY_EVENTS_DLT,
                    KafkaTopics.SUBSCRIPTION_EVENTS_DLT
            },
            groupId = KafkaTopics.GROUP_DLT_MONITOR)
    public void handle(ConsumerRecord<String, String> record) {
        deadLetters.increment();

        // DeadLetterPublishingRecoverer records why it gave up in these headers.
        log.error("DEAD LETTER on {} (key={}): original topic={}, exception={}: {}",
                record.topic(),
                record.key(),
                header(record, KafkaHeaders.DLT_ORIGINAL_TOPIC),
                header(record, KafkaHeaders.DLT_EXCEPTION_FQCN),
                header(record, KafkaHeaders.DLT_EXCEPTION_MESSAGE));
    }

    /**
     * Never throws. A monitor that can fail on a malformed header would itself be
     * dead-lettered, onto a topic nothing watches.
     */
    private static String header(ConsumerRecord<String, String> record, String name) {
        Header header = record.headers().lastHeader(name);
        if (header == null || header.value() == null) {
            return "unknown";
        }
        return new String(header.value(), StandardCharsets.UTF_8);
    }
}
