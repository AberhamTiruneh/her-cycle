class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type; // period_reminder, ovulation_reminder, symptom_reminder, etc.
  final DateTime scheduledTime;
  final bool isDelivered;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.scheduledTime,
    required this.isDelivered,
    required this.createdAt,
    this.data,
  });

  // Notification types
  static const String periodReminder = 'period_reminder';
  static const String ovulationReminder = 'ovulation_reminder';
  static const String fertileWindowReminder = 'fertile_window_reminder';
  static const String symptomReminder = 'symptom_reminder';
  static const String dailyCheckIn = 'daily_check_in';

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'scheduledTime': scheduledTime.toIso8601String(),
      'isDelivered': isDelivered,
      'createdAt': createdAt.toIso8601String(),
      'data': data,
    };
  }

  // Create from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      body: json['body'],
      type: json['type'],
      scheduledTime: DateTime.parse(json['scheduledTime']),
      isDelivered: json['isDelivered'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}
