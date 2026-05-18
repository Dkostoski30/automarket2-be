package com.automarket.payment.repository;

import com.automarket.payment.entity.UserView;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface UserViewRepository extends JpaRepository<UserView, UUID> {
    Optional<UserView> findByEmail(String email);
}
