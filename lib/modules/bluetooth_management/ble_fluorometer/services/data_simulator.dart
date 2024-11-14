import 'dart:async';
import 'dart:math';

class DataSimulator {
  final StreamController<Map<String, double>> _dataController =
      StreamController<Map<String, double>>.broadcast();

  Stream<Map<String, double>> get dataStream => _dataController.stream;

  DataSimulator() {
    _startSimulation();
  }

  void _startSimulation() {
    Timer.periodic(Duration(milliseconds: _generateRandomInterval()),
        (Timer timer) {
      // Simulate byte stream data as a packet, with each value parsed:
      double fluorideValue = _generateYValue(0.34, 0.25, 0.45);
      double temperatureValue = _generateYValue(20.0, 15.0, 25.0);
      double phValue = _generateYValue(7.0, 6.5, 7.5);

      // Bundle values into a packet and broadcast:
      _dataController.add({
        CommonStrings.fluoride: fluorideValue,
        CommonStrings.temperature: temperatureValue,
        CommonStrings.ph: phValue,
      });
    });
  }

  double _generateYValue(double seedValue, double minValue, double maxValue) {
    double result;
    double varianceValue = (maxValue - minValue) / 2;
    bool addOrSubtract = Random().nextBool();
    double multiplicationCoefficient = Random().nextDouble();
    if (addOrSubtract) {
      result = seedValue + (varianceValue * multiplicationCoefficient);
    } else {
      result = seedValue - (varianceValue * multiplicationCoefficient);
    }
    return result.clamp(minValue, maxValue);
  }

  int _generateRandomInterval() {
    // Random interval between 80ms and 120ms to mimic realistic variability
    return 80 + Random().nextInt(40);
  }

  void stopSimulation() {
    _dataController.close();
  }
}

class CommonStrings {
// Measurement Related:
  static const fluoride = 'fluoride';
  static const temperature = 'temperature';
  static const ph = 'ph';
}
