package com.automarket.reference.repository;

import com.automarket.reference.entity.BodyType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface BodyTypeRepository extends JpaRepository<BodyType, UUID> {
    List<BodyType> findAllByOrderByNameAsc();
}
