package com.gmao.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ClotureInterventionRequest {
    private String compteRendu;
    private Double cout;
}
