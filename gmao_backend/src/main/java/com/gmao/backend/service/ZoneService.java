package com.gmao.backend.service;

import com.gmao.backend.entity.Batiment;
import com.gmao.backend.entity.Zone;
import com.gmao.backend.repository.BatimentRepository;
import com.gmao.backend.repository.ZoneRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ZoneService {

    private final ZoneRepository repository;
    private final BatimentRepository batimentRepository;

    public Zone create(Long batimentId, Zone zone) {
        Batiment batiment = batimentRepository.findById(batimentId)
                .orElseThrow(() -> new RuntimeException("Batiment not found"));
        zone.setBatiment(batiment);
        return repository.save(zone);
    }

    public List<Zone> findAllByBatiment(Long batimentId) {
        return repository.findByBatimentId(batimentId);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
}
