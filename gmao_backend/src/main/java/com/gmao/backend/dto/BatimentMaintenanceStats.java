package com.gmao.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BatimentMaintenanceStats {
    private Long batimentId;
    private String batimentName;
    private long activeInterventionCount;
    private long criticalPriorityCount;
    private String status; // SAFE, WARNING, CRITICAL
}
