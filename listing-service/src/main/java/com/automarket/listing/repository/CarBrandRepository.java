package com.automarket.listing.repository;

import com.automarket.listing.entity.CarBrand;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface CarBrandRepository extends JpaRepository<CarBrand, UUID> {
}
