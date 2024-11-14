import 'package:flutter/foundation.dart';

/// Model representing the calibration state for the calibration process.
@immutable
class CalibrationState {
  final int numberOfCalibrations;
  final List<double> concentrations;
  final List<double> measurements;
  final int currentStepIndex;
  final bool isCalibrationComplete;
  final bool isCalibrating; // Add this field to control calibration state

  double get progress =>
      numberOfCalibrations > 0 ? (currentStepIndex / numberOfCalibrations) : 0.0;

  const CalibrationState({
    required this.numberOfCalibrations,
    required this.concentrations,
    required this.measurements,
    required this.currentStepIndex,
    required this.isCalibrationComplete,
    required this.isCalibrating,
  });

  /// Creates an initial calibration state with default values.
  factory CalibrationState.initial() {
    return CalibrationState(
      numberOfCalibrations: 0,
      concentrations: [],
      measurements: [],
      currentStepIndex: 0,
      isCalibrationComplete: false,
      isCalibrating: false, // Default to false
    );
  }

  /// Copy method to create a new instance with modified fields.
  CalibrationState copyWith({
    int? numberOfCalibrations,
    List<double>? concentrations,
    List<double>? measurements,
    int? currentStepIndex,
    bool? isCalibrationComplete,
    bool? isCalibrating,
  }) {
    return CalibrationState(
      numberOfCalibrations: numberOfCalibrations ?? this.numberOfCalibrations,
      concentrations: concentrations ?? List.from(this.concentrations),
      measurements: measurements ?? List.from(this.measurements),
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      isCalibrationComplete: isCalibrationComplete ?? this.isCalibrationComplete,
      isCalibrating: isCalibrating ?? this.isCalibrating,
    );
  }
}