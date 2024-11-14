import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../data_display/custom_data_table.dart';
import 'graph_state_provider.dart';
import '../../provider_setup/providers.dart';
import '../../theming/theme_provider.dart';
import 'graph_widget_parameters.dart';
import 'graph_widget_state.dart';

class GraphWidget extends ConsumerWidget {
  final String graphKey;
  final GraphWidgetParameters graphWidgetParameters;
  final GlobalKey lineChartKey;

  GraphWidget({
    Key? key,
    required this.graphKey,
    required this.graphWidgetParameters,
    required this.lineChartKey,
  }) : super(key: ValueKey(graphKey));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeProvider = ref.watch(themeProviderInstance);
    final graphStateProviderInstance = ref.watch(graphStateProvider);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return FutureBuilder<void>(
      future:
          graphStateProviderInstance.addGraph(graphKey, graphWidgetParameters),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error adding graph: ${snapshot.error}'));
        } else {
          final resultGetGraph = graphStateProviderInstance.getGraph(graphKey);
          if (resultGetGraph.isFailure || resultGetGraph.dataIsNull) {
            return Center(child: Text('Graph data is not available...'));
          } else {
            final state = resultGetGraph.data!;
            return Column(
              children: [
                // Real-time display shown only on larger screens
                if (!isSmallScreen) _buildRealTimeDisplay(context, ref, state),

                // Main graph or table display
                Expanded(
                  child: _buildGraphOrTableView(
                    context,
                    ref,
                    state,
                    themeProvider,
                    isSmallScreen,
                  ),
                ),
              ],
            );
          }
        }
      },
    );
  }

  Widget _buildRealTimeDisplay(
      BuildContext context, WidgetRef ref, GraphWidgetState state) {
    final isGraphView = ref.watch(isGraphViewProviderFamily(graphKey));
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (!isGraphView) return SizedBox.shrink();

    final fontSize = isSmallScreen ? (isLandscape ? 8.0 : 10.0) : 18.0;

    return ValueListenableBuilder<double?>(
      valueListenable: state.displayedMeasurement,
      builder: (context, displayedMeasurement, child) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            displayedMeasurement != null
                ? '${displayedMeasurement.toStringAsFixed(2)} ${state.graphWidgetParameters.yAxisUnit}'
                : '',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  Widget _buildGraphOrTableView(
    BuildContext context,
    WidgetRef ref,
    GraphWidgetState state,
    ThemeProvider themeProvider,
    bool isSmallScreen,
  ) {
    final isGraphView = ref.watch(isGraphViewProviderFamily(graphKey));

    List<String> headers = [
      'timestamp_local',
      'timestamp_utc',
      'elapsed_time',
      'value',
    ];

    List<List<String>> dataRows = state.collectedData.map((data) {
      DateTime? startTime = state.startTimeOfRecording;
      double? elapsedTime = data.x;

      String localTimestamp = (startTime != null)
          ? startTime
              .add(Duration(milliseconds: (elapsedTime * 1000).toInt()))
              .toString()
          : 'N/A';

      String utcTimestamp = (startTime != null)
          ? startTime
              .toUtc()
              .add(Duration(milliseconds: (elapsedTime * 1000).toInt()))
              .toString()
          : 'N/A';

      return [
        localTimestamp,
        utcTimestamp,
        elapsedTime.toString(),
        data.y.toString(),
      ];
    }).toList();

    return isGraphView
        ? _buildGraphView(context, state, themeProvider, isSmallScreen)
        : CustomDataTable(
            headers: headers,
            dataRows: dataRows,
            context: context,
            ref: ref,
            enableScrollControls: !isSmallScreen,
          );
  }

  Widget _buildGraphView(BuildContext context, GraphWidgetState state,
      ThemeProvider themeProvider, bool isSmallScreen) {
    return ValueListenableBuilder<List<FlSpot>>(
      valueListenable: state.visibleDataNotifier,
      builder: (context, visibleData, child) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: RepaintBoundary(
            key: lineChartKey,
            child: SizedBox(
              height: isSmallScreen
                  ? MediaQuery.of(context).size.height * 0.7
                  : null,
              child: LineChart(
                LineChartData(
                  backgroundColor: themeProvider.graphBackgroundColor,
                  minX: state.viewStartInSecondsElapsed,
                  maxX: state.viewEndInSecondsElapsed,
                  minY: state.graphWidgetParameters.yMin,
                  maxY: state.graphWidgetParameters.yMax,
                  lineBarsData: [
                    LineChartBarData(
                      spots: visibleData,
                      color: themeProvider.graphLineColor,
                      isCurved: false,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                  lineTouchData: _buildLineTouchData(state),
                  titlesData: _buildTitlesData(state, themeProvider.fontSize),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  LineTouchData _buildLineTouchData(GraphWidgetState state) {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        getTooltipItems: (List<LineBarSpot> touchedSpots) {
          return touchedSpots.map((spot) {
            return LineTooltipItem(
              'Timestamp: ${DateFormat.yMd().add_jm().format(DateTime.fromMillisecondsSinceEpoch(spot.x.toInt()))}\n'
              'Elapsed: ${spot.x} s\n'
              'Value: ${spot.y} ${state.graphWidgetParameters.yAxisUnit}',
              TextStyle(color: Colors.white),
            );
          }).toList();
        },
      ),
    );
  }

  FlTitlesData _buildTitlesData(GraphWidgetState state, double textSize) {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        axisNameWidget: Padding(
          padding: EdgeInsets.only(bottom: textSize * 0.5),
          child: Text(
            '${state.graphWidgetParameters.xAxisLabel} (${state.graphWidgetParameters.xAxisUnit})',
            style: TextStyle(fontSize: textSize),
          ),
        ),
      ),
      leftTitles: AxisTitles(
        axisNameWidget: Padding(
          padding: EdgeInsets.only(right: textSize * 0.5),
          child: Text(
            '${state.graphWidgetParameters.yAxisLabel} (${state.graphWidgetParameters.yAxisUnit})',
            style: TextStyle(fontSize: textSize),
          ),
        ),
      ),
    );
  }
}
