package com.gmao.backend.service;

import com.gmao.backend.entity.Poste;
import com.gmao.backend.repository.PosteRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class PosteService {

    private final PosteRepository repository;

    public List<Poste> findAll() {
        return repository.findAll();
    }

    public Poste findById(Long id) {
        return repository.findById(id).orElseThrow(() -> new RuntimeException("Poste non trouvé"));
    }

    public Poste save(Poste poste) {
        return repository.save(poste);
    }

    public Poste update(Long id, Poste poste) {
        Poste existing = findById(id);
        existing.setTitre(poste.getTitre());
        existing.setDescription(poste.getDescription());
        return repository.save(existing);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
}
