package com.automarket.payment.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.UUID;

/**
 * Local read model of a user, owned by payment-service.
 *
 * <p>Previously mapped onto auth-service's `users` table. It now maps onto
 * payment_user_view, kept current by UserEventConsumer from the user-events topic.
 */
@Entity
@Table(name = "payment_user_view")
@Getter
@Setter
@NoArgsConstructor
public class UserView {

    @Id
    private UUID id;

    private String email;

    private String name;
}
