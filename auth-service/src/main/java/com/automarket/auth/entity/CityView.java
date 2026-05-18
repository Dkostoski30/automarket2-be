package com.automarket.auth.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.Immutable;

import java.util.UUID;

/**
 * Read-only view of the cities table.
 * The cities table is owned by reference-service; auth-service only reads it.
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
