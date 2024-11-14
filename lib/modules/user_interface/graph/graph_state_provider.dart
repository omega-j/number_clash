import 'dart:convert';
import 'dart:ui';

import 'package:beta_app/models/common/result.dart';
import 'package:beta_app/modules/database/providers/database_provider.dart';
import 'package:beta_app/modules/input_output/providers/i_input_output_provider.dart';
import 'package:beta_app/modules/logging/providers/i_logging_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../enums/common_enums.dart';
import '../../database/providers/i_database_provider.dart';
import 'graph_widget_parameters.dart';
import 'graph_widget_state.dart';
import '../../settings/providers/configuration_data_provider.dart';
import '../../bluetooth_management/ble_fluorometer/providers/data_provider.dart';
import '../../theming/theme_provider.dart';

final isGraphViewProviderFamily =
    StateProvider.family<bool, String>((ref, graphKey) => true);

class GraphStateProvider extends ChangeNotifier {
  final Map<String, GraphWidgetState> _graphs = {};
  final ILoggingProvider logger;
  final ConfigurationDataProvider configurationDataProvider;
  final ThemeProvider themeProvider;
  final IDatabaseProvider databaseProvider;
  final IInputOutputProvider inputOutputProvider;

  final DataProvider dataProvider;

  bool isDisposed = false;

  GraphStateProvider({
    required this.logger,
    required this.configurationDataProvider,
    required this.themeProvider,
    required this.dataProvider,
    required this.databaseProvider,
    required this.inputOutputProvider,
  });

  bool hasUnsavedData(String key) => _graphs[key]?.hasUnsavedData() ?? false;

  Future<Result<GraphWidgetState>> addGraph(
      String key, GraphWidgetParameters graphParameters) async {
    try {
      if (!_graphs.containsKey(key)) {
        _graphs[key] = GraphWidgetState(
          graphWidgetParameters: graphParameters,
          logger: logger,
          themeProvider: themeProvider,
          configurationDataProvider: configurationDataProvider,
          dataProvider: dataProvider,
        );
      }
      final graphResult = getGraph(key);
      if (graphResult.isSuccessful && graphResult.data != null) {
        graphResult.data?.initStateManagement();
        return Result.success(
          message: 'Added graph with key: $key',
          data: graphResult.data,
        );
      } else {
        return Result.failure(
            message:
                "Failed to retrieve the graph after adding it with key: $key.");
      }
    } catch (e, stackTrace) {
      return Result.failure(
          message: "An error occurred while adding the graph: ${e.toString()}",
          exception: e,
          stackTrace: stackTrace);
    }
  }

  Result<void> removeGraph(String key) {
    try {
      if (_graphs.containsKey(key)) {
        _graphs.remove(key);
        notifyListeners();
        return Result.success(message: 'Removed graph with key: $key');
      } else {
        return Result.failure(message: "Graph with key '$key' does not exist.");
      }
    } catch (e, stackTrace) {
      return Result.failure(
          message:
              "An error occurred while trying to remove the graph: ${e.toString()}",
          exception: e,
          stackTrace: stackTrace);
    }
  }

  Result<GraphWidgetState> getGraph(String key) {
    try {
      if (_graphs.containsKey(key)) {
        return Result.success(
            message: 'Retrieved graph with key: $key', data: _graphs[key]);
      } else {
        return Result.failure(message: "Graph with key '$key' does not exist.");
      }
    } catch (e, stackTrace) {
      return Result.failure(
          message:
              "An error occurred while trying to retrieve the graph: ${e.toString()}",
          exception: e,
          stackTrace: stackTrace);
    }
  }

  Result<void> zoomGraphIn(String key) =>
      _graphOperation(key, "zoom in", (graph) {
        graph.zoomGraphIn();
      });

  Result<void> zoomGraphOut(String key) =>
      _graphOperation(key, "zoom out", (graph) {
        graph.zoomGraphOut();
      });

  Result<void> scrollGraphLeft(String key) =>
      _graphOperation(key, "scroll left", (graph) {
        graph.scrollGraphLeft();
      });

  Result<void> scrollGraphRight(String key) =>
      _graphOperation(key, "scroll right", (graph) {
        graph.scrollGraphRight();
      });

  Result<void> toggleIsGraphView(String key, WidgetRef ref) {
    try {
      final isGraphViewNotifier =
          ref.read(isGraphViewProviderFamily(key).notifier);
      isGraphViewNotifier.state = !isGraphViewNotifier.state;
      notifyListeners();
      return Result.success(message: 'Toggled view for graph with key: $key');
    } catch (e, stackTrace) {
      return Result.failure(
          message:
              "An error occurred while toggling view for graph: ${e.toString()}",
          exception: e,
          stackTrace: stackTrace);
    }
  }

  Result<void> startMonitoring(String key) =>
      _graphOperation(key, "start monitoring", (graph) {
        graph.startMonitoring();
      });

  Result<void> stopMonitoring(String key) =>
      _graphOperation(key, "stop monitoring", (graph) {
        graph.stopMonitoring();
      });

  Result<void> _graphOperation(
      String key, String action, void Function(GraphWidgetState) operation) {
    try {
      final graph = _graphs[key];
      if (graph != null) {
        operation(graph);
        notifyListeners();
        return Result.success(
            message: '$action performed on graph with key: $key');
      } else {
        return Result.failure(message: "Graph with key '$key' does not exist.");
      }
    } catch (e, stackTrace) {
      return Result.failure(
          message:
              "An error occurred while trying to $action on graph: ${e.toString()}",
          exception: e,
          stackTrace: stackTrace);
    }
  }

  Future<Result<void>> saveData(
    String graphKey,
    String sessionID,
  ) async {
    try {
      // Retrieve di graph data using di graph key
      final graphResult = getGraph(graphKey);
      if (!graphResult.isSuccessful || graphResult.data == null) {
        return Result.failure(
            message: 'Graph with key $graphKey does not exist.');
      }

      // Convert di graph's collected data to JSON format
      final data = graphResult.data!.collectedData;
      final jsonData = {
        'points': data.map((e) => {'x': e.x, 'y': e.y}).toList()
      };

      // Encode JSON if saving as a single string in metadata
      final jsonString =
          jsonEncode(jsonData); // Ensure JSON structure as string
      print('JSON string to save: $jsonString');

      // Set up di creation date an’ metadata
      final creationDate = DateTime.now();
      final metadata = {
        'description': 'Session data',
        'sessionID': sessionID,
        'jsonData': jsonString, // Store JSON data as encoded string
      };

      // Save record directly to database, storing structured JSON in `data`
      final saveRecordResult = await databaseProvider.addRecord(
        fileName: '',
        creationDate: creationDate,
        measurementType: MeasurementType.data,
        fileType: DataFileType.json,
        data: jsonData, // Store structured JSON directly
        metadata: metadata,
      );

      if (!saveRecordResult.isSuccessful) {
        return Result.failure(
            message: 'Failed to save data record in the database.');
      }

      return Result.success(message: 'Data saved successfully as JSON.');
    } catch (e) {
      return Result.failure(
        message: 'An error occurred while saving JSON data to di database.',
        exception: e,
      );
    }
  }

  Future<Result<void>> exportImage(
      GlobalKey lineChartKey, String sessionID) async {
    try {
      // Ensure the context is not null
      if (lineChartKey.currentContext == null) {
        return Result.failure(
            message: 'Line chart context is null. Cannot capture image.');
      }

      // Obtain the RenderRepaintBoundary for the line chart
      RenderRepaintBoundary boundary = lineChartKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;

      // Capture the image as bytes
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final imageBytes = byteData?.buffer.asUint8List();

      if (imageBytes == null) {
        return Result.failure(message: 'Failed to capture image bytes.');
      }

      // Save metadata and image bytes to DatabaseProvider with session ID and other details
      final saveRecordResult = await databaseProvider.addRecord(
        fileName:
            '${Uuid().v4()}.png', // Just for metadata purposes, as it's stored in the DB
        creationDate: DateTime.now(),
        //filePath: '',  // No physical path needed as we're storing bytes
        measurementType: MeasurementType.graph,
        fileType: DataFileType.image,
        data: {
          'imageBytes': imageBytes
        }, // Directly saving the image bytes in the 'data' field
        metadata: {
          'description': 'Exported graph image',
          'sessionID': sessionID,
        },
      );

      if (!saveRecordResult.isSuccessful) {
        return Result.failure(
            message: 'Failed to save image record in database.');
      }

      return Result.success(message: 'Image exported and saved successfully.');
    } catch (e) {
      return Result.failure(
        message: "An error occurred while exporting graph image.",
        exception: e,
      );
    }
  }
}
