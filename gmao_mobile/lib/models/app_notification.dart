enum TypeNotification { INFO, ALERTE, URGENCE }

class AppNotification {
  final int id;
  final String message;
  final TypeNotification type;
  final bool lu;
  final DateTime dateCreation;

  AppNotification({
    required this.id,
    required this.message,
    required this.type,
    required this.lu,
    required this.dateCreation,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      message: json['message'] ?? '',
      type: TypeNotification.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => TypeNotification.INFO,
      ),
      lu: json['lu'] ?? false,
      dateCreation: json['dateCreation'] != null
          ? DateTime.parse(json['dateCreation'])
          : DateTime.now(),
    );
  }
}
