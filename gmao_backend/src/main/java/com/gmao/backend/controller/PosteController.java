package com.gmao.backend.controller;

import com.gmao.backend.entity.Poste;
import com.gmao.backend.service.PosteService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/postes")
@RequiredArgsConstructor
public class PosteController {

    private final PosteService service;

    @GetMapping
    public ResponseEntity<List<Poste>> getAll() {
        return ResponseEntity.ok(service.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Poste> getById(@PathVariable Long id) {
        return ResponseEntity.ok(service.findById(id));
    }

    @PostMapping
    public ResponseEntity<Poste> create(@RequestBody Poste poste) {
        return ResponseEntity.ok(service.save(poste));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Poste> update(@PathVariable Long id, @RequestBody Poste poste) {
        return ResponseEntity.ok(service.update(id, poste));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
