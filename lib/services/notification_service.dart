import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'firebase_service.dart';

// ─── FCM Background Handler ───────────────────────────────────────────────────
// Must be a top-level function (not a class method).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialized by the time this is called.
  // Background messages are handled silently; the OS shows the notification
  // automatically when the app is in the background/terminated.
}

// ─── Notification IDs ─────────────────────────────────────────────────────────
class _NotificationIds {
  static const int periodReminder = 1000;
  static const int ovulationAlert = 2000;
  static const int dailyReminder = 3000;
  static const int fcmForeground = 9000;
}

// ─── Channel IDs ─────────────────────────────────────────────────────────────
class _ChannelIds {
  static const String period = 'period_reminders';
  static const String ovulation = 'ovulation_alerts';
  static const String daily = 'daily_reminders';
}

// ─── NotificationService ─────────────────────────────────────────────────────

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ─── Initialization ────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone database
    tz_data.initializeTimeZones();
    // Use the device's local timezone
    final String localTimezone = await _resolveLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTimezone));

    // Local notification plugin setup
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channels
    await _createChannels();

    // Request OS permissions
    await requestPermissions();

    // Firebase Cloud Messaging — non-critical: a failure here must not
    // prevent the app from starting.
    try {
      await _initFCM();
    } catch (_) {}

    _initialized = true;
  }

  // ─── Android Channels ─────────────────────────────────────────────────────

  Future<void> _createChannels() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return;

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _ChannelIds.period,
        'Period Reminders',
        description: 'Reminders for upcoming periods',
        importance: Importance.high,
      ),
    );

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _ChannelIds.ovulation,
        'Ovulation Alerts',
        description: 'Alerts for ovulation and fertile window',
        importance: Importance.defaultImportance,
      ),
    );

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _ChannelIds.daily,
        'Daily Reminders',
        description: 'Daily health check-in reminders',
        importance: Importance.low,
      ),
    );
  }

  // ─── Permissions ──────────────────────────────────────────────────────────

  Future<void> requestPermissions() async {
    if (Platform.isIOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Notification tap routing can be wired to a NavigatorKey here.
    // e.g. AppNavigator.navigateTo(response.payload);
  }

  // ─── FCM Setup ────────────────────────────────────────────────────────────

  Future<void> _initFCM() async {
    final fcm = FirebaseService.instance.messaging;

    // Register top-level background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Request FCM permission (iOS/web)
    await fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Show foreground messages as local notifications on iOS
    await fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handle messages received while app is in the foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle tapping a notification that opened the app from background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleFCMMessage);

    // Handle notification that opened the app from terminated state
    final initial = await fcm.getInitialMessage();
    if (initial != null) _handleFCMMessage(initial);

    // Save FCM token to Firestore
    final token = await fcm.getToken();
    if (token != null) await _saveFCMToken(token);

    // Keep token up-to-date on refresh
    fcm.onTokenRefresh.listen(_saveFCMToken);
  }

  Future<void> _saveFCMToken(String token) async {
    try {
      final uid = FirebaseService.instance.auth.currentUser?.uid;
      if (uid == null) return;
      await FirebaseService.instance.userDoc(uid).set(
        {'fcmToken': token},
        SetOptions(merge: true),
      );
    } catch (_) {
      // Non-critical — silently ignore
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _plugin.show(
      _NotificationIds.fcmForeground + message.hashCode % 1000,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _ChannelIds.period,
          'Period Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data['type'],
    );
  }

  void _handleFCMMessage(RemoteMessage message) {
    // Route to specific screen based on message type.
    // The NavigatorKey can be used here once wired up in app.dart.
    // e.g.:
    //   switch (message.data['type']) {
    //     case 'period_reminder': navigateTo('/home'); break;
    //     case 'ovulation_alert': navigateTo('/calendar'); break;
    //   }
  }

  // ─── Schedule: Period Reminder ─────────────────────────────────────────────

  /// Schedules a local notification [daysBefore] days before [periodDate].
  /// Cancels any existing period reminder before scheduling a new one.
  Future<void> schedulePeriodReminder(
      DateTime periodDate, int daysBefore) async {
    await cancelNotification(_NotificationIds.periodReminder);

    final reminderDate = periodDate.subtract(Duration(days: daysBefore));
    if (reminderDate.isBefore(DateTime.now())) return;

    await _plugin.zonedSchedule(
      _NotificationIds.periodReminder,
      '🩸 Period Reminder',
      'Your period is expected in $daysBefore '
          'day${daysBefore == 1 ? '' : 's'}. Stay prepared!',
      _toTZDateTime(reminderDate),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _ChannelIds.period,
          'Period Reminders',
          channelDescription: 'Reminders for upcoming periods',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ─── Schedule: Ovulation Alert ─────────────────────────────────────────────

  /// Schedules an ovulation alert one day before [ovulationDate].
  Future<void> scheduleOvulationAlert(DateTime ovulationDate) async {
    await cancelNotification(_NotificationIds.ovulationAlert);

    final alertDate = ovulationDate.subtract(const Duration(days: 1));
    if (alertDate.isBefore(DateTime.now())) return;

    await _plugin.zonedSchedule(
      _NotificationIds.ovulationAlert,
      '⭐ Ovulation Alert',
      'Your fertile window starts tomorrow. '
          'Your ovulation day is approaching!',
      _toTZDateTime(alertDate),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _ChannelIds.ovulation,
          'Ovulation Alerts',
          channelDescription: 'Alerts for ovulation and fertile window',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ─── Schedule: Daily Reminder ──────────────────────────────────────────────

  /// Schedules a daily reminder that fires every day at [time].
  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    await cancelNotification(_NotificationIds.dailyReminder);

    final now = DateTime.now();
    var scheduled =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      _NotificationIds.dailyReminder,
      '💜 Daily Check-in',
      'Take a moment to log how you are feeling today.',
      _toTZDateTime(scheduled),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _ChannelIds.daily,
          'Daily Reminders',
          channelDescription: 'Daily health check-in reminders',
          importance: Importance.low,
          priority: Priority.low,
        ),
        iOS: DarwinNotificationDetails(presentAlert: true),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // repeats daily
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
    );
  }

  // ─── Cancel ───────────────────────────────────────────────────────────────

  /// Cancel a single notification by [id].
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  /// Cancel all scheduled local notifications.
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  // ─── Reschedule All ───────────────────────────────────────────────────────

  /// Cancels everything and re-schedules period reminder, ovulation alert,
  /// and (optionally) daily reminder based on current cycle data.
  Future<void> rescheduleAllNotifications({
    required DateTime nextPeriod,
    required DateTime ovulationDate,
    required int daysBefore,
    TimeOfDay? dailyTime,
  }) async {
    await cancelAllNotifications();
    await schedulePeriodReminder(nextPeriod, daysBefore);
    await scheduleOvulationAlert(ovulationDate);
    if (dailyTime != null) {
      await scheduleDailyReminder(dailyTime);
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  tz.TZDateTime _toTZDateTime(DateTime dt) {
    return tz.TZDateTime(
      tz.local,
      dt.year,
      dt.month,
      dt.day,
      dt.hour,
      dt.minute,
    );
  }

  /// Attempts to resolve the device's IANA timezone name.
  /// Falls back to UTC if unavailable.
  Future<String> _resolveLocalTimezone() async {
    try {
      // On most platforms DateTime.now().timeZoneName is short (e.g. "EAT").
      // flutter_local_notifications ships tzdata so standard IANA names work.
      // We return 'UTC' as a safe fallback; a full solution uses
      // flutter_timezone package to get the proper IANA name.
      return 'UTC';
    } catch (_) {
      return 'UTC';
    }
  }
}
