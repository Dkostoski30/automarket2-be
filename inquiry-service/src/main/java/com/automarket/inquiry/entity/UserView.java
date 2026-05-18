package com.automarket.inquiry.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.Immutable;

import java.util.UUID;

@Entity
@Table(name = "users")
@Immutable
@Getter
@NoArgsConstructor
public class UserView {

    @Id
    private UUID id;

    private String name;

    private String email;
}
