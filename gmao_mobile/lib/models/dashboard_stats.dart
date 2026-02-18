class DashboardStats {
  final int totalInterventions;
  final int activeUrgentCount;
  final int finishedCount;
  final int pendingCount;
  final double totalCost;
  final int enCoursCount;
  final int planifieeCount;
  final int enAttenteCount;
  final int annuleeCount;
  final double tauxResolution;

  DashboardStats({
    required this.totalInterventions,
    required this.activeUrgentCount,
    required this.finishedCount,
    required this.pendingCount,
    required this.totalCost,
    this.enCoursCount = 0,
    this.planifieeCount = 0,
    this.enAttenteCount = 0,
    this.annuleeCount = 0,
    this.tauxResolution = 0.0,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalInterventions: json['totalInterventions'] ?? 0,
      activeUrgentCount: json['activeUrgentCount'] ?? 0,
      finishedCount: json['finishedCount'] ?? 0,
      pendingCount: json['pendingCount'] ?? 0,
      totalCost: json['totalCost'] != null ? (json['totalCost'] as num).toDouble() : 0.0,
      enCoursCount: json['enCoursCount'] ?? 0,
      planifieeCount: json['planifieeCount'] ?? 0,
      enAttenteCount: json['enAttenteCount'] ?? 0,
      annuleeCount: json['annuleeCount'] ?? 0,
      tauxResolution: json['tauxResolution'] != null ? (json['tauxResolution'] as num).toDouble() : 0.0,
    );
  }
}
