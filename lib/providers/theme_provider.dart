import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode;

  ThemeProvider({bool isDarkMode = false}) : _isDarkMode = isDarkMode;

  bool get isDarkMode => _isDarkMode;

  Future<void> toggleTheme() async {
    try {
      _isDarkMode = !_isDarkMode;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'theme_mode',
        _isDarkMode ? 'dark' : 'light',
      );

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setDarkMode(bool isDark) async {
    try {
      _isDarkMode = isDark;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'theme_mode',
        isDark ? 'dark' : 'light',
      );

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
