import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

/// Service for persisting theme preference in local storage
class ThemeService {
  /// Load saved theme preference (defaults to dark mode)
  static Future<bool> loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(AppConstants.themeKey) ?? true; // dark by default
    } catch (_) {
      return true;
    }
  }

  /// Save theme preference
  static Future<void> saveThemePreference(bool isDark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.themeKey, isDark);
    } catch (_) {}
  }
}
