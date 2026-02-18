class Zone {
  final int id;
  final String nom;
  final String type; // ETAGE, SALLE, COULOIR, AUTRE
  final int batimentId;

  Zone({
    required this.id,
    required this.nom,
    required this.type,
    required this.batimentId,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'],
      nom: json['nom'] ?? 'Sans nom',
      type: json['type'] ?? 'AUTRE',
      batimentId: json['batiment'] != null ? json['batiment']['id'] : 0,
    );
  }
}
