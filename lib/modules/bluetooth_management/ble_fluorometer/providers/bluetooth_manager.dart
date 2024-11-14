import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:beta_app/enums/bluetooth_enums.dart';
import 'package:beta_app/modules/bluetooth_management/models/commands/request_measurement_command.dart';
import 'package:beta_app/modules/bluetooth_management/models/commands/update_date_time_command.dart';
import 'package:beta_app/modules/logging/providers/i_logging_provider.dart';
import 'package:beta_app/modules/bluetooth_management/models/commands/get_info_command.dart';
import '../../../../models/common/result.dart';
import '../../utils/bluetooth_fluometer_constants.dart';
import '../../models/commands/auto_notify_command.dart';
import '../../models/commands/calibration_command.dart';
import '../../models/responses/info_response.dart';
import '../../models/responses/auto_notify_response.dart';
import 'ibluetooth_manager.dart';

class BluetoothManager implements IBluetoothManager {
  // Singleton instance
  static final BluetoothManager _instance = BluetoothManager._internal();

  ILoggingProvider? logger;
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  bool _isConnected = false;
  int scanDurationInSeconds = 20;
  Completer<void>? _scanCompleter;

  // Private constructor for singleton
  BluetoothManager._internal() : logger = null;

  // Factory constructor to provide singleton
  factory BluetoothManager({ILoggingProvider? logger}) {
    if (_instance.logger == null && logger != null) {
      _instance.logger = logger;
    }
    return _instance;
  }

  @override
  bool isConnected() => _isConnected;

  @override
  Future<Result<List<BluetoothDevice>>> scanAndFilterDevices() async {
    final List<BluetoothDevice> allDevices = [];

    try {
      await FlutterBluePlus.startScan(
          timeout: Duration(seconds: scanDurationInSeconds));

      final scanResultsSubscription = FlutterBluePlus.scanResults.listen(
        (scanResults) {
          for (var scanResult in scanResults) {
            final device = scanResult.device;
            if (device.platformName.isNotEmpty &&
                !allDevices.contains(device)) {
              allDevices.add(device);
              logger?.logInfo(
                  'Found device: ${device.platformName}, ID: ${device.id}');
            }
          }
        },
        onError: (error) {
          logger?.logError("Scan error: $error");
        },
      );

      await Future.delayed(Duration(seconds: scanDurationInSeconds));
      await FlutterBluePlus.stopScan();
      await scanResultsSubscription.cancel();

      final matchingDevices = allDevices
          .where(
              (device) => RegExp(r'^XC-\w{7}$').hasMatch(device.platformName))
          .toList();

      if (matchingDevices.isNotEmpty) {
        return Result.success(
            data: matchingDevices,
            message: "Found ${matchingDevices.length} matching devices");
      } else {
        return Result.failure(
            message: "No devices matching the ID format found.");
      }
    } catch (e) {
      return Result.failure(message: "Device scan failed", exception: e);
    }
  }

  @override
  Future<Result<InfoResponse>> connect(BluetoothDevice device) async {
    try {
      _connectedDevice = device;
      await _connectedDevice!.connect();
      final services = await _connectedDevice!.discoverServices();

      _findWriteCharacteristic(
          services, BluetoothFluorometerConstants.characteristicUUID);
      if (_writeCharacteristic == null) {
        return Result.failure(message: "Write characteristic not found");
      }

      final disableAutoNotifyCommand =
          AutoNotifyCommand.createAutoNotifyCommand(
              enable: false, interval: 10);
      await sendCommand(CommandType.autoNotify, disableAutoNotifyCommand);

      _isConnected = true;
      logger?.logInfo("Connected to ${device.platformName}");

      final Result<List<int>> infoResult = await sendCommand(
          CommandType.getInfo, GetInfoCommand.getDeviceInfoCommand());

      if (infoResult.isFailure) {
        return Result.failure(
            message: "Failed to retrieve device info: ${infoResult.message}");
      }

      if (infoResult.isSuccessfulAndDataIsNotNull) {
        final infoResponse = InfoResponse.fromData(infoResult.data!);
        return Result.success(data: infoResponse);
      }

      return Result.failure(message: "No device info received.");
    } catch (e, stackTrace) {
      return Result.failure(
          message: "Failed to connect", exception: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<Result<void>> disconnect() async {
    try {
      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
        _connectedDevice = null;
        _writeCharacteristic = null;
        _isConnected = false;
        return Result.success(message: "Disconnected from device");
      } else {
        return Result.success(message: "No device connected");
      }
    } catch (e) {
      return Result.failure(message: "Disconnection failed", exception: e);
    }
  }

  @override
  Future<Result<List<int>>> sendCommand(
      CommandType commandType, List<int> commandData) async {
    try {
      if (!_isConnected || _writeCharacteristic == null) {
        return Result.failure(
            message: "Not connected or characteristic not set.");
      }

      // Validate the command based on the command type
      switch (commandType) {
        case CommandType.getInfo:
          if (!GetInfoCommand.validateCommand(commandData)) {
            throw ArgumentError("Invalid data for GetInfo command.");
          }
          break;
        case CommandType.updateDate:
          if (!UpdateDateTimeCommand.validateCommand(commandData)) {
            throw ArgumentError("Invalid data for Update Date command.");
          }
          break;
        case CommandType.requestMeasurement:
          if (!RequestMeasurementCommand.validateCommand(commandData)) {
            throw ArgumentError(
                "Invalid data for Request Measurement command.");
          }
          break;
        case CommandType.calibration:
          if (!CalibrationCommand.validateCommand(commandData)) {
            throw ArgumentError("Invalid data for Calibration command.");
          }
          break;
        case CommandType.autoNotify:
          if (!AutoNotifyCommand.validateCommand(commandData)) {
            throw ArgumentError("Invalid data for Auto Notify command.");
          }
          break;
        default:
          return Result.failure(
              message: "Unsupported command type: $commandType");
      }

      await _writeCharacteristic?.setNotifyValue(true);
      await _writeCharacteristic!.write(commandData, withoutResponse: true);
      final List<int> response = await _writeCharacteristic!.read();

      bool isValidResponse;
      switch (commandType) {
        case CommandType.getInfo:
          isValidResponse = GetInfoCommand.validateResponse(response);
          break;
        case CommandType.updateDate:
          isValidResponse = UpdateDateTimeCommand.validateResponse(response);
          break;
        case CommandType.requestMeasurement:
          isValidResponse =
              RequestMeasurementCommand.validateResponse(response);
          break;
        case CommandType.calibration:
          isValidResponse = CalibrationCommand.validateResponse(response);
          break;
        case CommandType.autoNotify:
          isValidResponse = AutoNotifyCommand.validateResponse(response);
          break;
        default:
          return Result.failure(
              message: "Unsupported command type for response validation.");
      }

      if (!isValidResponse) {
        return Result.failure(message: "Invalid response format received.");
      }

      return Result.success(data: response);
    } catch (e, stackTrace) {
      return Result.failure(
          message: "Failed to send command",
          exception: e,
          stackTrace: stackTrace);
    }
  }

  @override
  Future<Result<void>> cancelScan() async {
    if (_scanCompleter != null && !_scanCompleter!.isCompleted) {
      _scanCompleter!.complete();
      return Result.success(message: 'Scan cancelled by the user.');
    } else {
      return Result.failure(message: "Unable to cancel scan.");
    }
  }

  void _findWriteCharacteristic(
      List<BluetoothService> services, Guid characteristicId) {
    for (final service in services) {
      if (service.uuid == BluetoothFluorometerConstants.serviceUUID) {
        for (final characteristic in service.characteristics) {
          if (characteristic.uuid == characteristicId &&
              characteristic.properties.writeWithoutResponse) {
            _writeCharacteristic = characteristic;
            logger?.logInfo(
                'Write characteristic found with UUID: ${characteristic.uuid}');
            break;
          }
        }
      }
      if (_writeCharacteristic != null) break;
    }

    if (_writeCharacteristic == null) {
      logger?.logError(
          "Write characteristic not found in the provided services.");
    }
  }
}
