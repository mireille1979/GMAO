import 'zone.dart';

class Batiment {
  final int id;
  final String nom;
  final String adresse;
  final String description;
  final List<Zone> zones;

  Batiment({
    required this.id,
    required this.nom,
    required this.adresse,
    required this.description,
    this.zones = const [],
  });

  factory Batiment.fromJson(Map<String, dynamic> json) {
    var list = json['zones'] as List? ?? [];
    List<Zone> zonesList = list.map((i) => Zone.fromJson(i)).toList();

    return Batiment(
      id: json['id'],
      nom: json['nom'] ?? 'Sans nom',
      adresse: json['adresse'] ?? '',
      description: json['description'] ?? '',
      zones: zonesList,
    );
  }
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Batiment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Batiment(id: $id, nom: $nom, zones: ${zones.length})';
}
