import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/asset_paths.dart';
import '../../models/common/result.dart';

class ThemeProvider extends ChangeNotifier {
  final Ref ref;
  final String _defaultTitle = 'Measurement App';

  ThemeData _lightThemeData = ThemeData.light();
  ThemeData _darkThemeData = ThemeData.dark();
  ThemeMode _themeMode = ThemeMode.system;
  Map<String, dynamic> _themeConfig = {};
  bool _isInitialized = false;

  Color _graphBackgroundColor = Colors.white;
  Color _graphLineColor = Colors.black;
  Color _graphIncrementLineColor = Colors.grey;
  double _fontSize = 14.0;
  String _logoPath = '';
  String _currentThemeName = 'default';
  String _appTitle = 'Measurement App';

  ThemeData get lightThemeData => _lightThemeData;
  ThemeData get darkThemeData => _darkThemeData;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isInitialized => _isInitialized;
  ThemeData get currentThemeData =>
      _themeMode == ThemeMode.dark ? _darkThemeData : _lightThemeData;
  Color get graphBackgroundColor => _graphBackgroundColor;
  Color get graphLineColor => _graphLineColor;
  Color get graphIncrementLineColor => _graphIncrementLineColor;
  double get fontSize => _fontSize;
  String get logoPath => _logoPath;
  String get currentThemeName => _currentThemeName;
  String get appTitle => _appTitle;

  ThemeProvider(this.ref) {
    loadThemeConfiguration();
  }

  Future<List<String>> getAvailableThemes() async {
    final defaultThemePath = 'assets/themes/default';
    final clientThemePath = 'assets/themes/clients';
    final assetManifest = await rootBundle.loadString('AssetManifest.json');
    final themeFiles = json.decode(assetManifest) as Map<String, dynamic>;

    final defaultThemes = themeFiles.keys
        .where((path) =>
            path.startsWith(defaultThemePath) && path.endsWith('.json'))
        .map((path) =>
            path.replaceAll('$defaultThemePath/', '').replaceAll('.json', ''))
        .toList();

    final clientThemes = themeFiles.keys
        .where((path) =>
            path.startsWith(clientThemePath) && path.endsWith('.json'))
        .map((path) =>
            path.replaceAll('$clientThemePath/', '').replaceAll('.json', ''))
        .toList();

    return [...defaultThemes, ...clientThemes];
  }

  Future<void> loadThemeConfiguration([String? themeName]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Check if a theme was previously saved in preferences
      themeName ??= prefs.getString('selectedTheme') ?? 'theme_default_v1.0';

      final themePath = themeName.contains('theme_default')
          ? 'assets/themes/default/$themeName.json'
          : 'assets/themes/clients/$themeName.json';

      final jsonString = await rootBundle.loadString(themePath);
      _themeConfig = json.decode(jsonString);

      final lightThemeResult = _mapThemeData(_themeConfig['theme']['light']);
      final darkThemeResult = _mapThemeData(_themeConfig['theme']['dark']);

      if (lightThemeResult.isSuccessfulAndDataIsNotNull &&
          darkThemeResult.isSuccessfulAndDataIsNotNull) {
        bool? isDarkMode = prefs.getBool('isDarkMode');
        _themeMode = isDarkMode == true ? ThemeMode.dark : ThemeMode.light;

        _lightThemeData = lightThemeResult.data!;
        _darkThemeData = darkThemeResult.data!;
        _updateLogoPath();
        _loadGraphColors(prefs);
        _loadFontSize(prefs);

        _appTitle = _themeConfig['theme']['appName'] ?? _defaultTitle;
        _currentThemeName = themeName;
        _isInitialized = true;
        notifyListeners();
      } else {
        print("Failed to load theme data.");
      }
    } catch (e) {
      print("Error loading theme configuration: $e");
    }
  }

  Future<void> applyTheme(String themeName) async {
    await loadThemeConfiguration(themeName);
    _currentThemeName = themeName;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedTheme', themeName);
    notifyListeners();
  }

  Future<void> toggleThemeMode() async {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _updateLogoPath();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _themeMode == ThemeMode.dark);
    notifyListeners();
  }

  Future<void> setGraphColors(
      Color backgroundColor, Color lineColor, Color incrementLineColor) async {
    _graphBackgroundColor = backgroundColor;
    _graphLineColor = lineColor;
    _graphIncrementLineColor = incrementLineColor;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('graphBackgroundColor', backgroundColor.value);
    await prefs.setInt('graphLineColor', lineColor.value);
    await prefs.setInt('graphIncrementLineColor', incrementLineColor.value);
    notifyListeners();
  }

  void resetGraphColors() {
    _graphBackgroundColor = Color(int.parse(_themeConfig['theme']
                [_themeMode == ThemeMode.dark ? 'dark' : 'light']
            ['graphBackgroundColor']
        .replaceAll('#', '0xff')));
    _graphLineColor = Color(int.parse(_themeConfig['theme']
            [_themeMode == ThemeMode.dark ? 'dark' : 'light']['graphLineColor']
        .replaceAll('#', '0xff')));
    _graphIncrementLineColor = Color(int.parse(_themeConfig['theme']
                [_themeMode == ThemeMode.dark ? 'dark' : 'light']
            ['graphIncrementLineColor']
        .replaceAll('#', '0xff')));
    notifyListeners();
  }

  Future<void> setFontSize(double newSize) async {
    _fontSize = newSize;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', newSize);
    notifyListeners();
  }

  Result<ThemeData> _mapThemeData(Map<String, dynamic> themeDataMap) {
    try {
      final colorScheme = ColorScheme(
        primary: Color(int.parse(
            themeDataMap['colorScheme']['primary'].replaceAll('#', '0xff'))),
        secondary: Color(int.parse(
            themeDataMap['colorScheme']['secondary'].replaceAll('#', '0xff'))),
        surface: Color(int.parse(
            themeDataMap['colorScheme']['surface'].replaceAll('#', '0xff'))),
        error: Color(int.parse(
            themeDataMap['colorScheme']['error'].replaceAll('#', '0xff'))),
        onPrimary: Color(int.parse(
            themeDataMap['colorScheme']['onPrimary'].replaceAll('#', '0xff'))),
        onSecondary: Color(int.parse(themeDataMap['colorScheme']['onSecondary']
            .replaceAll('#', '0xff'))),
        onSurface: Color(int.parse(
            themeDataMap['colorScheme']['onSurface'].replaceAll('#', '0xff'))),
        onError: Color(int.parse(
            themeDataMap['colorScheme']['onError'].replaceAll('#', '0xff'))),
        brightness: Brightness.light,
      );

      final appBarTheme = AppBarTheme(
        backgroundColor: Color(int.parse(themeDataMap['appBarTheme']
                ['backgroundColor']
            .replaceAll('#', '0xff'))),
        foregroundColor: Color(int.parse(themeDataMap['appBarTheme']
                ['foregroundColor']
            .replaceAll('#', '0xff'))),
      );

      final bottomNavigationBarTheme = BottomNavigationBarThemeData(
        selectedItemColor: Color(int.parse(
            themeDataMap['bottomNavigationBarTheme']['selectedItemColor']
                .replaceAll('#', '0xff'))),
        unselectedItemColor: Color(int.parse(
            themeDataMap['bottomNavigationBarTheme']['unselectedItemColor']
                .replaceAll('#', '0xff'))),
        backgroundColor: Color(int.parse(
            themeDataMap['bottomNavigationBarTheme']['backgroundColor']
                .replaceAll('#', '0xff'))),
      );

      return Result.success(
          data: ThemeData(
        colorScheme: colorScheme,
        appBarTheme: appBarTheme,
        bottomNavigationBarTheme: bottomNavigationBarTheme,
      ));
    } catch (e, stackTrace) {
      return Result.failure(
          message: "Failed to map theme data.",
          exception: e,
          stackTrace: stackTrace);
    }
  }

  void _updateLogoPath() {
    _logoPath = _themeConfig['theme']
            [_themeMode == ThemeMode.dark ? 'dark' : 'light']['logoPath'] ??
        AssetPaths.defaultLogoPath;
  }

  void _loadGraphColors(SharedPreferences prefs) {
    _graphBackgroundColor = Color(prefs.getInt('graphBackgroundColor') ??
        int.parse(_themeConfig['theme']
                    [_themeMode == ThemeMode.dark ? 'dark' : 'light']
                ['graphBackgroundColor']
            .replaceAll('#', '0xff')));
    _graphLineColor = Color(prefs.getInt('graphLineColor') ??
        int.parse(_themeConfig['theme']
                    [_themeMode == ThemeMode.dark ? 'dark' : 'light']
                ['graphLineColor']
            .replaceAll('#', '0xff')));
    _graphIncrementLineColor = Color(prefs.getInt('graphIncrementLineColor') ??
        int.parse(_themeConfig['theme']
                    [_themeMode == ThemeMode.dark ? 'dark' : 'light']
                ['graphIncrementLineColor']
            .replaceAll('#', '0xff')));
  }

  void _loadFontSize(SharedPreferences prefs) {
    _fontSize = prefs.getDouble('fontSize') ??
        (_themeConfig['theme']['defaultFontSize']?.toDouble() ?? 14.0);
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('graphBackgroundColor', _graphBackgroundColor.value);
    await prefs.setInt('graphLineColor', _graphLineColor.value);
    await prefs.setInt(
        'graphIncrementLineColor', _graphIncrementLineColor.value);
    await prefs.setDouble('fontSize', _fontSize);
  }
}
