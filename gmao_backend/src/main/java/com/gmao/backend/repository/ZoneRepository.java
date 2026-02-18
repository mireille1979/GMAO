package com.gmao.backend.repository;

import com.gmao.backend.entity.Zone;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ZoneRepository extends JpaRepository<Zone, Long> {
    List<Zone> findByBatimentId(Long batimentId);
}
