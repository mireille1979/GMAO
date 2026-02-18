package com.gmao.backend.service;

import com.gmao.backend.entity.Intervention;
import com.gmao.backend.entity.Statut;
import com.gmao.backend.repository.InterventionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class InterventionService {

    private final InterventionRepository repository;
    private final com.gmao.backend.repository.ChecklistRepository checklistRepository;

    public com.gmao.backend.entity.Checklist addChecklistItem(Long interventionId, String description) {
        Intervention intervention = findById(interventionId);
        com.gmao.backend.entity.Checklist item = com.gmao.backend.entity.Checklist.builder()
                .description(description)
                .isChecked(false)
                .intervention(intervention)
                .build();
        return checklistRepository.save(item);
    }

    public com.gmao.backend.entity.Checklist toggleChecklistItem(Long itemId) {
        com.gmao.backend.entity.Checklist item = checklistRepository.findById(itemId)
                .orElseThrow(() -> new RuntimeException("Checklist item not found"));
        item.setChecked(!item.isChecked());
        return checklistRepository.save(item);
    }

    public Intervention save(Intervention intervention) {
        if (intervention.getStatut() == null) {
            intervention.setStatut(Statut.PLANIFIEE);
        }
        if (intervention.getChecklist() != null) {
            for (com.gmao.backend.entity.Checklist item : intervention.getChecklist()) {
                item.setIntervention(intervention);
            }
        }
        Intervention saved = repository.save(intervention);
        // Reload to get fully populated relationships (technician names, etc.)
        return repository.findById(saved.getId()).orElse(saved);
    }

    @Transactional(readOnly = true)
    public List<Intervention> findAll() {
        return repository.findAll();
    }

    @Transactional(readOnly = true)
    public List<Intervention> findByTechnicien(Long id) {
        return repository.findByTechnicienId(id);
    }

    public List<Intervention> findByEquipement(Long id) {
        return repository.findByEquipementId(id);
    }

    public List<Intervention> findByManager(Long managerId) {
        return repository.findByManagerId(managerId);
    }

    @Transactional(readOnly = true)
    public Intervention findById(Long id) {
        return repository.findById(id).orElseThrow(() -> new RuntimeException("Intervention not found"));
    }

    public Intervention demarrerIntervention(Long id) {
        Intervention intervention = findById(id);
        intervention.setStatut(Statut.EN_COURS);
        return repository.save(intervention);
    }

    public Intervention cloturerIntervention(Long id, String rapport, Double cout) {
        Intervention intervention = findById(id);
        intervention.setStatut(Statut.TERMINEE);
        intervention.setCompteRendu(rapport);
        intervention.setCout(cout);
        intervention.setDateFinReelle(LocalDateTime.now());
        return repository.save(intervention);
    }

    @Transactional(readOnly = true)
    public List<Intervention> getPlanning(LocalDateTime start, LocalDateTime end, Long technicienId) {
        if (technicienId != null) {
            return repository.findByTechnicienIdAndDatePrevueBetween(technicienId, start, end);
        }
        return repository.findByDatePrevueBetween(start, end);
    }

    // --- Demandes ---

    @Transactional(readOnly = true)
    public List<Intervention> findByClient(Long clientId) {
        return repository.findByClientId(clientId);
    }

    @Transactional(readOnly = true)
    public List<Intervention> findPending() {
        return repository.findByStatut(Statut.EN_ATTENTE);
    }

    public Intervention accepterDemande(Long id, Long technicienId, LocalDateTime datePrevue) {
        Intervention demande = findById(id);
        demande.setStatut(Statut.PLANIFIEE);
        if (technicienId != null) {
            com.gmao.backend.entity.User tech = new com.gmao.backend.entity.User();
            tech.setId(technicienId);
            demande.setTechnicien(tech);
        }
        if (datePrevue != null) {
            demande.setDatePrevue(datePrevue);
        }
        return repository.save(demande);
    }

    public Intervention refuserDemande(Long id) {
        Intervention demande = findById(id);
        demande.setStatut(Statut.ANNULEE);
        return repository.save(demande);
    }
}
