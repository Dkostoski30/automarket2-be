package com.automarket.messaging.inbox;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.Instant;

/**
 * Deduplicates at-least-once event delivery.
 *
 * <p>Call {@link #alreadyProcessed} before acting, and {@link #markProcessed} from
 * within the same transaction as the effect. If that transaction rolls back, the
 * marker rolls back with it and the event is retried - which is what we want.
 *
 * <p>No @Transactional here on purpose: both methods must join the caller's
 * transaction rather than commit independently of it.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class InboxGuard {

    private final ProcessedEventRepository processedEventRepository;

    public boolean alreadyProcessed(String eventId, String consumerGroup) {
        return processedEventRepository.existsByEventIdAndConsumerGroup(eventId, consumerGroup);
    }

    public void markProcessed(String eventId, String consumerGroup, String eventType) {
        processedEventRepository.save(ProcessedEvent.builder()
                .eventId(eventId)
                .consumerGroup(consumerGroup)
                .eventType(eventType)
                .processedAt(Instant.now())
                .build());
    }
}
