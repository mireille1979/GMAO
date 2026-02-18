package com.gmao.backend.controller;

import com.gmao.backend.entity.Intervention;
import com.gmao.backend.repository.InterventionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/export")
@RequiredArgsConstructor
public class ExportController {

    private final InterventionRepository interventionRepository;

    @GetMapping("/interventions/csv")
    public ResponseEntity<byte[]> exportInterventionsCsv() {
        List<Intervention> interventions = interventionRepository.findAll();

        StringBuilder sb = new StringBuilder();
        sb.append("ID;Titre;Description;Priorite;Statut;Date Prevue;Date Fin;Technicien;Batiment;Cout\n");

        for (Intervention i : interventions) {
            sb.append(i.getId()).append(";");
            sb.append(escape(i.getTitre())).append(";");
            sb.append(escape(i.getDescription())).append(";");
            sb.append(i.getPriorite()).append(";");
            sb.append(i.getStatut()).append(";");
            sb.append(i.getDatePrevue() != null ? i.getDatePrevue().toString() : "").append(";");
            sb.append(i.getDateFinReelle() != null ? i.getDateFinReelle().toString() : "").append(";");
            sb.append(
                    i.getTechnicien() != null ? i.getTechnicien().getFirstName() + " " + i.getTechnicien().getLastName()
                            : "")
                    .append(";");
            sb.append(i.getBatiment() != null ? i.getBatiment().getNom() : "").append(";");
            sb.append(i.getCout() != null ? i.getCout().toString() : "0");
            sb.append("\n");
        }

        byte[] csvBytes = sb.toString().getBytes(java.nio.charset.StandardCharsets.UTF_8);

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=interventions.csv")
                .contentType(MediaType.parseMediaType("text/csv; charset=UTF-8"))
                .body(csvBytes);
    }

    private String escape(String s) {
        if (s == null)
            return "";
        return s.replace(";", ",").replace("\n", " ");
    }
}
