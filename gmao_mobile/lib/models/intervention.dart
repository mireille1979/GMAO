import 'batiment.dart';
import 'equipement.dart';
import 'user.dart';
import 'checklist.dart';

enum Priorite { BASSE, MOYENNE, URGENTE }
enum Statut { EN_ATTENTE, PLANIFIEE, EN_COURS, TERMINEE, ANNULEE }

class Intervention {
  final int id;
  final String titre;
  final String description;
  final Priorite priorite;
  final Statut statut;
  final DateTime? datePrevue;
  final DateTime? dateFinReelle;
  final String? compteRendu;
  final double? cout;
  final Equipement? equipement;
  final Batiment? batiment;
  final User? technicien;
  final User? manager;
  final User? client;
  final DateTime? dateCreation;
  final List<Checklist>? checklist;

  Intervention({
    required this.id,
    required this.titre,
    required this.description,
    required this.priorite,
    required this.statut,
    this.datePrevue,
    this.dateFinReelle,
    this.compteRendu,
    this.cout,
    this.equipement,
    this.batiment,
    this.technicien,
    this.manager,
    this.client,
    this.dateCreation,
    this.checklist,
  });

  factory Intervention.fromJson(Map<String, dynamic> json) {
    return Intervention(
      id: json['id'],
      titre: json['titre'],
      description: json['description'],
      priorite: Priorite.values.firstWhere((e) => e.toString().split('.').last == json['priorite'], orElse: () => Priorite.MOYENNE),
      statut: Statut.values.firstWhere((e) => e.toString().split('.').last == json['statut'], orElse: () => Statut.PLANIFIEE),
      datePrevue: json['datePrevue'] != null ? DateTime.parse(json['datePrevue']) : null,
      dateFinReelle: json['dateFinReelle'] != null ? DateTime.parse(json['dateFinReelle']) : null,
      compteRendu: json['compteRendu'],
      cout: json['cout'] != null ? (json['cout'] as num).toDouble() : null,
      equipement: json['equipement'] != null ? Equipement.fromJson(json['equipement']) : null,
      batiment: json['batiment'] != null ? Batiment.fromJson(json['batiment']) : null,
      technicien: json['technicien'] != null ? User.fromJson(json['technicien']) : null,
      manager: json['manager'] != null ? User.fromJson(json['manager']) : null,
      client: json['client'] != null ? User.fromJson(json['client']) : null,
      dateCreation: json['dateCreation'] != null ? DateTime.parse(json['dateCreation']) : null,
      checklist: json['checklist'] != null
          ? (json['checklist'] as List).map((i) => Checklist.fromJson(i)).toList()
          : [],
    );
  }
}
