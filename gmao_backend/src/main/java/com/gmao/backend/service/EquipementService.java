package com.gmao.backend.service;

import com.gmao.backend.entity.Equipement;
import com.gmao.backend.repository.EquipementRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class EquipementService {

    private final EquipementRepository repository;
    private final com.gmao.backend.repository.InterventionRepository interventionRepository;

    public void delete(Long id) {
        List<com.gmao.backend.entity.Intervention> interventions = interventionRepository.findByEquipementId(id);
        for (com.gmao.backend.entity.Intervention intervention : interventions) {
            intervention.setEquipement(null);
            interventionRepository.save(intervention);
        }
        repository.deleteById(id);
    }

    public Equipement save(Equipement equipement) {
        return repository.save(equipement);
    }

    public Equipement update(Long id, Equipement equipementDetails) {
        Equipement equipement = findById(id);
        equipement.setNom(equipementDetails.getNom());
        equipement.setType(equipementDetails.getType());
        equipement.setEtat(equipementDetails.getEtat());
        equipement.setBatiment(equipementDetails.getBatiment());
        equipement.setZone(equipementDetails.getZone());
        return repository.save(equipement);
    }

    public List<Equipement> findAll() {
        return repository.findAll();
    }

    public List<Equipement> findByBatiment(Long batimentId) {
        return repository.findByBatimentId(batimentId);
    }

    public Equipement findById(Long id) {
        return repository.findById(id).orElseThrow(() -> new RuntimeException("Equipement not found"));
    }
}
