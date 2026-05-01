import 'package:flutter/material.dart';
import '../services/theme_service.dart';

/// Provider for managing app theme state
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _isDarkMode = await ThemeService.loadThemePreference();
    notifyListeners();
  }

  /// Toggle between dark and light mode
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await ThemeService.saveThemePreference(_isDarkMode);
    notifyListeners();
  }
}
