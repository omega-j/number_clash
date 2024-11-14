import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static const String textScalerKey = 'text_scaler';

  static Future<double> getTextScaler() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(textScalerKey) ?? 1.0;
  }

  static Future<void> setTextScaler(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(textScalerKey, value);
  }

   // Method to save color values to Shared Preferences
  static Future<void> saveColorToPreferences(String key, Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, color.value);
  }

  // Method to save font size to Shared Preferences
  static Future<void> saveFontSizeToPreferences(double fontSize) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', fontSize);
  }
}
