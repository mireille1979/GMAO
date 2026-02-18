class Poste {
  final int id;
  final String titre;
  final String? description;

  Poste({
    required this.id,
    required this.titre,
    this.description,
  });

  factory Poste.fromJson(Map<String, dynamic> json) {
    return Poste(
      id: json['id'],
      titre: json['titre'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
    };
  }
}
