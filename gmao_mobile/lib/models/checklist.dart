class Checklist {
  final int id;
  final String description;
  final bool isChecked;
  final int interventionId;

  Checklist({
    required this.id,
    required this.description,
    required this.isChecked,
    required this.interventionId,
  });

  factory Checklist.fromJson(Map<String, dynamic> json) {
    return Checklist(
      id: json['id'],
      description: json['description'],
      isChecked: json['checked'] ?? false,
      interventionId: json['intervention']?['id'] ?? 0,
    );
  }

  Checklist copyWith({bool? isChecked}) {
    return Checklist(
      id: id,
      description: description,
      isChecked: isChecked ?? this.isChecked,
      interventionId: interventionId,
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'description': description,
      'checked': isChecked,
    };
    if (id != 0) {
      data['id'] = id;
    }
    return data;
  }
}
