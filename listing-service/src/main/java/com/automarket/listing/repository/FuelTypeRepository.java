package com.automarket.listing.repository;

import com.automarket.listing.entity.FuelType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface FuelTypeRepository extends JpaRepository<FuelType, UUID> {
}
