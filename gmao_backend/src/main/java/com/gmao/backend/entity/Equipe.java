package com.gmao.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "equipes")
@com.fasterxml.jackson.annotation.JsonIgnoreProperties({ "hibernateLazyInitializer", "handler" })
public class Equipe {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String nom;

    private String description;

    @OneToMany(mappedBy = "equipe")
    @com.fasterxml.jackson.annotation.JsonIgnoreProperties({ "equipe", "password", "role", "authorities",
            "notificationPreferences", "hibernateLazyInitializer", "handler" })
    private List<User> membres;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "chef_id")
    @com.fasterxml.jackson.annotation.JsonIgnoreProperties({ "equipe", "password", "role", "authorities",
            "notificationPreferences", "hibernateLazyInitializer", "handler" })
    private User chef;
}
