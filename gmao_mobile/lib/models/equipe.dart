import 'user.dart';

class Equipe {
  final int id;
  final String nom;
  final String? description;
  final User? chef;
  final List<User>? membres;

  Equipe({
    required this.id,
    required this.nom,
    this.description,
    this.chef,
    this.membres,
  });

  factory Equipe.fromJson(Map<String, dynamic> json) {
    return Equipe(
      id: json['id'],
      nom: json['nom'],
      description: json['description'],
      chef: json['chef'] != null ? User.fromJson(json['chef']) : null,
      membres: json['membres'] != null
          ? (json['membres'] as List).map((e) => User.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'chef': chef != null ? {'id': chef!.id} : null,
      'membres': membres?.map((e) => e.toJson()).toList(),
    };
  }
}
