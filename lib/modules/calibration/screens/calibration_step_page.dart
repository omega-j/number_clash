import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../provider_setup/providers.dart';
import '../../../../router/router.dart';

@RoutePage()
class CalibrationStepPage extends ConsumerWidget {
  CalibrationStepPage({Key? key})
      : super(key: key ?? UniqueKey());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calibrationState = ref.watch(calibrationProvider);
    final controller = ref.read(calibrationProvider.notifier);

    // Redirect to CalibrationCompletionRoute if we reach the end of steps
    if (calibrationState.currentStepIndex >=
        calibrationState.numberOfCalibrations) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.router.replace(CalibrationCompletionRoute());
      });
      return const SizedBox(); // Return an empty widget temporarily
    }

    // Check if currentStepIndex is within bounds of concentrations
    final currentConcentration = calibrationState.concentrations.length > calibrationState.currentStepIndex
        ? calibrationState.concentrations[calibrationState.currentStepIndex]
        : 0.0; // Fallback value

    final currentMeasurement = calibrationState.measurements.isNotEmpty &&
            calibrationState.measurements.length > calibrationState.currentStepIndex
        ? calibrationState.measurements[calibrationState.currentStepIndex]
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calibration Step ${calibrationState.currentStepIndex + 1} / ${calibrationState.numberOfCalibrations}',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: calibrationState.progress,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 20),
            Text(
              'Step ${calibrationState.currentStepIndex + 1}: Measure Concentration $currentConcentration',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Insert the sensor into the specified concentration sample and take a measurement.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            if (currentMeasurement != null)
              Text(
                'Measurement: $currentMeasurement',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await controller.takeMeasurement();
                  },
                  child: const Text('Take Measurement'),
                ),
                if (currentMeasurement != null)
                  ElevatedButton(
                    onPressed: () async {
                      controller.nextStep();
                      if (calibrationState.currentStepIndex >=
                          calibrationState.numberOfCalibrations - 1) {
                        context.router.replace(CalibrationCompletionRoute());
                      }
                    },
                    child: Text(
                      calibrationState.currentStepIndex <
                              calibrationState.numberOfCalibrations - 1
                          ? 'Next Step'
                          : 'Complete Calibration',
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}