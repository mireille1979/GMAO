package com.gmao.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import com.fasterxml.jackson.annotation.JsonIgnore;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "zones")
public class Zone {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String nom;

    @Enumerated(EnumType.STRING)
    private TypeZone type;

    @ManyToOne
    @JoinColumn(name = "batiment_id", nullable = false)
    @JsonIgnore
    private Batiment batiment;

    public enum TypeZone {
        ETAGE,
        SALLE,
        COULOIR,
        AUTRE
    }
}
