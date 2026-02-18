class BatimentMaintenanceStats {
  final int batimentId;
  final String batimentName;
  final int activeInterventionCount;
  final int criticalPriorityCount;
  final String status; // SAFE, WARNING, CRITICAL

  BatimentMaintenanceStats({
    required this.batimentId,
    required this.batimentName,
    required this.activeInterventionCount,
    required this.criticalPriorityCount,
    required this.status,
  });

  factory BatimentMaintenanceStats.fromJson(Map<String, dynamic> json) {
    return BatimentMaintenanceStats(
      batimentId: json['batimentId'],
      batimentName: json['batimentName'] ?? 'Inconnu',
      activeInterventionCount: json['activeInterventionCount'] ?? 0,
      criticalPriorityCount: json['criticalPriorityCount'] ?? 0,
      status: json['status'] ?? 'SAFE',
    );
  }
}
