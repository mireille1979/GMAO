package com.gmao.backend.controller;

import com.gmao.backend.entity.Batiment;
import com.gmao.backend.service.BatimentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/batiments")
@RequiredArgsConstructor
public class BatimentController {

    private final BatimentService service;

    @PostMapping
    public ResponseEntity<Batiment> create(@RequestBody Batiment batiment) {
        return ResponseEntity.ok(service.save(batiment));
    }

    @GetMapping
    public ResponseEntity<List<Batiment>> getAll() {
        return ResponseEntity.ok(service.findAll());
    }

    @GetMapping("/maintenance-stats")
    public ResponseEntity<List<com.gmao.backend.dto.BatimentMaintenanceStats>> getMaintenanceStats() {
        return ResponseEntity.ok(service.getMaintenanceStats());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Batiment> getById(@PathVariable Long id) {
        return ResponseEntity.ok(service.findById(id));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Batiment> update(@PathVariable Long id, @RequestBody Batiment batiment) {
        return ResponseEntity.ok(service.update(id, batiment));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
