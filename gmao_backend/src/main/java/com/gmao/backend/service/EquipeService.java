package com.gmao.backend.service;

import com.gmao.backend.entity.Equipe;
import com.gmao.backend.entity.User;
import com.gmao.backend.repository.EquipeRepository;
import com.gmao.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class EquipeService {

    private final EquipeRepository repository;
    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public List<Equipe> findAll() {
        return repository.findAll();
    }

    @Transactional(readOnly = true)
    public Equipe findById(Long id) {
        return repository.findById(id).orElseThrow(() -> new RuntimeException("Equipe non trouvée"));
    }

    public Equipe save(Equipe equipe) {
        return repository.save(equipe);
    }

    @Transactional
    public Equipe update(Long id, Equipe equipe) {
        Equipe existing = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Equipe non trouvée"));
        existing.setNom(equipe.getNom());
        existing.setDescription(equipe.getDescription());
        // Resolve chef from DB by ID if provided
        if (equipe.getChef() != null && equipe.getChef().getId() != null) {
            User chef = userRepository.findById(equipe.getChef().getId())
                    .orElseThrow(() -> new RuntimeException("Chef non trouvé"));
            existing.setChef(chef);
        }
        return repository.save(existing);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
}
