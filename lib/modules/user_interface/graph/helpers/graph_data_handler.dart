import 'package:fl_chart/fl_chart.dart';

class GraphDataHandler {
  final List<FlSpot> _collectedData = [];

  List<FlSpot> get collectedData => _collectedData;

  void addDataPoint(double x, double y) {
    _collectedData.add(FlSpot(x, y));
  }

  List<FlSpot> calculateVisibleData(double viewStart, double viewEnd) {
    // Logic fi filter and return visible data within di view range
    return _collectedData.where((spot) => spot.x >= viewStart && spot.x <= viewEnd).toList();
  }

  void clearData() {
    _collectedData.clear();
  }
}