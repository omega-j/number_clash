import 'package:auto_route/auto_route.dart';
import 'package:beta_app/enums/common_enums.dart';
import 'package:beta_app/modules/user_interface/graph/graph_widget_parameters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../modules/localization/providers/i_localization_provider.dart';
import '../modules/provider_setup/providers.dart';
import '../modules/user_interface/graph/graph_state_provider.dart';
import '../modules/user_interface/graph/graph_widget.dart';
import '../modules/user_interface/graph/graph_widget_state.dart';
import '../widgets/feedback_form.dart';
import '../../../models/common/result.dart';
import '../../../utils/user_interface_utils.dart';

@RoutePage()
class RealTimeDataPage extends ConsumerWidget {
  RealTimeDataPage({Key? key}) : super(key: key ?? UniqueKey());

  final GlobalKey lineChartKey = GlobalKey();
  static const String graphKey = "realTimeDataGraph";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localization = ref.watch(localizationProvider.notifier);
    final sessionController = ref.read(sessionControllerProvider.notifier);
    final sessionState = ref.watch(sessionControllerProvider);

    if (!sessionState.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        sessionController.startSession();
      });
    }

    final graphStateProviderInstance = ref.watch(graphStateProvider);
    final isGraphView = ref.watch(isGraphViewProviderFamily(graphKey));
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final graphWidgetParametersFluoride = GraphWidgetParameters(
      measurementType: MeasurementType.fluoride,
      xAxisLabel: localization.translate('time'),
      yAxisLabel: localization.translate('concentration'),
      xAxisUnit: localization.translate('s'),
      yAxisUnit: localization.translate('ppb'),
      yMin: 0,
      isRealTime: true,
      yMax: 1,
      measurementTitle:
          localization.translate('measurement_of_fluoride_concentration'),
    );

    final graphAddResult = graphStateProviderInstance.addGraph(
        graphKey, graphWidgetParametersFluoride);
    final graphStateResult = graphStateProviderInstance.getGraph(graphKey);

    if (graphStateResult.isFailure || graphStateResult.dataIsNull) {
      return Center(child: Text('Graph data is not available...'));
    }

    final state = graphStateResult.data!;

    return Scaffold(
      appBar: isLandscape
          ? null
          : AppBar(
              title: Text(localization.translate('real_time_data_page')),
              actions: [
                IconButton(
                  icon: Icon(Icons.feedback),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => FeedbackForm(),
                  ),
                ),
              ],
            ),
      body: Column(
        children: [
          _buildTopControlBar(
              context, ref, state, isGraphView, localization, isLandscape),
          Expanded(
            child: Center(
              child: GraphWidget(
                graphKey: graphKey,
                lineChartKey: lineChartKey,
                graphWidgetParameters: graphWidgetParametersFluoride,
              ),
            ),
          ),
          if (!isLandscape)
            _buildBottomControlBar(
                context, ref, state, isGraphView, localization),
        ],
      ),
    );
  }

  Widget _buildTopControlBar(
    BuildContext context,
    WidgetRef ref,
    GraphWidgetState state,
    bool isGraphView,
    ILocalizationProvider localization,
    bool isLandscape,
  ) {
    final sessionController = ref.read(sessionControllerProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      constraints: BoxConstraints(
        maxHeight: isLandscape ? 48.0 : 60.0,
      ),
      child: Wrap(
        spacing: 4.0,
        alignment: WrapAlignment.center,
        children: [
          if (!state.isRunning)
            Semantics(
              label: localization.translate('toggle_view'),
              child: IconButton(
                icon: Icon(isGraphView ? Icons.table_chart : Icons.show_chart),
                iconSize: 20.0,
                onPressed: () => ref
                    .read(graphStateProvider)
                    .toggleIsGraphView(graphKey, ref),
                tooltip: localization.translate('toggle_view'),
              ),
            ),
          // Inside dee RealTimeDataPage's control bar
          if (!state.isRunning && isGraphView)
            Semantics(
              label: localization.translate('save_data'),
              child: IconButton(
                icon: Icon(Icons.save),
                iconSize: 20.0,
                onPressed: () async {
                  if (sessionController.sessionId.isEmpty) {
                    _showSessionWarning(context);
                    return;
                  }
                  final saveResult = await ref
                      .read(graphStateProvider)
                      .saveData(graphKey, sessionController.sessionId);

                  if (saveResult.isSuccessful) {
                    sessionController.markComplete();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Data saved and session marked complete!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to save session data.')),
                    );
                  }
                },
                tooltip: localization.translate('save_data'),
              ),
            ),
          if (!state.isRunning && isGraphView)
            Semantics(
              label: localization.translate('export_image'),
              child: IconButton(
                icon: Icon(Icons.camera_alt),
                iconSize: 20.0,
                onPressed: () async {
                  if (sessionController.sessionId.isEmpty) {
                    _showSessionWarning(context);
                    return;
                  }
                  await ref
                      .read(graphStateProvider)
                      .exportImage(lineChartKey, sessionController.sessionId);
                },
                tooltip: localization.translate('export_image'),
              ),
            ),
          if (isLandscape) ...[
            _buildNavigationControls(context, ref, localization),
          ]
        ],
      ),
    );
  }

  Widget _buildBottomControlBar(
    BuildContext context,
    WidgetRef ref,
    GraphWidgetState state,
    bool isGraphView,
    ILocalizationProvider localization,
  ) {
    final sessionController = ref.read(sessionControllerProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isGraphView) _buildNavigationControls(context, ref, localization),
        if (state.isRealTime && isGraphView)
          Semantics(
            label: state.isRunning
                ? localization.translate('stop_recording')
                : localization.translate('start_recording'),
            child: IconButton(
              icon: state.isRunning
                  ? Icon(Icons.stop)
                  : Icon(Icons.circle, color: Colors.red),
              onPressed: () async {
                if (state.isRunning) {
                  sessionController.endSession();
                  ref.read(graphStateProvider).stopMonitoring(graphKey);
                  bool shouldSave = await _showSaveModal(context, ref);
                  if (shouldSave) {
                    if (sessionController.state != null) {
                      await ref.read(graphStateProvider).saveData(
                          graphKey, sessionController.state.sessionId);

                      // Check if the context is still mounted before using it
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Data saved successfully!')),
                        );
                      }
                    } else {
                      // Use context only after ensuring it's mounted
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Session ID is not set.')),
                        );
                      }
                    }
                  }
                } else {
                  sessionController.startSession();
                  ref.read(graphStateProvider).startMonitoring(graphKey);
                }
              },
            ),
          ),
      ],
    );
  }

  Widget _buildNavigationControls(
    BuildContext context,
    WidgetRef ref,
    ILocalizationProvider localization,
  ) {
    return Wrap(
      spacing: 4.0,
      children: [
        UserInterfaceUtils.buildIconButton(
          context,
          ref,
          icon: Icons.zoom_out,
          labelKey: 'zoom_out',
          onPressed: () {
            final result = ref.read(graphStateProvider).zoomGraphOut(graphKey);
            if (result.isFailure) {
              UserInterfaceUtils.showErrorMessage(context, result.message);
            }
          },
        ),
        UserInterfaceUtils.buildIconButton(
          context,
          ref,
          icon: Icons.zoom_in,
          labelKey: 'zoom_in',
          onPressed: () {
            final result = ref.read(graphStateProvider).zoomGraphIn(graphKey);
            if (result.isFailure) {
              UserInterfaceUtils.showErrorMessage(context, result.message);
            }
          },
        ),
        UserInterfaceUtils.buildIconButton(
          context,
          ref,
          icon: Icons.arrow_back,
          labelKey: 'scroll_left',
          onPressed: () {
            final result =
                ref.read(graphStateProvider).scrollGraphLeft(graphKey);
            if (result.isFailure) {
              UserInterfaceUtils.showErrorMessage(context, result.message);
            }
          },
        ),
        UserInterfaceUtils.buildIconButton(
          context,
          ref,
          icon: Icons.arrow_forward,
          labelKey: 'scroll_right',
          onPressed: () {
            final result =
                ref.read(graphStateProvider).scrollGraphRight(graphKey);
            if (result.isFailure) {
              UserInterfaceUtils.showErrorMessage(context, result.message);
            }
          },
        ),
      ],
    );
  }

  Future<bool> _showSaveModal(BuildContext context, WidgetRef ref) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Unsaved Data'),
          content: Text('Would you like to save the data?'),
          actions: [
            TextButton(
              child: Text('Yes'),
              onPressed: () async {
                await ref.read(graphStateProvider).saveData(
                    graphKey, ref.read(sessionControllerProvider).sessionId);
                Navigator.of(context).pop(true);
              },
            ),
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    ).then((result) => result ?? false);
  }

  void _showSessionWarning(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('No active session. Please start a session first.'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
