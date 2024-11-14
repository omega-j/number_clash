import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../provider_setup/providers.dart';
import '../../localization/providers/i_localization_provider.dart';
import '../providers/settings_provider.dart';
import '../../theming/theme_provider.dart';

@RoutePage()
class SettingsPage extends ConsumerWidget {
  SettingsPage({Key? key}) : super(key: key ?? UniqueKey());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.watch(themeProviderInstance.notifier);
final themeData = ref.watch(themeProviderInstance);
    final settings = ref.watch(settingsProvider.notifier);
    final state = ref.watch(settingsProvider);
    final localization = ref.watch(localizationProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.settings),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                localization.getString('settings_page'),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildDisplaySettings(themeNotifier, themeData, localization),
            _buildGraphSettings(themeNotifier, context, localization),
            _buildLanguageSetting(settings, state, localization),
            _buildNotificationSetting(settings, state, localization),
            _buildAccessibilitySetting(settings, state, localization),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplaySettings(ThemeProvider themeNotifier,
      ThemeProvider themeData, ILocalizationProvider localization) {
    return ExpansionTile(
      title: Row(
        children: [
          Icon(Icons.brightness_medium),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              localization.getString('display_settings'),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      children: [
        SwitchListTile(
          title: Text(localization.getString('dark_mode')),
          secondary: Icon(Icons.brightness_6),
          value: themeData.isDarkMode,
          onChanged: (_) => themeNotifier.toggleThemeMode(),
        ),
        ListTile(
          title: Text(localization.getString('select_theme')),
          trailing: FutureBuilder<List<String>>(
            future: themeNotifier.getAvailableThemes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text(localization.getString('error_loading_themes'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text(localization.getString('no_themes_found'));
              }

              final themes = snapshot.data!;
              return DropdownButton<String>(
                value: themeNotifier.currentThemeName,
                items: themes.map((themeName) {
                  return DropdownMenuItem<String>(
                    value: themeName,
                    child: Text(themeName),
                  );
                }).toList(),
                onChanged: (String? newTheme) {
                  if (newTheme != null) {
                    themeNotifier.applyTheme(newTheme);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGraphSettings(ThemeProvider themeNotifier, BuildContext context,
      ILocalizationProvider localization) {
    return ExpansionTile(
      title: Row(
        children: [
          Icon(Icons.bar_chart),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              localization.getString('graph_settings'),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      children: [
        _colorPickerTile(
          title: localization.getString('graph_background_color'),
          icon: Icons.format_paint,
          color: themeNotifier.graphBackgroundColor,
          onColorSelected: (color) => themeNotifier.setGraphColors(
            color,
            themeNotifier.graphLineColor,
            themeNotifier.graphIncrementLineColor,
          ),
          context: context,
          localization: localization,
        ),
        _colorPickerTile(
          title: localization.getString('graph_line_color'),
          icon: Icons.show_chart,
          color: themeNotifier.graphLineColor,
          onColorSelected: (color) => themeNotifier.setGraphColors(
            themeNotifier.graphBackgroundColor,
            color,
            themeNotifier.graphIncrementLineColor,
          ),
          context: context,
          localization: localization,
        ),
        _colorPickerTile(
          title: localization.getString('graph_increment_line_color'),
          icon: Icons.timeline,
          color: themeNotifier.graphIncrementLineColor,
          onColorSelected: (color) => themeNotifier.setGraphColors(
            themeNotifier.graphBackgroundColor,
            themeNotifier.graphLineColor,
            color,
          ),
          context: context,
          localization: localization,
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: themeNotifier.resetGraphColors,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    localization.getString('reset_to_default'),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSetting(SettingsProvider settingsProvider,
      SettingsState state, ILocalizationProvider localization) {
    final availableLocales = localization.supportedLocales;

    return ExpansionTile(
      title: Row(
        children: [
          Icon(Icons.language),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              localization.getString('language_settings'),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      children: [
        ListTile(
          title: Text(localization.getString('select_language')),
          trailing: DropdownButton<String>(
            value: state.currentLanguage,
            items: availableLocales.map((locale) {
              String localeCode = locale.languageCode;
              return DropdownMenuItem<String>(
                value: localeCode,
                child: Text(localization.getString(
                    'language_$localeCode')), // Fetching localized language name
              );
            }).toList(),
            onChanged: (String? newLanguage) {
              if (newLanguage != null) {
                settingsProvider.updateLanguage(newLanguage);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationSetting(SettingsProvider settingsProvider,
      SettingsState state, ILocalizationProvider localization) {
    return SwitchListTile(
      title: Text(localization.getString('enable_notifications')),
      secondary: Icon(Icons.notifications),
      value: state.notificationsEnabled,
      onChanged: (value) => settingsProvider.toggleNotifications(value),
    );
  }

  Widget _buildAccessibilitySetting(SettingsProvider settingsProvider,
      SettingsState state, ILocalizationProvider localization) {
    return SwitchListTile(
      title: Text(localization.getString('enable_accessibility_features')),
      secondary: Icon(Icons.accessibility),
      value: state.accessibilityFeaturesEnabled,
      onChanged: (value) => settingsProvider.toggleAccessibilityFeatures(value),
    );
  }

  Widget _colorPickerTile({
    required String title,
    required IconData icon,
    required Color color,
    required Function(Color) onColorSelected,
    required BuildContext context,
    required ILocalizationProvider localization,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: CircleAvatar(
        backgroundColor: color,
        radius: 14,
      ),
      onTap: () => _pickColor(context, color, onColorSelected, localization),
    );
  }

  void _pickColor(
    BuildContext context,
    Color currentColor,
    Function(Color) updateColor,
    ILocalizationProvider localization,
  ) {
    Color selectedColor = currentColor; // Local variable for color selection

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localization.getString('select_color')),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (color) {
                selectedColor =
                    color; // Update local color without state change
              },
              pickerAreaHeightPercent: 0.7,
            ),
          ),
          actions: [
            TextButton(
              child: Text(localization.getString('done')),
              onPressed: () {
                updateColor(selectedColor); // Update state only on confirmation
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
