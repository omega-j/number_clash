import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigurationDataProvider with ChangeNotifier {
  static const String _defaultViewRangeInSecondsKey =
      'default_view_range'; // Key for view range

  double _defaultViewRangeInSeconds = 30; // Default view range in seconds

  // Getters:
  double get defaultViewRangeInSeconds => _defaultViewRangeInSeconds;

  // Constructor:
  ConfigurationDataProvider() {
    _loadSettings();
  }

  // Load settings from SharedPreferences:
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    // _fontSize = prefs.getDouble(_fontSizeKey) ?? 14.0;
    _defaultViewRangeInSeconds =
        prefs.getDouble(_defaultViewRangeInSecondsKey) ??
            30; // Load view range or use default
    notifyListeners();
  }

  // Setters:
  Future<void> setDefaultViewRangeInSeconds(double newRange) async {
    _defaultViewRangeInSeconds = newRange;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_defaultViewRangeInSecondsKey,
        newRange); // Save view range to shared preferences
  }
}
