import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'graph_data_handler.dart';
import 'graph_view_manager.dart';
import 'monitoring_manager.dart';

class GraphWidgetState extends ChangeNotifier {
  final GraphDataHandler dataHandler = GraphDataHandler();
  final GraphViewManager viewManager = GraphViewManager();
  final MonitoringManager monitoringManager = MonitoringManager();

  void addData(double x, double y) {
    dataHandler.addDataPoint(x, y);
    updateVisibleData();
  }

  void updateVisibleData() {
    final visibleData = dataHandler.calculateVisibleData(viewManager.viewStart, viewManager.viewEnd);
    // Update di UI or notify listeners
  }

  void startMonitoring(Stream<double> dataStream) {
    monitoringManager.startMonitoring(dataStream, (data) => addData(data, data)); // Example
  }

  void stopMonitoring() {
    monitoringManager.stopMonitoring();
  }

  @override
  void dispose() {
    monitoringManager.dispose();
    super.dispose();
  }
}