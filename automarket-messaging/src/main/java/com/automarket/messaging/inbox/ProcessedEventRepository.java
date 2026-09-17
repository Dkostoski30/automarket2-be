package com.automarket.messaging.inbox;

import org.springframework.data.jpa.repository.JpaRepository;

public interface ProcessedEventRepository
        extends JpaRepository<ProcessedEvent, ProcessedEvent.Key> {

    boolean existsByEventIdAndConsumerGroup(String eventId, String consumerGroup);
}
