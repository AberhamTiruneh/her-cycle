import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phoneNumber;
  final DateTime? dateOfBirth;
  final String language;
  final String themeMode;
  final bool notificationsEnabled;
  final bool smsAlertsEnabled;
  final int reminderDaysBefore;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.dateOfBirth,
    this.language = 'en',
    this.themeMode = 'light',
    this.notificationsEnabled = true,
    this.smsAlertsEnabled = false,
    this.reminderDaysBefore = 3,
    required this.createdAt,
  });

  // ─── Firestore Serialization ────────────────────────────────────────────

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth != null
          ? Timestamp.fromDate(dateOfBirth!)
          : null,
      'language': language,
      'themeMode': themeMode,
      'notificationsEnabled': notificationsEnabled,
      'smsAlertsEnabled': smsAlertsEnabled,
      'reminderDaysBefore': reminderDaysBefore,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] as String,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate(),
      language: data['language'] as String? ?? 'en',
      themeMode: data['themeMode'] as String? ?? 'light',
      notificationsEnabled: data['notificationsEnabled'] as bool? ?? true,
      smsAlertsEnabled: data['smsAlertsEnabled'] as bool? ?? false,
      reminderDaysBefore: data['reminderDaysBefore'] as int? ?? 3,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  UserModel copyWith({
    String? name,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? language,
    String? themeMode,
    bool? notificationsEnabled,
    bool? smsAlertsEnabled,
    int? reminderDaysBefore,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      smsAlertsEnabled: smsAlertsEnabled ?? this.smsAlertsEnabled,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      createdAt: createdAt,
    );
  }
}
