package com.automarket.listing.repository;

import com.automarket.listing.entity.BodyType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface BodyTypeRepository extends JpaRepository<BodyType, UUID> {
    List<BodyType> findAllByOrderByNameAsc();
}
