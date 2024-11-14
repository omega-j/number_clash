import 'dart:convert';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../database/models/data_record.dart';
import '../../provider_setup/providers.dart';
import '../models/database_data_file.dart';
import '../providers/data_management_provider.dart';
import 'package:fl_chart/fl_chart.dart';

@RoutePage()
class DataManagementPage extends ConsumerWidget {
  DataManagementPage({Key? key}) : super(key: key ?? UniqueKey());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataManagementProvider = ref.watch(dataManagementProviderProvider);
    final localization = ref.watch(localizationProvider.notifier);
    final theme = Theme.of(context);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    // Define sessionType, either as a constant or dynamically as needed
    const String sessionType =
        'your_session_type'; // Replace with the actual session type or fetch dynamically

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(dataManagementProviderProvider.notifier)
          .loadDataFiles(sessionType: sessionType);
    });

    return Scaffold(
      appBar: isLandscape
          ? null
          : AppBar(
              title: Text(localization.translate('data_management_page')),
            ),
      body: Column(
        children: [
          _buildToggleButton(ref, dataManagementProvider),
          Expanded(
            child: _buildMainContent(
                context, ref, dataManagementProvider, theme, isLandscape),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
      WidgetRef ref, DataManagementProvider dataManagementProvider) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Show Images Only"),
          Switch(
            value: dataManagementProvider.showImagesOnly,
            onChanged: (value) => dataManagementProvider.toggleShowImages(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(
      BuildContext context,
      WidgetRef ref,
      DataManagementProvider dataManagementProvider,
      ThemeData theme,
      bool isLandscape) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildDataRecordsTable(context, ref, dataManagementProvider),
          if (dataManagementProvider.previewedFile != null)
            _buildFilePreview(context, dataManagementProvider),
        ],
      ),
    );
  }

  Widget _buildDataRecordsTable(BuildContext context, WidgetRef ref,
      DataManagementProvider dataManagementProvider) {
    final headers = dataManagementProvider.tableHeaders;
    final dataRows = dataManagementProvider.filteredFiles;

    return Table(
      columnWidths: {
        0: FlexColumnWidth(),
        1: FlexColumnWidth(),
        2: FlexColumnWidth(),
        3: FixedColumnWidth(
            48.0), // Width for the actions cell to ensure uniformity
      },
      children: [
        TableRow(
          children: [
            for (var header in headers) _buildTableHeader(header),
            _buildTableHeader("Actions"), // Adding header for actions column
          ],
        ),
        for (var i = 0; i < dataRows.length; i++)
          TableRow(
            children: [
              _buildTableCell(dataRows[i].fileName, i % 2 == 0, context),
              _buildTableCell(
                  dataRows[i].measurementType.toString(), i % 2 == 0, context),
              _buildTableCell(
                DateFormat.yMd().add_Hm().format(dataRows[i].creationDate),
                i % 2 == 0,
                context,
              ),
              _buildActionsCell(
                  context, ref, dataRows[i]), // Actions cell for each row
            ],
          ),
      ],
    );
  }

  Widget _buildActionsCell(
      BuildContext context, WidgetRef ref, DatabaseDataFile dataFile) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        final notifier = ref.read(dataManagementProviderProvider.notifier);
        if (value == 'Preview') {
          notifier.previewFile(dataFile.fileName);
          _showPreviewModal(context, ref.read(dataManagementProviderProvider));
        } else if (value == 'Share') {
          notifier.shareFile(dataFile.fileName);
        } else if (value == 'Delete') {
          notifier.markFileAsDeleted(dataFile.fileName);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: 'Preview', child: Text('Preview')),
        PopupMenuItem(value: 'Share', child: Text('Share')),
        PopupMenuItem(value: 'Delete', child: Text('Delete')),
      ],
      icon: Icon(Icons.more_vert, size: 20),
    );
  }

  void _showPreviewModal(
      BuildContext context, DataManagementProvider dataManagementProvider) {
    final previewedFile = dataManagementProvider.previewedFile;

    if (previewedFile == null) {
      return;
    }

    // If the file is JSON, convert data to spots before building the widget tree
    List<FlSpot> spots = [];
    if (previewedFile.isJson && previewedFile.data != null) {
      spots = _convertJsonToSpots(previewedFile.data!);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Preview: ${previewedFile.fileName}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                if (previewedFile.isJson) ...[
                  if (previewedFile.data != null) ...[
                    // Check if spots have data to display
                    if (spots.isNotEmpty)
                      SizedBox(
                        height: 250,
                        child: LineChart(LineChartData(
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              barWidth: 2,
                            ),
                          ],
                          titlesData: FlTitlesData(show: true),
                          borderData: FlBorderData(show: true),
                        )),
                      )
                    else
                      Text("No valid data points available for JSON preview."),
                  ] else
                    Text("No data available for JSON preview."),
                ] else if (previewedFile.isImage) ...[
                  if (previewedFile.binaryData != null)
                    Image.memory(previewedFile.binaryData!)
                  else
                    Text("No binary data available for image preview."),
                ] else
                  Text("No preview available for this file."),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("Close"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTableHeader(String label) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(String text, bool isAlternate, BuildContext context) {
    Color baseColor = Theme.of(context).colorScheme.surface;
    Color lighterColor = Color.lerp(baseColor, Colors.white, 0.07)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      height: 50.0,
      color: isAlternate ? lighterColor : baseColor,
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildFilePreview(
      BuildContext context, DataManagementProvider dataManagementProvider) {
    final file = dataManagementProvider.previewedFile;

    if (file == null) return SizedBox.shrink();

    try {
      // Check for data structure in 'points'
      if (file.data != null && file.data!['points'] != null) {
        final spots = _convertJsonToSpots(file.data!);

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            color: Colors.grey.shade200,
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Preview: ${file.fileName}",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                SizedBox(
                  height: 250,
                  child: LineChart(LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        barWidth: 2,
                      ),
                    ],
                    titlesData: FlTitlesData(show: true),
                    borderData: FlBorderData(show: true),
                  )),
                ),
              ],
            ),
          ),
        );
      } else if (file.isImage && file.binaryData != null) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Image.memory(file.binaryData!, fit: BoxFit.cover),
        );
      }
    } catch (e) {
      print("Error loading preview: $e");
    }

    return Center(child: Text("No preview available for this file."));
  }

  List<FlSpot> _convertJsonToSpots(Map<String, dynamic> jsonData) {
    List<FlSpot> spots = [];
    if (jsonData.containsKey('points')) {
      final points = jsonData['points'] as List;
      for (var point in points) {
        final x = point['x'] is int
            ? (point['x'] as int).toDouble()
            : point['x'].toDouble();
        final y = point['y'] is int
            ? (point['y'] as int).toDouble()
            : point['y'].toDouble();
        spots.add(FlSpot(x, y));
      }
    } else {
      print("JSON data does not contain 'points'.");
    }
    return spots;
  }
}
