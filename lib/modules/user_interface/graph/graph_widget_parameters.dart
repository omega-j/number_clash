import 'package:beta_app/enums/common_enums.dart';
import 'package:fl_chart/fl_chart.dart';

/// A model class to encapsulate parameters for configuring a graph.
///
/// This class helps manage all the necessary values required to render a graph,
/// ensuring that the graph widget receives a single cohesive object with all
/// the relevant data.
class GraphWidgetParameters {
  /// The type of measurement represented in the graph (e.g., temperature, pressure).
  final MeasurementType measurementType;

  /// The label for the x-axis, typically representing the independent variable.
  final String xAxisLabel;

  /// The label for the y-axis, typically representing the dependent variable.
  final String yAxisLabel;

  /// The unit of measurement for the x-axis (e.g., seconds, meters).
  final String xAxisUnit;

  /// The unit of measurement for the y-axis (e.g., degrees Celsius, pascals).
  final String yAxisUnit;

  /// The minimum value on the y-axis; helps define the scale of the graph.
  final double yMin;

  /// The maximum value on the y-axis; helps define the scale of the graph.
  final double yMax;

  /// The title of the measurement being represented, which may be displayed above the graph.
  final String measurementTitle;

  /// A boolean indicating if the graph displays real-time data.
  final bool isRealTime;

  /// A list of static data points to display on the graph.
  ///
  /// This list contains [FlSpot] points that represent data values to be plotted
  /// statically on the graph, typically used for historical or non-dynamic data.
  /// If null, no static data will be displayed.
  final List<FlSpot>? staticData;

  /// Creates a new instance of [GraphWidgetParameters].
  ///
  /// All parameters are required to ensure that the graph can be rendered correctly,
  /// except for [staticData], which is optional and can be null if static data is not needed.
  GraphWidgetParameters({
    required this.measurementType,
    required this.xAxisLabel,
    required this.yAxisLabel,
    required this.xAxisUnit,
    required this.yAxisUnit,
    required this.yMin,
    required this.yMax,
    required this.measurementTitle,
    required this.isRealTime,
    this.staticData, // Made optional by using a nullable type
  });
}