package com.automarket.reference.repository;

import com.automarket.reference.entity.ConditionType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface ConditionTypeRepository extends JpaRepository<ConditionType, UUID> {
    List<ConditionType> findAllByOrderByNameAsc();
}
