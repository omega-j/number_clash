import 'dart:convert';
import 'package:beta_app/utils/asset_paths.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class SupportedLocales {
  static final SupportedLocales _instance = SupportedLocales._internal();
  List<Locale>? _locales;

  SupportedLocales._internal();

  factory SupportedLocales() => _instance;

  Future<List<Locale>> loadLocales() async {
    // If locales are already loaded, return them directly
    if (_locales != null) return _locales!;

    final List<Locale> locales = [];
    try {
      final manifestJson =
          await rootBundle.loadString(AssetPaths.availableLanguagesManifest);
      final manifestData = json.decode(manifestJson);

      for (var localeData in manifestData['locales']) {
        final languageCode = localeData['languageCode'];
        locales.add(Locale(languageCode));
      }
      _locales = locales;
    } catch (e) {
      print("Error loading supported locales: $e");
      return [];
    }

    return _locales!;
  }
}

final supportedLocalesProvider = FutureProvider<List<Locale>>((ref) async {
  final supportedLocales = SupportedLocales();
  return await supportedLocales.loadLocales();
});
