package com.gmao.backend.service;

import com.gmao.backend.entity.Batiment;
import com.gmao.backend.repository.BatimentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class BatimentService {

    private final BatimentRepository repository;
    private final com.gmao.backend.repository.InterventionRepository interventionRepository;

    public java.util.List<com.gmao.backend.dto.BatimentMaintenanceStats> getMaintenanceStats() {
        List<Batiment> batiments = repository.findAll();
        return batiments.stream().map(batiment -> {
            long activeCount = interventionRepository.countByBatimentIdAndStatut(batiment.getId(),
                    com.gmao.backend.entity.Statut.EN_COURS)
                    + interventionRepository.countByBatimentIdAndStatut(batiment.getId(),
                            com.gmao.backend.entity.Statut.PLANIFIEE);

            long criticalCount = interventionRepository.countByBatimentIdAndPrioriteAndStatutNot(
                    batiment.getId(),
                    com.gmao.backend.entity.Priorite.URGENTE,
                    com.gmao.backend.entity.Statut.TERMINEE);

            String status = "SAFE";
            if (criticalCount > 0) {
                status = "CRITICAL";
            } else if (activeCount > 5) {
                status = "WARNING";
            }

            return com.gmao.backend.dto.BatimentMaintenanceStats.builder()
                    .batimentId(batiment.getId())
                    .batimentName(batiment.getNom())
                    .activeInterventionCount(activeCount)
                    .criticalPriorityCount(criticalCount)
                    .status(status)
                    .build();
        }).collect(java.util.stream.Collectors.toList());
    }

    public Batiment save(Batiment batiment) {
        return repository.save(batiment);
    }

    public List<Batiment> findAll() {
        return repository.findAll();
    }

    public Batiment findById(Long id) {
        return repository.findById(id).orElseThrow(() -> new RuntimeException("Batiment not found"));
    }

    public Batiment update(Long id, Batiment updatedBatiment) {
        Batiment existing = findById(id);
        existing.setNom(updatedBatiment.getNom());
        existing.setAdresse(updatedBatiment.getAdresse());
        return repository.save(existing);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
}
