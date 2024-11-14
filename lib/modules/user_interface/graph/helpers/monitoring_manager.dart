import 'dart:async';

class MonitoringManager {
  Timer? _updateTimer;
  StreamSubscription<double>? _dataSubscription;

  bool isMonitoring = false;

  void startMonitoring(Stream<double> dataStream, void Function(double) onData) {
    _updateTimer = Timer.periodic(const Duration(milliseconds: 750), (_) {
      if (isMonitoring) {
        // Periodic monitoring updates
      }
    });
    _dataSubscription = dataStream.listen(onData);
    isMonitoring = true;
  }

  void stopMonitoring() {
    _dataSubscription?.cancel();
    _updateTimer?.cancel();
    isMonitoring = false;
  }

  void dispose() {
    _dataSubscription?.cancel();
    _updateTimer?.cancel();
  }
}