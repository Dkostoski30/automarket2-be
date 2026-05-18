package com.automarket.inquiry.repository;

import com.automarket.inquiry.entity.ListingView;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface ListingViewRepository extends JpaRepository<ListingView, UUID> {
}
