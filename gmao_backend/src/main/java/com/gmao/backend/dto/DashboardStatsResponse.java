package com.gmao.backend.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class DashboardStatsResponse {
    private long totalInterventions;
    private long activeUrgentCount;
    private long finishedCount;
    private long pendingCount;
    private Double totalCost;
    private long enCoursCount;
    private long planifieeCount;
    private long enAttenteCount;
    private long annuleeCount;
    private double tauxResolution;
}
