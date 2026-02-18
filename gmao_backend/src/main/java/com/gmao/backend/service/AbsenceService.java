package com.gmao.backend.service;

import com.gmao.backend.entity.Absence;
import com.gmao.backend.entity.StatutAbsence;
import com.gmao.backend.repository.AbsenceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class AbsenceService {

    private final AbsenceRepository repository;

    @Transactional(readOnly = true)
    public List<Absence> findAll() {
        return repository.findAll();
    }

    @Transactional(readOnly = true)
    public List<Absence> findByUserId(Long userId) {
        return repository.findByUserId(userId);
    }

    @Transactional(readOnly = true)
    public List<Absence> findByEquipeId(Long equipeId) {
        return repository.findByUserEquipeId(equipeId);
    }

    @Transactional(readOnly = true)
    public Absence findById(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Absence non trouvée"));
    }

    public Absence save(Absence absence) {
        return repository.save(absence);
    }

    @Transactional
    public Absence updateStatut(Long id, StatutAbsence statut) {
        Absence absence = findById(id);
        absence.setStatut(statut);
        return repository.save(absence);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
}
