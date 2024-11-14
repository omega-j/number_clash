import 'package:beta_app/modules/bluetooth_management/models/responses/info_response.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../../enums/bluetooth_enums.dart';
import '../../../models/common/result.dart';

abstract class IBluetoothProvider {
  /// Stream that emits scanning state changes (true if scanning, false otherwise).
  Stream<bool> get isScanningStream;

  /// Stream that emits error messages, if any, encountered during Bluetooth operations.
  Stream<String?> get scanErrorStream;

  /// Stream that emits connection status updates to track connection states.
  Stream<BleConnectionStatusCode> get connectionStatusStream;

  /// Stream of available devices discovered during scanning.
  Stream<List<BluetoothDevice>> get availableDevicesStream;

  /// Indicates if a device is currently connected.
  bool get isConnected; // Added property

  /// The error message, if any, encountered during scanning.
  String? get scanError; // Added property


  /// The connected device.
  BluetoothDevice? get connectedDevice;



  /// Initiates a scan for available Bluetooth devices.
  Future<void> startScan();

  /// Connects to a selected Bluetooth device by its ID.
  Future<Result<InfoResponse>> connectToDevice(BluetoothDevice device);

  /// Disconnects from the currently connected device.
  Future<void> disconnect();

  /// Stops the scanning process.
  Future<void> stopScan();

  //Future<Result<GetDeviceInfoResponse>> requestDeviceInfo();

  void dispose();
}
