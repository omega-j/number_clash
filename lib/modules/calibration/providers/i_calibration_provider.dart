import '../../../models/common/result.dart';

abstract class ICalibrationProvider {
  /// Sets the number of calibration points for the calibration process.
  Result<void> setNumberOfCalibrations(int count);

  /// Starts the calibration process.
  Future<Result<void>> beginCalibration();

  /// Sets a calibration point with a specific concentration value.
  Future<Result<void>> setCalibrationPoint(int pointIndex, double concentration);

  /// Takes a measurement at the current calibration point.
  Future<Result<void>> takeMeasurement();

  /// Completes the calibration process, finalizing all calibration points.
  Future<Result<void>> completeCalibration();

  /// Restarts the calibration process, clearing previous values.
  Future<Result<void>> restartCalibration();
}