package com.gmao.backend.controller;

import com.gmao.backend.entity.*;
import com.gmao.backend.repository.UserRepository;
import com.gmao.backend.service.InterventionService;
import com.gmao.backend.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/demandes")
@RequiredArgsConstructor
public class DemandeController {

    private final InterventionService service;
    private final NotificationService notificationService;
    private final UserRepository userRepository;

    /**
     * Client crée une demande d'intervention (statut = EN_ATTENTE)
     */
    @PostMapping
    public ResponseEntity<Intervention> createDemande(
            @AuthenticationPrincipal User client,
            @RequestBody Intervention demande) {
        demande.setClient(client);
        demande.setStatut(Statut.EN_ATTENTE);
        demande.setDateCreation(LocalDateTime.now());
        Intervention saved = service.save(demande);

        // Notify client that demand was received
        notificationService.create(client,
                "Votre demande \"" + saved.getTitre() + "\" a été enregistrée.",
                TypeNotification.INFO);

        // Notify all managers about the new demand
        List<User> managers = userRepository.findByRole(Role.MANAGER);
        for (User manager : managers) {
            notificationService.create(manager,
                    "Nouvelle demande de " + client.getFirstName() + " : \"" + saved.getTitre() + "\"",
                    TypeNotification.ALERTE);
        }

        return ResponseEntity.ok(saved);
    }

    /**
     * Client récupère ses propres demandes
     */
    @GetMapping("/mes-demandes")
    public ResponseEntity<List<Intervention>> getMesDemandes(@AuthenticationPrincipal User client) {
        return ResponseEntity.ok(service.findByClient(client.getId()));
    }

    /**
     * Manager/Admin liste toutes les demandes (EN_ATTENTE ou toutes)
     */
    @GetMapping
    public ResponseEntity<List<Intervention>> getAllDemandes(
            @RequestParam(required = false, defaultValue = "false") boolean enAttenteOnly) {
        if (enAttenteOnly) {
            return ResponseEntity.ok(service.findPending());
        }
        return ResponseEntity.ok(service.findAll());
    }

    /**
     * Manager accepte une demande → statut PLANIFIEE, assigne technicien
     */
    @PutMapping("/{id}/accepter")
    public ResponseEntity<Intervention> accepterDemande(
            @PathVariable Long id,
            @RequestBody Map<String, Object> body) {
        Long technicienId = body.get("technicienId") != null
                ? Long.valueOf(body.get("technicienId").toString())
                : null;
        LocalDateTime datePrevue = body.get("datePrevue") != null
                ? LocalDateTime.parse(body.get("datePrevue").toString())
                : null;
        Intervention result = service.accepterDemande(id, technicienId, datePrevue);

        // Notify client that demand was accepted
        if (result.getClient() != null) {
            notificationService.create(result.getClient(),
                    "Votre demande \"" + result.getTitre() + "\" a été acceptée et planifiée.",
                    TypeNotification.INFO);
        }

        return ResponseEntity.ok(result);
    }

    /**
     * Manager refuse une demande → statut ANNULEE
     */
    @PutMapping("/{id}/refuser")
    public ResponseEntity<Intervention> refuserDemande(@PathVariable Long id) {
        Intervention result = service.refuserDemande(id);

        // Notify client that demand was refused
        if (result.getClient() != null) {
            notificationService.create(result.getClient(),
                    "Votre demande \"" + result.getTitre() + "\" a été refusée.",
                    TypeNotification.ALERTE);
        }

        return ResponseEntity.ok(result);
    }
}
