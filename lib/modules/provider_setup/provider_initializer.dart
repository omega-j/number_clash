import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analytics/providers/i_analytics_provider.dart';
import '../analytics/providers/firebase_analytics_provider.dart';
import 'providers.dart';

class ProviderInitializer {
  final WidgetRef ref;

  ProviderInitializer(this.ref);

  void initializeAll() {
    // _initializeAnalytics();
    _initializeLogging();
    _initializeLogListener();
    _initializeFileService();
    _initializeInputOutput();
    _initializeSettings();
    _initializeLocalization();
    _initializeTheme();
    _initializeBluetooth();
    _initializeDataSimulator();
    _initializeDataProvider();
    _initializeConfiguration();
    _initializeGraphState();
    _initializeDataManagement();
    _initializeCalibration();
  }

  // void _initializeAnalytics() {
  //   ref.read(analyticsProvider);
  // }

  void _initializeLogging() {
    ref.read(loggingProvider);
  }

  void _initializeLogListener() {
    ref.read(logListenerProvider);
  }

  void _initializeFileService() {
    ref.read(fileServiceProvider);
  }

  void _initializeInputOutput() {
    ref.read(inputOutputProvider);
  }

  void _initializeSettings() {
    ref.read(settingsProvider);
  }

  void _initializeLocalization() {
    ref.read(localizationProvider);
  }

  void _initializeTheme() {
    ref.read(themeProviderInstance);
  }

  void _initializeBluetooth() {
    ref.read(bluetoothManagerProvider);
    ref.read(bluetoothDatasourceProvider);
  }

  void _initializeDataSimulator() {
    ref.read(dataSimulatorProvider);
  }

  void _initializeDataProvider() {
    ref.read(dataProvider);
  }

  void _initializeConfiguration() {
    ref.read(configurationDataProvider);
  }

  void _initializeGraphState() {
    ref.read(graphStateProvider);
  }

  void _initializeDataManagement() {
    ref.read(dataManagementProviderProvider);
  }

  void _initializeCalibration() {
    ref.read(calibrationProvider);
  }
}

// Define each provider with autoDispose

// final analyticsProvider = Provider.autoDispose<IAnalyticsProvider>((ref) {
//   return FirebaseAnalyticsProvider();
// });

//... (apply `autoDispose` to the rest of the providers, as shown in your original setup)