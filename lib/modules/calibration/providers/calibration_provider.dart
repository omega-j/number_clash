import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../enums/bluetooth_enums.dart';
import '../../../models/common/result.dart';
import '../../bluetooth_management/utils/bluetooth_fluometer_constants.dart';
import '../../bluetooth_management/models/commands/request_measurement_command.dart';
import '../models/calibration_state.dart';
import '../../bluetooth_management/ble_fluorometer/providers/ibluetooth_manager.dart';
import '../../logging/providers/i_logging_provider.dart';
import 'i_calibration_provider.dart';

class CalibrationProvider extends StateNotifier<CalibrationState>
    implements ICalibrationProvider {
  static final CalibrationProvider _instance = CalibrationProvider._internal(
    bluetoothManager: null,
    logger: null,
  );

  IBluetoothManager? bluetoothManager;
  ILoggingProvider? logger;
  int sequenceId = 0;

  // Private constructor for singleton
  CalibrationProvider._internal({
    required this.bluetoothManager,
    required this.logger,
  }) : super(CalibrationState.initial());

  // Factory constructor to return singleton instance
  factory CalibrationProvider({
    required IBluetoothManager bluetoothManager,
    required ILoggingProvider logger,
  }) {
    _instance.bluetoothManager ??= bluetoothManager;
    _instance.logger ??= logger;
    return _instance;
  }

  @override
  Result<void> setNumberOfCalibrations(int count) {
    try {
      state = state.copyWith(numberOfCalibrations: count);
      return Result.success();
    } catch (e) {
      return Result.failure(
        message: "An error occurred while setting calibration count",
        exception: e,
      );
    }
  }

  @override
  Future<Result<void>> setCalibrationPoint(
      int pointIndex, double concentration) async {
    try {
      final updatedConcentrations = List.of(state.concentrations);
      if (updatedConcentrations.length <= pointIndex) {
        updatedConcentrations.length = pointIndex + 1;
      }
      updatedConcentrations[pointIndex] = concentration;
      state = state.copyWith(concentrations: updatedConcentrations);
      return Result.success();
    } catch (e) {
      return Result.failure(
        message: "Failed to set calibration point",
        exception: e,
      );
    }
  }

  @override
  Future<Result<void>> beginCalibration() async {
    logger?.logInfo("Calibration started.");
    return Result.success(message: 'Calibration started.');
  }

  @override
  Future<Result<void>> takeMeasurement() async {
    try {
      final commandData = RequestMeasurementCommand.generateCommand();
      final response = await bluetoothManager!.sendCommand(
        CommandType.requestMeasurement,
        commandData,
      );

      if (response.isFailure) {
        return Result.failure(
            message: "Measurement failed: ${response.message}");
      }

      if (response.isSuccessfulAndDataIsNotNull) {
        final measurementData = response.data!;
        final parsedMeasurement = BluetoothFluorometerConstants.parseFloat(
          measurementData.sublist(0, 4),
        );

        final updatedMeasurements = List.of(state.measurements);
        updatedMeasurements.add(parsedMeasurement);
        state = state.copyWith(measurements: updatedMeasurements);

        return Result.success(message: "Measurement taken successfully.");
      } else {
        return Result.failure(message: "No measurement data received.");
      }
    } catch (e) {
      return Result.failure(
          message: "Failed to take measurement", exception: e);
    }
  }

  @override
  Future<Result<void>> completeCalibration() async {
    try {
      state = state.copyWith(isCalibrationComplete: true);
      return Result.success(message: "Calibration completed successfully.");
    } catch (e) {
      return Result.failure(
          message: "Failed to complete calibration", exception: e);
    }
  }

  @override
  Future<Result<void>> restartCalibration() async {
    state = CalibrationState.initial();
    logger?.logInfo("Calibration restarted.");
    return Result.success(message: "Calibration restarted");
  }

  Result<void> nextStep() {
    try {
      if (state.currentStepIndex < state.numberOfCalibrations - 1) {
        state = state.copyWith(currentStepIndex: state.currentStepIndex + 1);
        return Result.success();
      } else {
        return Result.failure(message: "Already at the final step.");
      }
    } catch (e) {
      return Result.failure(
          message: "Failed to proceed to the next step", exception: e);
    }
  }

  int getNextSequenceId() => sequenceId++;
}
