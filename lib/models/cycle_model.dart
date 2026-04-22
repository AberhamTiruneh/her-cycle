class CycleData {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final int duration;
  final List<String> symptoms;
  final String notes;
  final String? flowIntensity; // light, normal, heavy
  final List<String>? moods;

  CycleData({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.duration,
    required this.symptoms,
    required this.notes,
    this.flowIntensity,
    this.moods,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'duration': duration,
      'symptoms': symptoms,
      'notes': notes,
      'flowIntensity': flowIntensity,
      'moods': moods,
    };
  }

  // Create from JSON
  factory CycleData.fromJson(Map<String, dynamic> json) {
    return CycleData(
      id: json['id'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      duration: json['duration'],
      symptoms: List<String>.from(json['symptoms'] ?? []),
      notes: json['notes'] ?? '',
      flowIntensity: json['flowIntensity'],
      moods: json['moods'] != null ? List<String>.from(json['moods']) : null,
    );
  }
}
