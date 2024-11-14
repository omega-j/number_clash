import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../router/router.dart';
import '../models/calibration_data.dart';

@RoutePage()
class CalibrationDataPage extends ConsumerWidget {
  CalibrationDataPage({Key? key}) : super(key: key ?? UniqueKey());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('calibration_data_page')),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'settings') {
                context.router.push(SettingsRoute());
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'settings',
                child: Text(tr('settings')),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('calibration_data_overview'),
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            // Expanded(
            //   child: ref.watch(calibrationProvider).when(
            //     data: (data) => _buildDataTable(data, theme),
            //     loading: () => Center(child: CircularProgressIndicator()),
            //     error: (err, stack) => Center(child: Text(tr('data_load_error'))),
            //   ),
            // ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCalibrationOptions(context);
        },
        tooltip: tr('add_calibration_data'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDataTable(List<CalibrationData> data, ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text(tr('date'), style: theme.textTheme.titleSmall)),
          DataColumn(label: Text(tr('measurement'), style: theme.textTheme.titleSmall)),
          DataColumn(label: Text(tr('unit'), style: theme.textTheme.titleSmall)),
          DataColumn(label: Text(tr('value'), style: theme.textTheme.titleSmall)),
        ],
        rows: data
            .map((item) => DataRow(
                  cells: [
                    DataCell(Text(DateFormat.yMMMd().format(item.date))),
                    DataCell(Text(item.measurementType)),
                    DataCell(Text(item.unit)),
                    DataCell(Text(item.value.toString())),
                  ],
                ))
            .toList(),
      ),
    );
  }

  void _showCalibrationOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.save),
                title: Text(tr('save_data')),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.file_download),
                title: Text(tr('export_data')),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}