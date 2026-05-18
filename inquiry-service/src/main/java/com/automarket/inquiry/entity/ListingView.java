package com.automarket.inquiry.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.Immutable;

import java.util.UUID;

@Entity
@Table(name = "listings")
@Immutable
@Getter
@NoArgsConstructor
public class ListingView {

    @Id
    private UUID id;

    private String title;

    @Column(name = "seller_id")
    private UUID sellerId;

    private boolean approved;
}
