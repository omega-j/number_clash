import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../provider_setup/providers.dart';
import '../../../../router/router.dart';

@RoutePage()
class CalibrationCompletionPage extends ConsumerWidget {
  CalibrationCompletionPage({Key? key}) : super(key: key ?? UniqueKey());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calibrationState = ref.watch(calibrationProvider);
    final calibration = ref.read(calibrationProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calibration Complete'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Congratulations!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Your device has been successfully calibrated.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Calibration Data:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...List.generate(calibrationState.numberOfCalibrations, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Point ${index + 1}:'),
                    Text(
                        'Concentration: ${calibrationState.concentrations[index]}'),
                    Text(
                        'Measurement: ${calibrationState.measurements[index]}'),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                calibration.restartCalibration();
                context.router.push(CalibrationRoute());
              },
              child: const Text('Redo Calibration'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                context.router.push(RealTimeDataRoute());
              },
              child: const Text('Proceed to Real-Time Data'),
            ),
          ],
        ),
      ),
    );
  }
}
