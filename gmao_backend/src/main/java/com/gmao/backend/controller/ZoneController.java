package com.gmao.backend.controller;

import com.gmao.backend.entity.Zone;
import com.gmao.backend.service.ZoneService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/zones")
@RequiredArgsConstructor
public class ZoneController {

    private final ZoneService service;

    @PostMapping("/batiment/{batimentId}")
    public ResponseEntity<Zone> create(@PathVariable Long batimentId, @RequestBody Zone zone) {
        return ResponseEntity.ok(service.create(batimentId, zone));
    }

    @GetMapping("/batiment/{batimentId}")
    public ResponseEntity<List<Zone>> getAllByBatiment(@PathVariable Long batimentId) {
        return ResponseEntity.ok(service.findAllByBatiment(batimentId));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
