import 'dart:async';
import 'package:flutter/material.dart';
import '../../../logging/providers/i_logging_provider.dart';
import '../services/data_simulator.dart';
import '../../../analytics/providers/i_analytics_provider.dart';
import '../../../../enums/common_enums.dart';

class DataProvider extends ChangeNotifier {
  // Singleton instance
  static final DataProvider _instance = DataProvider._internal(
    dataSimulator: DataSimulator(),
    // analyticsProvider: null,
    logger: null,
  );

  final DataSimulator dataSimulator;
  // IAnalyticsProvider? analyticsProvider;
  ILoggingProvider? logger;

  final StreamController<double> _fluorideController =
      StreamController<double>.broadcast();
  final StreamController<double> _temperatureController =
      StreamController<double>.broadcast();
  final StreamController<double> _phController =
      StreamController<double>.broadcast();

  double? _latestFluoride;
  double? _latestTemperature;
  double? _latestPh;

  Stream<double> get fluorideStream => _fluorideController.stream;
  Stream<double> get temperatureStream => _temperatureController.stream;
  Stream<double> get phStream => _phController.stream;

  late StreamSubscription<Map<String, double>> _dataSubscription;
  Timer? _throttleTimer;
  final int throttleDurationMs;
  bool isFetching = true;
  bool hasError = false;
  ConnectionStatusCode connectionStatus = ConnectionStatusCode.disconnected;

  // Private constructor for singleton
  DataProvider._internal({
    required this.dataSimulator,
    //required this.analyticsProvider,
    required this.logger,
    this.throttleDurationMs = 500,
  }) {
    logger?.logInfo("DATA PROVIDER INITIALIZED.");
    _initializeDataSubscription();
  }

  // Factory constructor to provide singleton
  factory DataProvider({
    required DataSimulator dataSimulator,
    //required IAnalyticsProvider? analyticsProvider,
    required ILoggingProvider? logger,
    int throttleDurationMs = 500,
  }) {
   // _instance.analyticsProvider ??= analyticsProvider;
    _instance.logger ??= logger;
    return _instance;
  }

  void _initializeDataSubscription() {
    logger?.logInfo("Initializing Data Provider subscription...");

    _dataSubscription = dataSimulator.dataStream.listen(
      (dataPacket) {
        if (_throttleTimer == null || !_throttleTimer!.isActive) {
          _throttleTimer =
              Timer(Duration(milliseconds: throttleDurationMs), () {
            //_logDataUpdate();
            _emitLatestData();
          });
        }

        _processData(MeasurementType.fluoride,
            dataPacket[CommonStrings.fluoride]!, _fluorideController);
        _processData(MeasurementType.temperature,
            dataPacket[CommonStrings.temperature]!, _temperatureController);
        _processData(
            MeasurementType.ph, dataPacket[CommonStrings.ph]!, _phController);
      },
      onError: (error) {
        hasError = true;
        connectionStatus = ConnectionStatusCode.disconnected;
        logger?.logError("Data stream error: $error");
        notifyListeners();
      },
      onDone: () {
        isFetching = false;
        connectionStatus = ConnectionStatusCode.disconnected;
        logger?.logInfo("Data stream closed");
        notifyListeners();
      },
    );
  }

  void _emitLatestData() {
    if (_latestFluoride != null) {
      _fluorideController.add(_latestFluoride!);
    }
    if (_latestTemperature != null) {
      _temperatureController.add(_latestTemperature!);
    }
    if (_latestPh != null) {
      _phController.add(_latestPh!);
    }
  }

  void _processData(
      MeasurementType type, double data, StreamController<double> controller) {
    controller.add(data);

    switch (type) {
      case MeasurementType.fluoride:
        _latestFluoride = data;
        break;
      case MeasurementType.temperature:
        _latestTemperature = data;
        break;
      case MeasurementType.ph:
        _latestPh = data;
        break;
      case MeasurementType.realTime:
        // TODO: Handle this case.
      case MeasurementType.graph:
        // TODO: Handle this case.
      case MeasurementType.data:
        // TODO: Handle this case.
    }
  }

  void _logDataUpdate() {
    logger?.logInfo(
        "Fluoride: $_latestFluoride, Temperature: $_latestTemperature, pH: $_latestPh");
  }

  void updateData(double newData, MeasurementType type) {
    switch (type) {
      case MeasurementType.fluoride:
        _fluorideController.add(newData);
        _latestFluoride = newData;
        break;
      case MeasurementType.temperature:
        _temperatureController.add(newData);
        _latestTemperature = newData;
        break;
      case MeasurementType.ph:
        _phController.add(newData);
        _latestPh = newData;
        break;
      case MeasurementType.realTime:
        // TODO: Handle this case.
      case MeasurementType.graph:
        // TODO: Handle this case.
      case MeasurementType.data:
        // TODO: Handle this case.
    }

    notifyListeners();
  }

  double? getData(MeasurementType measurementType) {
    switch (measurementType) {
      case MeasurementType.fluoride:
        return _latestFluoride;
      case MeasurementType.temperature:
        return _latestTemperature;
      case MeasurementType.ph:
        return _latestPh;
      default:
        return null;
    }
  }

  void pause() {
    _dataSubscription.pause();
    isFetching = false;
    connectionStatus = ConnectionStatusCode.paused;
    logger?.logInfo("Data Provider paused");
    notifyListeners();
  }

  void resume() {
    _dataSubscription.resume();
    isFetching = true;
    connectionStatus = ConnectionStatusCode.connected;
    logger?.logInfo("Data Provider resumed");
    notifyListeners();
  }

  @override
  void dispose() {
    logger?.logInfo("Disposing Data Provider...");
    _fluorideController.close();
    _temperatureController.close();
    _phController.close();
    _dataSubscription.cancel();
    _throttleTimer?.cancel();
    super.dispose();
    logger?.logInfo("Data Provider disposed");
  }
}