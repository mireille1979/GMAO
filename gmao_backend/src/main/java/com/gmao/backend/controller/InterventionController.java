package com.gmao.backend.controller;

import com.gmao.backend.dto.ClotureInterventionRequest;

import com.gmao.backend.entity.Intervention;
import com.gmao.backend.entity.Statut;
import com.gmao.backend.service.InterventionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/interventions")
@RequiredArgsConstructor
public class InterventionController {

    private final InterventionService service;

    @PostMapping
    public ResponseEntity<Intervention> create(@RequestBody Intervention intervention) {
        return ResponseEntity.ok(service.save(intervention));
    }

    @GetMapping
    public ResponseEntity<List<Intervention>> getAll(@RequestParam(required = false) Long equipementId) {
        if (equipementId != null) {
            return ResponseEntity.ok(service.findByEquipement(equipementId));
        }
        return ResponseEntity.ok(service.findAll());
    }

    @GetMapping("/planning")
    public ResponseEntity<List<Intervention>> getPlanning(
            @RequestParam @org.springframework.format.annotation.DateTimeFormat(iso = org.springframework.format.annotation.DateTimeFormat.ISO.DATE_TIME) java.time.LocalDateTime start,
            @RequestParam @org.springframework.format.annotation.DateTimeFormat(iso = org.springframework.format.annotation.DateTimeFormat.ISO.DATE_TIME) java.time.LocalDateTime end,
            @RequestParam(required = false) Long technicienId) {
        return ResponseEntity.ok(service.getPlanning(start, end, technicienId));
    }

    @GetMapping("/technicien/{id}")
    public ResponseEntity<List<Intervention>> getByTechnicien(@PathVariable Long id) {
        return ResponseEntity.ok(service.findByTechnicien(id));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Intervention> getById(@PathVariable Long id) {
        return ResponseEntity.ok(service.findById(id));
    }

    @PatchMapping("/{id}/demarrer")
    public ResponseEntity<Intervention> startIntervention(@PathVariable Long id) {
        return ResponseEntity.ok(service.demarrerIntervention(id));
    }

    @PatchMapping("/{id}/cloturer")
    public ResponseEntity<Intervention> finishIntervention(@PathVariable Long id,
            @RequestBody com.gmao.backend.dto.ClotureInterventionRequest request) {
        return ResponseEntity.ok(service.cloturerIntervention(id, request.getCompteRendu(), request.getCout()));
    }

    @PostMapping("/{id}/checklist")
    public ResponseEntity<com.gmao.backend.entity.Checklist> addChecklistItem(@PathVariable Long id,
            @RequestBody Map<String, String> payload) {
        return ResponseEntity.ok(service.addChecklistItem(id, payload.get("description")));
    }

    @PatchMapping("/checklist/{itemId}")
    public ResponseEntity<com.gmao.backend.entity.Checklist> toggleChecklistItem(@PathVariable Long itemId) {
        return ResponseEntity.ok(service.toggleChecklistItem(itemId));
    }
}
