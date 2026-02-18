import 'poste.dart';
import 'equipe.dart';

enum Role { ADMIN, MANAGER, TECH, CLIENT }

class User {
  final int? id;
  final String email;
  final String firstName;
  final String lastName;
  final Role role;
  final bool isActive;
  final String? token;
  final Poste? poste;
  final Equipe? equipe;
  final String? telephone;
  final String? specialite;
  final bool disponible;

  User({
    this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.isActive = false,
    this.token,
    this.poste,
    this.equipe,
    this.telephone,
    this.specialite,
    this.disponible = true,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      isActive: json['active'] ?? json['isActive'] ?? false,
      role: json['role'] != null 
          ? Role.values.firstWhere((e) => e.toString().split('.').last == json['role'], orElse: () => Role.CLIENT)
          : Role.CLIENT,
      token: json['token'],
      poste: json['poste'] != null ? Poste.fromJson(json['poste']) : null,
      equipe: json['equipe'] != null ? Equipe.fromJson(json['equipe']) : null,
      telephone: json['telephone'],
      specialite: json['specialite'],
      disponible: json['disponible'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role.toString().split('.').last,
      'token': token,
      'poste': poste?.toJson(),
      'equipe': equipe?.toJson(),
      'telephone': telephone,
      'specialite': specialite,
      'disponible': disponible,
    };
  }
}
