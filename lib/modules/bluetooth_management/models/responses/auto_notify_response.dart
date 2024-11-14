import '../../utils/bluetooth_fluometer_constants.dart';

class AutoNotifyResponse {
  final double amplitude;
  final double compensatedConcentration;
  final double uncompensatedConcentration;
  final double temperature;
  final double analogOutput;
  final int checksum;

  AutoNotifyResponse({
    required this.amplitude,
    required this.compensatedConcentration,
    required this.uncompensatedConcentration,
    required this.temperature,
    required this.analogOutput,
    required this.checksum,
  });

  factory AutoNotifyResponse.fromData(List<int> data) {
    if (data.length != 19 || data[0] != 0x03) {
      throw ArgumentError("Invalid data for AutoNotifyResponse");
    }

    final amplitude =
        BluetoothFluorometerConstants.parseFloat(data.sublist(2, 6));
    final compensatedConcentration =
        BluetoothFluorometerConstants.parseFloat(data.sublist(6, 10));
    final uncompensatedConcentration =
        BluetoothFluorometerConstants.parseFloat(data.sublist(10, 14));
    final temperature = _parseTemperature(data.sublist(14, 16));
    final analogOutput = _parseAnalogOutput(data.sublist(16, 18));
    final checksum = data[18];

    return AutoNotifyResponse(
      amplitude: amplitude,
      compensatedConcentration: compensatedConcentration,
      uncompensatedConcentration: uncompensatedConcentration,
      temperature: temperature,
      analogOutput: analogOutput,
      checksum: checksum,
    );
  }

  static double _parseTemperature(List<int> bytes) {
    return ((bytes[0] << 8) | bytes[1]) / 100.0;
  }

  static double _parseAnalogOutput(List<int> bytes) {
    return ((bytes[0] << 8) | bytes[1]) / 1000.0;
  }

  @override
  String toString() {
    return 'Auto Notify Response - Amplitude: $amplitude mV, Compensated Concentration: $compensatedConcentration ppb, '
        'Uncompensated Concentration: $uncompensatedConcentration ppb, Temperature: $temperature °C, '
        'Analog Output: $analogOutput mA, Checksum: $checksum';
  }
}
