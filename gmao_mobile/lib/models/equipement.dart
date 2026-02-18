import 'batiment.dart';

enum TypeEquipement { ELECTRIQUE, PLOMBERIE, CVC, ASCENSEUR, AUTRE }
enum EtatEquipement { FONCTIONNEL, EN_PANNE, EN_MAINTENANCE }

class Equipement {
  final int id;
  final String nom;
  final TypeEquipement type;
  final EtatEquipement etat;
  final Batiment? batiment;
  final int? zoneId;
  final String? zoneName;

  Equipement({
    required this.id,
    required this.nom,
    required this.type,
    required this.etat,
    this.batiment,
    this.zoneId,
    this.zoneName,
  });

  factory Equipement.fromJson(Map<String, dynamic> json) {
    return Equipement(
      id: json['id'],
      nom: json['nom'] ?? 'Sans nom',
      type: json['type'] != null 
          ? TypeEquipement.values.firstWhere((e) => e.toString().split('.').last == json['type'], orElse: () => TypeEquipement.AUTRE)
          : TypeEquipement.AUTRE,
      etat: json['etat'] != null
          ? EtatEquipement.values.firstWhere((e) => e.toString().split('.').last == json['etat'], orElse: () => EtatEquipement.FONCTIONNEL)
          : EtatEquipement.FONCTIONNEL,
      batiment: json['batiment'] != null ? Batiment.fromJson(json['batiment']) : null,
      zoneId: json['zone']?['id'],
      zoneName: json['zone']?['nom'],
    );
  }
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Equipement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Equipement(id: $id, nom: $nom)';
}
