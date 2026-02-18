package com.gmao.backend.controller;

import com.gmao.backend.entity.Absence;
import com.gmao.backend.entity.StatutAbsence;
import com.gmao.backend.entity.User;
import com.gmao.backend.service.AbsenceService;
import com.gmao.backend.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/absences")
@RequiredArgsConstructor
public class AbsenceController {

    private final AbsenceService absenceService;
    private final UserService userService;

    // Manager: get all absences
    @GetMapping
    public ResponseEntity<List<Absence>> getAll() {
        return ResponseEntity.ok(absenceService.findAll());
    }

    // Tech: get my absences
    @GetMapping("/me")
    public ResponseEntity<List<Absence>> getMyAbsences(Authentication authentication) {
        User user = userService.getConnectedUser(authentication);
        return ResponseEntity.ok(absenceService.findByUserId(user.getId()));
    }

    // Get absences by team
    @GetMapping("/equipe/{equipeId}")
    public ResponseEntity<List<Absence>> getByEquipe(@PathVariable Long equipeId) {
        return ResponseEntity.ok(absenceService.findByEquipeId(equipeId));
    }

    // Tech: create an absence request
    @PostMapping
    public ResponseEntity<Absence> create(@RequestBody Absence absence, Authentication authentication) {
        User user = userService.getConnectedUser(authentication);
        absence.setUser(user);
        absence.setStatut(StatutAbsence.EN_ATTENTE);
        return ResponseEntity.ok(absenceService.save(absence));
    }

    // Manager: approve or refuse
    @PutMapping("/{id}/statut")
    public ResponseEntity<Absence> updateStatut(
            @PathVariable Long id,
            @RequestBody Map<String, String> body) {
        StatutAbsence statut = StatutAbsence.valueOf(body.get("statut"));
        return ResponseEntity.ok(absenceService.updateStatut(id, statut));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        absenceService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
