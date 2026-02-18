import 'user.dart';

enum StatutAbsence { EN_ATTENTE, APPROUVEE, REFUSEE }

class Absence {
  final int? id;
  final User? user;
  final String dateDebut;
  final String dateFin;
  final String motif;
  final StatutAbsence statut;
  final String? createdAt;

  Absence({
    this.id,
    this.user,
    required this.dateDebut,
    required this.dateFin,
    required this.motif,
    this.statut = StatutAbsence.EN_ATTENTE,
    this.createdAt,
  });

  factory Absence.fromJson(Map<String, dynamic> json) {
    return Absence(
      id: json['id'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      dateDebut: json['dateDebut'] ?? '',
      dateFin: json['dateFin'] ?? '',
      motif: json['motif'] ?? '',
      statut: StatutAbsence.values.firstWhere(
        (e) => e.toString().split('.').last == json['statut'],
        orElse: () => StatutAbsence.EN_ATTENTE,
      ),
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dateDebut': dateDebut,
      'dateFin': dateFin,
      'motif': motif,
      'statut': statut.toString().split('.').last,
    };
  }

  String get statutLabel {
    switch (statut) {
      case StatutAbsence.EN_ATTENTE:
        return 'En attente';
      case StatutAbsence.APPROUVEE:
        return 'Approuvée';
      case StatutAbsence.REFUSEE:
        return 'Refusée';
    }
  }
}
