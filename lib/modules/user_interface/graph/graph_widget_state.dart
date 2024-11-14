import 'dart:async';
import 'package:beta_app/enums/common_enums.dart';
import 'package:beta_app/modules/logging/providers/i_logging_provider.dart';
import 'package:beta_app/modules/user_interface/graph/graph_widget_parameters.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../settings/providers/configuration_data_provider.dart';
import '../../bluetooth_management/ble_fluorometer/providers/data_provider.dart';
import '../../theming/theme_provider.dart';
import '../../../utils/common_utils.dart';

class GraphWidgetState extends ChangeNotifier {
  final GraphWidgetParameters _graphWidgetParameters;
  final ILoggingProvider logger;
  final ThemeProvider themeProvider;
  final ConfigurationDataProvider configurationDataProvider;
  final DataProvider? dataProvider;

  final int _maxVisibleDataPoints = 100;
  double _viewStartInSecondsElapsed = 0;
  late double _viewEndInSecondsElapsed = 10;
  late double _viewRangeInSeconds = 10;
  final double _currentMeasurementValue = 0;
  bool _isGraphView = true;
  bool _isRunning = false;
  bool _isDataSaved = false;
  bool _userHasBeenWarnedOfInvalidData = false;

  DateTime? _startTimeOfRecording;
  final List<FlSpot> _collectedData = [];
  List<FlSpot> _visibleData = [FlSpot(0, 0)];
  ValueNotifier<List<FlSpot>> visibleDataNotifier = ValueNotifier([]);
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  GlobalKey? _lineChartKey;
  final ValueNotifier<double?> _displayedMeasurement = ValueNotifier(null);
  double? _latestBufferedValue;
  Timer? _updateTimer;
  StreamSubscription<double>? _dataSubscription;

  bool get isRunning => _isRunning;
  bool get isRealTime => _graphWidgetParameters.isRealTime;
  double get viewStartInSecondsElapsed => _viewStartInSecondsElapsed;
  double get viewEndInSecondsElapsed => _viewEndInSecondsElapsed;
  List<FlSpot> get visibleData => _visibleData;
  GlobalKey get lineChartKey {
    return _lineChartKey ?? GlobalKey();
  }

  bool get isGraphView => _isGraphView;
  List<FlSpot> get collectedData => _collectedData;
  double get currentMeasurementValue => _currentMeasurementValue;
  ValueNotifier<double?> get displayedMeasurement => _displayedMeasurement;
  DateTime? get startTimeOfRecording => _startTimeOfRecording;
  GraphWidgetParameters get graphWidgetParameters => _graphWidgetParameters;

  // Constructor with injected dependencies
  GraphWidgetState({
    required GraphWidgetParameters graphWidgetParameters,
    required this.logger,
    required this.themeProvider,
    required this.configurationDataProvider,
    this.dataProvider,
  }) : _graphWidgetParameters = graphWidgetParameters;

  void initStateManagement() {
    _updateTimer = Timer.periodic(const Duration(milliseconds: 750), (timer) {
      if (_latestBufferedValue != null) {
        _displayedMeasurement.value = _latestBufferedValue;
        notifyListeners();
      }
    });
  }

  void updateVisibleData(List<FlSpot> newData) {
    if (isRealTime) {
      _visibleData = newData;
      logger.logInfo(
          'Updated visible data for $_graphWidgetParameters.measurementTitle with ${newData.length} points.');
    }
  }

  void updateDefaultViewRange(double newRange) {
    configurationDataProvider.setDefaultViewRangeInSeconds(newRange);
  }

  void _addData(double newDataPoint) {
    if (_isRunning) {
      _collectedData
          .add(FlSpot(_stopwatch.elapsedMilliseconds / 1000, newDataPoint));

      _latestBufferedValue = newDataPoint;

      // calculate the elapsed time in seconds:
      double elapsedTimeInSeconds = _stopwatch.elapsed.inMilliseconds / 1000;

      // calculate half of the view range:
      double halfViewRange = _viewRangeInSeconds / 2;

      // adjust the view by scrolling in multiples of half the view range:
      if (elapsedTimeInSeconds >= viewEndInSecondsElapsed) {
        _viewEndInSecondsElapsed += halfViewRange;
      }

      // adjust the view to start from the new end minus the view range:
      adjustView(viewEndInSecondsElapsed - _viewRangeInSeconds,
          viewEndInSecondsElapsed);
    }
  }

  void _updateVisibleData() {
    if (_collectedData.isNotEmpty) {
      double sessionStartTimeInSecondsFromEpoch =
          CommonUtils.getSessionStartTimeInSecondsFromEpochUtc(_collectedData);

      List<FlSpot> updatedVisibleData = _collectedData
          .where((spot) => CommonUtils.isInViewRange(
              spot.x,
              sessionStartTimeInSecondsFromEpoch,
              viewStartInSecondsElapsed,
              viewEndInSecondsElapsed))
          .map((spot) {
            double elapsedTimeInSeconds =
                CommonUtils.convertToElapsedTimeInSeconds(
                    spot.x, sessionStartTimeInSecondsFromEpoch);
            return FlSpot(elapsedTimeInSeconds, spot.y);
          })
          .where((spot) => !(spot.x == 0.0 && spot.y == 0.0))
          .toList(); // avoid initial zero values

      // handle the missing viewStart point:
      if (!updatedVisibleData
          .any((spot) => spot.x == viewStartInSecondsElapsed)) {
        FlSpot? beforeStart;
        FlSpot? afterStart;

        for (var spot in _collectedData) {
          double elapsedTimeInSeconds =
              CommonUtils.convertToElapsedTimeInSeconds(
                  spot.x, sessionStartTimeInSecondsFromEpoch);
          if (elapsedTimeInSeconds < viewStartInSecondsElapsed) {
            beforeStart = spot;
          } else if (elapsedTimeInSeconds > viewStartInSecondsElapsed &&
              afterStart == null) {
            afterStart = spot;
            break;
          }
        }

        if (beforeStart != null && afterStart != null) {
          double interpolatedY =
              CommonUtils.interpolateY(beforeStart, afterStart);

          updatedVisibleData.insert(
              0, FlSpot(viewStartInSecondsElapsed, interpolatedY));
        }
      }

      _visibleData = updatedVisibleData;
      visibleDataNotifier.value = updatedVisibleData;
    }
  }

  void adjustView(double startInSecondsElapsed, double endInSecondsElapsed) {
    if (_collectedData.isNotEmpty) {
      if (!_isRunning) {
        double sessionStartTime = 0;
        double lastDataPoint = CommonUtils.convertToElapsedTimeInSeconds(
            _collectedData.isNotEmpty ? _collectedData.last.x : 0,
            _collectedData.first.x);

        if (startInSecondsElapsed < sessionStartTime) {
          startInSecondsElapsed = sessionStartTime;
          endInSecondsElapsed = sessionStartTime + _viewRangeInSeconds;
        } else if (endInSecondsElapsed > lastDataPoint) {
          startInSecondsElapsed = endInSecondsElapsed - _viewRangeInSeconds;
        }
      }
      _viewStartInSecondsElapsed = startInSecondsElapsed;
      _viewEndInSecondsElapsed = endInSecondsElapsed;
      _updateVisibleData();
    }
  }

  void adjustViewRange(double increment) {
    _viewRangeInSeconds += increment;
    if (_viewRangeInSeconds < 1) {
      _viewRangeInSeconds = 1; // Minimum view range
      updateDefaultViewRange(_viewRangeInSeconds);
    }
    double start = viewEndInSecondsElapsed - _viewRangeInSeconds;
    if (start < 0) {
      start = 0;
      _viewEndInSecondsElapsed = _viewRangeInSeconds;
    }

    _viewStartInSecondsElapsed = start;
    _updateVisibleData();
  }

  void toggleIsGraphView() {
    _isGraphView = !_isGraphView;
  }

  void scrollGraphLeft() {
    if (!_isRunning) {
      double start = CommonUtils.convertToElapsedTimeInSeconds(
          (_viewStartInSecondsElapsed - _viewRangeInSeconds < 0)
              ? 0
              : _viewStartInSecondsElapsed - _viewRangeInSeconds,
          0);
      double end = start + _viewRangeInSeconds;
      adjustView(start, end);
    }
  }

  void scrollGraphRight() {
    if (!_isRunning) {
      double end = viewEndInSecondsElapsed + _viewRangeInSeconds;
      double lastDataPoint = CommonUtils.convertToElapsedTimeInSeconds(
          collectedData.isNotEmpty ? collectedData.last.x : 0,
          collectedData.first.x);
      if (viewEndInSecondsElapsed < lastDataPoint) {
        adjustView(viewEndInSecondsElapsed, end);
      }
    }
  }

  void zoomGraphOut() {
    _viewRangeInSeconds =
        (_viewRangeInSeconds * 1.2).clamp(10, double.infinity); // Zoom out
    updateDefaultViewRange(_viewRangeInSeconds);
    adjustView(viewStartInSecondsElapsed,
        _viewStartInSecondsElapsed + _viewRangeInSeconds);
  }

  void zoomGraphIn() {
    _viewRangeInSeconds =
        (_viewRangeInSeconds / 1.2).clamp(10, double.infinity); // Zoom in
    updateDefaultViewRange(_viewRangeInSeconds);
    adjustView(_viewStartInSecondsElapsed,
        _viewStartInSecondsElapsed + _viewRangeInSeconds);
  }

  void startMonitoring() {
    if (isRealTime && dataProvider != null) {
      clearData();
      _userHasBeenWarnedOfInvalidData = false;

      _startTimeOfRecording = DateTime.now();
      _stopwatch = Stopwatch()..start();

      _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {});
      _isRunning = true;
      _isDataSaved = false;

      dataProvider?.resume();

      // start listening to the data source in the data provider:
      switch (_graphWidgetParameters.measurementType) {
        // Store the latest value:
        case MeasurementType.fluoride:
          _dataSubscription =
              _dataSubscription = dataProvider?.fluorideStream.listen((spot) {
            _addData(spot);
          });
          break;
        case MeasurementType.temperature:
          _dataSubscription = _dataSubscription =
              dataProvider?.temperatureStream.listen((spot) {
            _addData(spot);
          });
          break;
        case MeasurementType.ph:
          _dataSubscription =
              _dataSubscription = dataProvider?.phStream.listen((spot) {
            _addData(spot);
          });
          break;
        case MeasurementType.realTime:
          // TODO: Handle this case.
          break;
        case MeasurementType.graph:
          // TODO: Handle this case.
          break;
        case MeasurementType.data:
          // TODO: Handle this case.
      }
    }
  }

  void stopMonitoring() {
    if (_graphWidgetParameters.isRealTime) {
      _isRunning = false;
      _dataSubscription?.cancel();
      _timer?.cancel();
      _stopwatch.stop();

      notifyListeners();
    }
  }

  bool hasUnsavedData() {
    return (!_isDataSaved && collectedData.isNotEmpty);
  }

  void clearData() {
    _startTimeOfRecording = null;
    _collectedData.clear();
    _viewStartInSecondsElapsed = 0;
    _viewEndInSecondsElapsed = _viewRangeInSeconds;
    _isDataSaved = true;
  }

  @override
  void dispose() {
    super.dispose();
    //subscription?.cancel();
    _dataSubscription?.cancel();
    _stopwatch.stop();
    _timer?.cancel();
  }
}
