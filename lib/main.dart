import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'services/firebase_service.dart';
import 'services/notification_service.dart';
import 'providers/auth_provider.dart';
import 'providers/cycle_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await FirebaseService.initialize();

  // Initialize Notification Service (local + FCM)
  try {
    await NotificationService.instance.initialize();
  } catch (_) {
    // Non-critical — app runs without push notifications
  }

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Load saved theme mode
  final savedTheme = prefs.getString('theme_mode') ?? 'light';
  final isDarkMode = savedTheme == 'dark';

  // Load saved language
  final savedLanguage = prefs.getString('language') ?? 'en';

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..checkAuthStatus(),
        ),
        ChangeNotifierProvider(create: (_) => CycleProvider()),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(isDarkMode: isDarkMode),
        ),
        ChangeNotifierProvider(
          create: (_) => LanguageProvider(initialLanguage: savedLanguage),
        ),
      ],
      child: const HerCycleApp(),
    ),
  );
}
