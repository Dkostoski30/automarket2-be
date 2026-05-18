package com.automarket.listing.repository;

import com.automarket.listing.entity.CityView;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface CityViewRepository extends JpaRepository<CityView, UUID> {
}
