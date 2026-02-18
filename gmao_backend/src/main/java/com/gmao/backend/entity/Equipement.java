package com.gmao.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "equipements")
public class Equipement {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String nom;

    @Enumerated(EnumType.STRING)
    private TypeEquipement type;

    @Enumerated(EnumType.STRING)
    private EtatEquipement etat;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "batiment_id")
    @com.fasterxml.jackson.annotation.JsonIgnoreProperties({ "equipements", "hibernateLazyInitializer", "handler" })
    private Batiment batiment;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "zone_id")
    @com.fasterxml.jackson.annotation.JsonIgnoreProperties({ "hibernateLazyInitializer", "handler" })
    private Zone zone;
}
