package com.gmao.backend.repository;

import com.gmao.backend.entity.Intervention;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface InterventionRepository extends JpaRepository<Intervention, Long> {
        List<Intervention> findByTechnicienId(Long technicienId);

        List<Intervention> findByManagerId(Long managerId);

        List<Intervention> findByEquipementId(Long equipementId);

        long countByStatut(com.gmao.backend.entity.Statut statut);

        long countByPrioriteAndStatutNot(com.gmao.backend.entity.Priorite priorite,
                        com.gmao.backend.entity.Statut statut);

        @org.springframework.data.jpa.repository.Query("SELECT SUM(i.cout) FROM Intervention i WHERE i.statut = :statut")
        Double sumCoutByStatut(
                        @org.springframework.data.repository.query.Param("statut") com.gmao.backend.entity.Statut statut);

        long countByBatimentIdAndStatut(Long batimentId, com.gmao.backend.entity.Statut statut);

        long countByBatimentIdAndPrioriteAndStatutNot(Long batimentId, com.gmao.backend.entity.Priorite priorite,
                        com.gmao.backend.entity.Statut statut);

        List<Intervention> findByDatePrevueBetween(java.time.LocalDateTime start, java.time.LocalDateTime end);

        List<Intervention> findByTechnicienIdAndDatePrevueBetween(Long technicienId, java.time.LocalDateTime start,
                        java.time.LocalDateTime end);

        List<Intervention> findByClientId(Long clientId);

        List<Intervention> findByStatut(com.gmao.backend.entity.Statut statut);
}
