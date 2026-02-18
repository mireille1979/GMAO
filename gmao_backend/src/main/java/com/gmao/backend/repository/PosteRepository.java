package com.gmao.backend.repository;

import com.gmao.backend.entity.Poste;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface PosteRepository extends JpaRepository<Poste, Long> {
    Optional<Poste> findByTitre(String titre);
}
