package com.automarket.listing.repository;

import com.automarket.listing.entity.UserView;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface UserViewRepository extends JpaRepository<UserView, UUID> {

    Optional<UserView> findByEmail(String email);
}
