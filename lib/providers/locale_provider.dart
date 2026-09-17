import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing and persisting in-app language/locale preferences.
class LocaleProvider extends ChangeNotifier {
  static const String _prefKey = 'selected_language_code';

  Locale _locale = const Locale('en');

  /// Currently active in-app locale.
  Locale get locale => _locale;

  /// Loads previously saved locale from SharedPreferences on app startup.
  Future<void> loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_prefKey);
      if (savedCode != null && savedCode.isNotEmpty) {
        _locale = Locale(savedCode);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading saved locale: $e');
    }
  }

  /// Sets new locale, notifies listeners, and persists choice to SharedPreferences.
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, locale.languageCode);
    } catch (e) {
      debugPrint('Error saving locale preference: $e');
    }
  }
}
