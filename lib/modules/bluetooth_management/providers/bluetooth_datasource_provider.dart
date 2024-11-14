import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../enums/bluetooth_enums.dart';
import '../models/responses/info_response.dart';
import '../../provider_setup/providers.dart'; // Import for accessing providers


// Provider to listen to scanning status
final isScanningProvider = StreamProvider<bool>((ref) {
  final bluetoothController = ref.watch(bluetoothDatasourceProvider);
  return bluetoothController.isScanningStream;
});

// Provider to track available devices during scanning
final availableDevicesProvider = StreamProvider<List<BluetoothDevice>>((ref) {
  final bluetoothController = ref.watch(bluetoothDatasourceProvider);
  return bluetoothController.availableDevicesStream;
});

// Provider for the device connection status
final connectionStatusProvider = StreamProvider<BleConnectionStatusCode>((ref) {
  final bluetoothController = ref.watch(bluetoothDatasourceProvider);
  return bluetoothController.connectionStatusStream;
});

// Provider to capture and update device info after connecting
final deviceInfoProvider = StateProvider<InfoResponse?>((ref) => null);

// Provider to manage scan error messages
final scanErrorProvider = StreamProvider<String?>((ref) {
  final bluetoothController = ref.watch(bluetoothDatasourceProvider);
  return bluetoothController.scanErrorStream;
});