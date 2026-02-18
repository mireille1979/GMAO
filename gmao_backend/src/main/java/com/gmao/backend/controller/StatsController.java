package com.gmao.backend.controller;

import com.gmao.backend.dto.DashboardStatsResponse;
import com.gmao.backend.entity.Priorite;
import com.gmao.backend.entity.Statut;
import com.gmao.backend.repository.InterventionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/stats")
@RequiredArgsConstructor
public class StatsController {

    private final InterventionRepository repository;

    @GetMapping("/kpis")
    public ResponseEntity<DashboardStatsResponse> getKpis() {
        long total = repository.count();
        long finished = repository.countByStatut(Statut.TERMINEE);
        long urgentActive = repository.countByPrioriteAndStatutNot(Priorite.URGENTE, Statut.TERMINEE);
        long enCours = repository.countByStatut(Statut.EN_COURS);
        long planifiee = repository.countByStatut(Statut.PLANIFIEE);
        long enAttente = repository.countByStatut(Statut.EN_ATTENTE);
        long annulee = repository.countByStatut(Statut.ANNULEE);
        long pending = total - finished - annulee;

        Double totalCost = repository.sumCoutByStatut(Statut.TERMINEE);
        double tauxResolution = total > 0 ? (double) finished / total * 100.0 : 0.0;

        return ResponseEntity.ok(DashboardStatsResponse.builder()
                .totalInterventions(total)
                .finishedCount(finished)
                .activeUrgentCount(urgentActive)
                .pendingCount(pending)
                .totalCost(totalCost != null ? totalCost : 0.0)
                .enCoursCount(enCours)
                .planifieeCount(planifiee)
                .enAttenteCount(enAttente)
                .annuleeCount(annulee)
                .tauxResolution(Math.round(tauxResolution * 10.0) / 10.0)
                .build());
    }
}
