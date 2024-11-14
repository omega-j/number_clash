import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../provider_setup/providers.dart';
import '../../../../router/router.dart';

@RoutePage()
class CalibrationPage extends ConsumerWidget {
  CalibrationPage({Key? key}) : super(key: key ?? UniqueKey());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calibrationState = ref.watch(calibrationProvider);
    final calibration = ref.read(calibrationProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calibration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Calibration Process',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Select the number of calibration points.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            // Wrapping the dropdown in a SizedBox to constrain height and width
            SizedBox(
              width: double.infinity,
              child: DropdownButtonFormField<int>(
                hint: const Text('Choose number of calibration points'),
                value: calibrationState.numberOfCalibrations > 0
                    ? calibrationState.numberOfCalibrations
                    : null,
                items: List.generate(9, (index) => index + 2)
                    .map((value) => DropdownMenuItem(
                          value: value,
                          child: Text('$value Points'),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    calibration.setNumberOfCalibrations(value);
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            ...List.generate(calibrationState.numberOfCalibrations, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Calibration Point ${index + 1} Concentration',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    final concentration = double.tryParse(value) ?? 0.0;
                    calibration.setCalibrationPoint(index, concentration);
                  },
                ),
              );
            }),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: calibrationState.numberOfCalibrations > 0
                  ? () {
                      calibration.beginCalibration();
                      context.router.push(CalibrationStepRoute());
                    }
                  : null,
              child: const Text('Begin Calibration'),
            ),
          ],
        ),
      ),
    );
  }
}
