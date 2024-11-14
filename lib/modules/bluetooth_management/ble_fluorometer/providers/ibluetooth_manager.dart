// bluetooth_manager.dart

import 'package:beta_app/enums/bluetooth_enums.dart';
import 'package:beta_app/modules/bluetooth_management/models/responses/info_response.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../../../models/common/result.dart';

abstract class IBluetoothManager {
//  List<Device> devices;
  bool isConnected();

  Future<Result<List<BluetoothDevice>>> scanAndFilterDevices();
  Future<Result<void>> cancelScan();
  Future<Result<InfoResponse>> connect(BluetoothDevice device);
  Future<Result<void>> disconnect();
  Future<Result<List<int>>> sendCommand(
      CommandType commandType, List<int> commandData);
}
