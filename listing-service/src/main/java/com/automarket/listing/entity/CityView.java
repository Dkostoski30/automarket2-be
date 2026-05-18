package com.automarket.listing.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.Immutable;

import java.util.UUID;

/**
 * Read-only JPA view of the cities table.
 */
@Entity
@Table(name = "cities")
@Immutable
@Getter
@NoArgsConstructor
public class CityView {

    @Id
    private UUID id;

    private String name;
}
