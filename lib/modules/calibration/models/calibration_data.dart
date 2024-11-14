// calibration_data.dart

class CalibrationData {
  final DateTime date;
  final String measurementType;
  final String unit;
  final double value;

  CalibrationData({
    required this.date,
    required this.measurementType,
    required this.unit,
    required this.value,
  });

  // Optional: A factory constructor to parse from a map, if needed
  factory CalibrationData.fromMap(Map<String, dynamic> map) {
    return CalibrationData(
      date: DateTime.parse(map['date'] as String),
      measurementType: map['measurementType'] as String,
      unit: map['unit'] as String,
      value: map['value'] as double,
    );
  }

  // Optional: Convert the model to a map, if needed for storage or export
  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'measurementType': measurementType,
      'unit': unit,
      'value': value,
    };
  }

  // Example of a string representation for debugging purposes
  @override
  String toString() {
    return 'CalibrationData(date: $date, measurementType: $measurementType, unit: $unit, value: $value)';
  }
}
