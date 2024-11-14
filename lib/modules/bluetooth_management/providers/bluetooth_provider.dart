import 'dart:async';
import 'package:beta_app/modules/bluetooth_management/models/responses/info_response.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../../enums/bluetooth_enums.dart';
import '../../../models/common/result.dart';
import '../ble_fluorometer/providers/ibluetooth_manager.dart';
import 'i_bluetooth_provider.dart';
import '../../logging/providers/i_logging_provider.dart';

class BluetoothProvider implements IBluetoothProvider {
  final IBluetoothManager _bluetoothManager;
  final ILoggingProvider logger;

  BluetoothProvider({
    required IBluetoothManager bluetoothManager,
    required ILoggingProvider logger,
  })  : _bluetoothManager = bluetoothManager,
        logger = logger;

  final StreamController<List<BluetoothDevice>> _availableDevicesController =
      StreamController<List<BluetoothDevice>>.broadcast();
  final StreamController<BleConnectionStatusCode> _connectionStatusController =
      StreamController<BleConnectionStatusCode>.broadcast();
  final StreamController<String?> _scanErrorController =
      StreamController<String?>.broadcast();
  final StreamController<bool> _isScanningController =
      StreamController<bool>.broadcast();

  List<BluetoothDevice> _availableDevices = [];
  bool _isConnected = false;
  bool _isScanning = false;
  String? _scanError;

  BluetoothDevice? _connectedDevice;

  @override
  BluetoothDevice? get connectedDevice => _connectedDevice;

  @override
  bool get isConnected => _isConnected;

  @override
  String? get scanError => _scanError;

  @override
  Stream<bool> get isScanningStream => _isScanningController.stream;

  @override
  Stream<BleConnectionStatusCode> get connectionStatusStream =>
      _connectionStatusController.stream;

  @override
  Stream<List<BluetoothDevice>> get availableDevicesStream =>
      _availableDevicesController.stream;

  @override
  Stream<String?> get scanErrorStream => _scanErrorController.stream;

  @override
  Future<void> startScan() async {
    _isScanning = true;
    _isScanningController.add(_isScanning);
    _connectionStatusController.add(BleConnectionStatusCode.scanning);

    try {
      final scanResult = await _bluetoothManager.scanAndFilterDevices();

      if (scanResult.isSuccessful) {
        _availableDevices = scanResult.data ?? [];
        _availableDevicesController.add(_availableDevices);
        _connectionStatusController.add(BleConnectionStatusCode.scanCompleted);
      } else {
        _scanError = scanResult.message;
        _scanErrorController.add(_scanError);
        _connectionStatusController.add(BleConnectionStatusCode.idle);
      }
    } catch (e) {
      _scanError = 'Bluetooth Scan Error: $e';
      _scanErrorController.add(_scanError);
      _connectionStatusController.add(BleConnectionStatusCode.idle);
      logger.logError(_scanError!);
    } finally {
      _isScanning = false;
      _isScanningController.add(_isScanning);
    }
  }

  @override
  Future<void> stopScan() async {
    try {
      final stopResult = await _bluetoothManager.cancelScan();

      if (stopResult.isSuccessful) {
        _availableDevices.clear();
        _availableDevicesController.add([]); // Emit empty list
        _connectionStatusController.add(BleConnectionStatusCode.idle);
      } else {
        _scanError = stopResult.message;
        _scanErrorController.add(_scanError);
      }
    } catch (e) {
      _scanError = 'Error stopping scan: $e';
      _scanErrorController.add(_scanError);
      logger.logError(_scanError!);
    } finally {
      _isScanning = false;
      _isScanningController.add(_isScanning);
    }
  }

  @override
  Future<Result<InfoResponse>> connectToDevice(BluetoothDevice device) async {
    try {
      _connectionStatusController.add(BleConnectionStatusCode.connecting);
      final connectResult = await _bluetoothManager.connect(device);

      if (connectResult.isSuccessfulAndDataIsNotNull) {
        _isConnected = true;
        _connectedDevice = device;

        _connectionStatusController.add(BleConnectionStatusCode.connected);

        return Result.success(
            message: 'Connected to ${device.platformName}.',
            data: connectResult.data);
      }

      _connectionStatusController.add(BleConnectionStatusCode.connectionFailed);
      return Result.failure(
          message:
              'Failed to connect to device: ${device.platformName}.');
    } catch (e, stackTrace) {
      _connectionStatusController.add(BleConnectionStatusCode.connectionFailed);
      return Result.failure(
          message: 'Exception during connection: $e',
          exception: e,
          stackTrace: stackTrace);
    }
  }

  @override
  Future<Result<void>> disconnect() async {
    try {
      final disconnectResult = await _bluetoothManager.disconnect();

      if (disconnectResult.isSuccessful) {
        _isConnected = false;
        _connectedDevice = null;
        _connectionStatusController.add(BleConnectionStatusCode.disconnected);
        return Result.success(message: 'Disconnected successfully.');
      } else {
        return Result.failure(
            message:
                'Error during disconnection: ${disconnectResult.message}');
      }
    } catch (e, stackTrace) {
      return Result.failure(
          message: 'Exception during disconnection: $e',
          exception: e,
          stackTrace: stackTrace);
    }
  }

  @override
  void dispose() {
    _availableDevicesController.close();
    _connectionStatusController.close();
    _scanErrorController.close();
    _isScanningController.close();
  }
}
