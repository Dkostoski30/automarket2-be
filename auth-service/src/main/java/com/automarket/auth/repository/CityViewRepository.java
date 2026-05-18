package com.automarket.auth.repository;

import com.automarket.auth.entity.CityView;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface CityViewRepository extends JpaRepository<CityView, UUID> {
}
