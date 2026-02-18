package com.gmao.backend.repository;

import com.gmao.backend.entity.Batiment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface BatimentRepository extends JpaRepository<Batiment, Long> {
}
