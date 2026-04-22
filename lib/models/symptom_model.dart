class SymptomModel {
  final String id;
  final String cycleId;
  final String name;
  final String severity; // mild, moderate, severe
  final DateTime date;
  final String? description;
  final DateTime createdAt;

  SymptomModel({
    required this.id,
    required this.cycleId,
    required this.name,
    required this.severity,
    required this.date,
    this.description,
    required this.createdAt,
  });

  // Common symptoms
  static const List<String> commonSymptoms = [
    'Cramps',
    'Bloating',
    'Fatigue',
    'Headache',
    'Mood Swings',
    'Breast Tenderness',
    'Acne',
    'Back Pain',
    'Nausea',
    'Food Cravings',
    'Joint Pain',
    'Anxiety',
    'Depression',
    'Insomnia',
    'Brain Fog',
  ];

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cycleId': cycleId,
      'name': name,
      'severity': severity,
      'date': date.toIso8601String(),
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory SymptomModel.fromJson(Map<String, dynamic> json) {
    return SymptomModel(
      id: json['id'],
      cycleId: json['cycleId'],
      name: json['name'],
      severity: json['severity'],
      date: DateTime.parse(json['date']),
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
