package com.automarket.listing.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.Immutable;

import java.util.UUID;

/**
 * Read-only reference entity — owned by reference-service.
 */
@Entity
@Table(name = "transmission_types")
@Immutable
@Getter
@NoArgsConstructor
public class TransmissionType {

    @Id
    private UUID id;

    @Column(nullable = false, unique = true, length = 100)
    private String name;
}
