import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/models/data_record.dart';
import '../database/providers/database_provider.dart';
import '../database/providers/i_database_provider.dart';
import '../settings/providers/settings_provider.dart';
import '../settings/services/app_settings_service.dart';
import '../analytics/providers/i_analytics_provider.dart';
import '../analytics/providers/firebase_analytics_provider.dart';
import '../bluetooth_management/providers/bluetooth_provider.dart';
import '../bluetooth_management/providers/i_bluetooth_provider.dart';
import '../calibration/providers/calibration_provider.dart';
import '../data_management/providers/data_management_provider.dart';
import '../input_output/providers/i_input_output_provider.dart';
import '../input_output/providers/input_output_provider.dart';
import '../localization/providers/localization_provider.dart';
import '../logging/providers/log_listener.dart';
import '../logging/providers/i_logging_provider.dart';
import '../logging/providers/logging_provider.dart';
import '../bluetooth_management/ble_fluorometer/providers/bluetooth_manager.dart';
import '../bluetooth_management/ble_fluorometer/providers/ibluetooth_manager.dart';
import '../bluetooth_management/ble_fluorometer/services/data_simulator.dart';
import '../input_output/services/i_file_service.dart';
import '../settings/services/iuser_settings_service.dart';
import '../settings/services/user_settings_service.dart';
import '../input_output/services/file_service.dart';
import '../calibration/models/calibration_state.dart';
import '../bluetooth_management/ble_fluorometer/providers/data_provider.dart';
import '../theming/theme_provider.dart';
import '../settings/providers/configuration_data_provider.dart';
import '../user_interface/graph/graph_state_provider.dart';
import '../user_interface/graph/session_management/session_controller.dart';
import '../user_interface/graph/session_management/session_state.dart';
import '../user_interface/navigation_provider.dart';

final navigationProvider =
    StateNotifierProvider<NavigationProvider, PageRouteInfo>((ref) {
  return NavigationProvider();
});

// Analytics Provider
// final analyticsProvider = Provider<IAnalyticsProvider>((ref) {
//   return FirebaseAnalyticsProvider();
// });

/// Logging Provider with analytics dependency, foundational for all logs
final loggingProvider = Provider<ILoggingProvider>((ref) {
  // final analytics = ref.read(analyticsProvider);
  return LoggingProvider(
    logStorage: null,
    // analyticsProvider: analytics,
  );
});

/// LogListener Provider, always available across the app
final logListenerProvider = Provider<LogListener>((ref) {
  final logging = ref.read(loggingProvider);
  final logListener = LogListener(loggingProvider: logging);
  logListener.initialize();
  ref.onDispose(() => logListener.dispose());
  return logListener;
});

// File Service Provider
final fileServiceProvider = Provider<IFileService>((ref) {
  return FileService(logger: ref.read(loggingProvider));
});

// InputOutput Provider, Singleton for file operations
final inputOutputProvider = Provider<IInputOutputProvider>((ref) {
  return InputOutputProvider(ref.read(fileServiceProvider));
});

// AppSettingsService Provider
final appSettingsServiceProvider = Provider<AppSettingsService>((ref) {
  return AppSettingsService();
});

// Settings Provider
final settingsProvider =
    StateNotifierProvider<SettingsProvider, SettingsState>((ref) {
  return SettingsProvider(
    logger: ref.read(loggingProvider),
    userSettingsService: ref.read(userSettingsServiceProvider),
    appSettingsService: ref.read(appSettingsServiceProvider),
    ref: ref,
  );
});

// Localization Provider, managing language and locale
final localizationProvider =
    StateNotifierProvider<LocalizationProvider, LocalizationState>(
  (ref) => LocalizationProvider(
    logger: ref.watch(loggingProvider),
    ioProvider: ref.watch(inputOutputProvider),
    appSettingsService: ref.watch(appSettingsServiceProvider),
  ),
);

// Theme Provider for app theming
final themeProviderInstance = ChangeNotifierProvider<ThemeProvider>((ref) {
  return ThemeProvider(ref);
});

// Bluetooth Manager Provider, Singleton for handling Bluetooth operations
final bluetoothManagerProvider = Provider<IBluetoothManager>((ref) {
  return BluetoothManager(logger: ref.read(loggingProvider));
});

// Bluetooth Provider, works with BluetoothManager for device interactions
final bluetoothDatasourceProvider = Provider<IBluetoothProvider>((ref) {
  final bluetoothManager = ref.read(bluetoothManagerProvider);
  return BluetoothProvider(
    bluetoothManager: bluetoothManager,
    logger: ref.read(loggingProvider),
  );
});

// User Settings Service Provider
final userSettingsServiceProvider = Provider<IUserSettingsService>((ref) {
  return UserSettingsService();
});

// Data Simulator Provider, lazy-loaded for optional use
final dataSimulatorProvider = Provider<DataSimulator>((ref) {
  return DataSimulator();
});

// Aggregated data dependencies for DataProvider
final dataDependenciesProvider = Provider((ref) {
  return {
    'dataSimulator': ref.watch(dataSimulatorProvider),
    // 'analyticsProvider': ref.watch(analyticsProvider),
    'logger': ref.watch(loggingProvider),
  };
});

// Data Provider, Singleton instance scoped to specific pages only
final dataProvider = Provider<DataProvider>((ref) {
  final dependencies = ref.read(dataDependenciesProvider);
  return DataProvider(
    dataSimulator: dependencies['dataSimulator'] as DataSimulator,
    // analyticsProvider: dependencies['analyticsProvider'] as IAnalyticsProvider,
    logger: dependencies['logger'] as ILoggingProvider,
  );
});

// Configuration Data Provider, Singleton for configuration handling
final configurationDataProvider = Provider<ConfigurationDataProvider>((ref) {
  return ConfigurationDataProvider();
});

final databaseProvider =
    StateNotifierProvider<DatabaseProvider, Map<String, DataRecord>>((ref) {
  final logger = ref.watch(loggingProvider);
  return DatabaseProvider(logger: logger);
});

// Graph State Provider for managing graph state and data
final graphStateProvider = Provider<GraphStateProvider>((ref) {
  return GraphStateProvider(
    logger: ref.read(loggingProvider),
    configurationDataProvider: ref.read(configurationDataProvider),
    themeProvider: ref.read(themeProviderInstance),
    dataProvider: ref.read(dataProvider),
    inputOutputProvider: ref.read(inputOutputProvider),
    databaseProvider: ref.read(databaseProvider.notifier),
  );
});

// Data Management Provider, scoped to data management page
final dataManagementProviderProvider =
    ChangeNotifierProvider<DataManagementProvider>((ref) {
  final logger = ref.read(loggingProvider);
  final fileService = ref.read(fileServiceProvider);
  final databaseProviderInstance = ref.read(databaseProvider.notifier);
  return DataManagementProvider(
    logger: logger,
    fileService: fileService,
    databaseProvider: databaseProviderInstance,
  );
});

// Calibration Provider, Singleton for calibration functionality
final calibrationProvider =
    StateNotifierProvider<CalibrationProvider, CalibrationState>((ref) {
  return CalibrationProvider(
    bluetoothManager: ref.read(bluetoothManagerProvider),
    logger: ref.read(loggingProvider),
  );
});

final sessionControllerProvider =
    StateNotifierProvider<SessionController, SessionState>(
  (ref) =>
      SessionController(databaseProvider: ref.watch(databaseProvider.notifier)),
);
