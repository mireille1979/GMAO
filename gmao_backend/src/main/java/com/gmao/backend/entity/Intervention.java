package com.gmao.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "interventions")
public class Intervention {

        @Id
        @GeneratedValue(strategy = GenerationType.IDENTITY)
        private Long id;

        private String titre;
        private String description;

        @Enumerated(EnumType.STRING)
        private Priorite priorite;

        @Enumerated(EnumType.STRING)
        private Statut statut;

        private LocalDateTime datePrevue;
        private LocalDateTime dateFinReelle;

        @Column(columnDefinition = "TEXT")
        private String compteRendu;

        private Double cout;

        @ManyToOne(fetch = FetchType.LAZY)
        @JoinColumn(name = "equipement_id")
        @com.fasterxml.jackson.annotation.JsonIgnoreProperties({ "hibernateLazyInitializer", "handler" })
        private Equipement equipement;

        @ManyToOne(fetch = FetchType.LAZY)
        @JoinColumn(name = "batiment_id")
        @com.fasterxml.jackson.annotation.JsonIgnoreProperties({ "equipements", "hibernateLazyInitializer", "handler" })
        private Batiment batiment;

        @ManyToOne(fetch = FetchType.LAZY)
        @JoinColumn(name = "technicien_id")
        @com.fasterxml.jackson.annotation.JsonIgnoreProperties({ "hibernateLazyInitializer", "handler", "equipe",
                        "poste",
                        "password", "authorities", "notificationPreferences" })
        private User technicien;

        @ManyToOne(fetch = FetchType.LAZY)
        @JoinColumn(name = "manager_id")
        @com.fasterxml.jackson.annotation.JsonIgnoreProperties({ "hibernateLazyInitializer", "handler", "equipe",
                        "poste",
                        "password", "authorities", "notificationPreferences" })
        private User manager;

        @ManyToOne(fetch = FetchType.LAZY)
        @JoinColumn(name = "client_id")
        @com.fasterxml.jackson.annotation.JsonIgnoreProperties({ "hibernateLazyInitializer", "handler", "equipe",
                        "poste",
                        "password", "authorities", "notificationPreferences" })
        private User client;

        private LocalDateTime dateCreation;

        @OneToMany(mappedBy = "intervention", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.EAGER)
        private java.util.List<Checklist> checklist;
}
