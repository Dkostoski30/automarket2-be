package com.automarket.listing.repository;

import com.automarket.listing.entity.TransmissionType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface TransmissionTypeRepository extends JpaRepository<TransmissionType, UUID> {
    List<TransmissionType> findAllByOrderByNameAsc();
}
