package com.automarket.messaging.outbox;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.UUID;

public interface OutboxRepository extends JpaRepository<OutboxEvent, UUID> {

    /**
     * Claims a batch of this service's unpublished events.
     *
     * <p>FOR UPDATE SKIP LOCKED lets several replicas of the same service relay
     * concurrently without any of them publishing the same record twice: rows locked
     * by another transaction are skipped rather than waited on.
     */
    @Query(value = "SELECT * FROM outbox "
            + "WHERE source_service = :sourceService AND published_at IS NULL "
            + "ORDER BY created_at "
            + "LIMIT :batchSize "
            + "FOR UPDATE SKIP LOCKED", nativeQuery = true)
    List<OutboxEvent> claimPending(@Param("sourceService") String sourceService,
                                   @Param("batchSize") int batchSize);

    long countBySourceServiceAndPublishedAtIsNull(String sourceService);
}
