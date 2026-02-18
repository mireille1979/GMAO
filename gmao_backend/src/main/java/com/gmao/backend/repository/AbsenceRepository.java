package com.gmao.backend.repository;

import com.gmao.backend.entity.Absence;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface AbsenceRepository extends JpaRepository<Absence, Long> {
    List<Absence> findByUserId(Long userId);

    List<Absence> findByUserEquipeId(Long equipeId);
}
