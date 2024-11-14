import 'dart:convert';
import 'dart:io';
import 'package:beta_app/modules/logging/providers/i_logging_provider.dart';
import 'package:beta_app/modules/input_output/services/i_file_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:beta_app/modules/data_management/models/database_data_file.dart';
import 'package:beta_app/models/common/result.dart';
import '../../../enums/common_enums.dart';

class FileService implements IFileService {
  final ILoggingProvider logger;

  FileService({required this.logger});

  Future<Directory> _getAppDirectory() async =>
      await getApplicationDocumentsDirectory();

  @override
  Future<Result<List<DatabaseDataFile>>> loadAllFiles() async {
    try {
      final directory = await _getAppDirectory();
      final files = directory.listSync().whereType<File>();

      final dataFiles = files.map((file) {
        final fileType = _determineFileType(file);
        return DatabaseDataFile(
          filePath: file.path,
          fileName: file.uri.pathSegments.last,
          creationDate: file.statSync().changed,
          fileType: fileType,
          measurementType: MeasurementType.fluoride, // Placeholder
        );
      }).toList();

      return Result.success(
          message: 'Files loaded successfully', data: dataFiles);
    } catch (e) {
      return Result.failure(message: "Failed to load files: $e");
    }
  }

  @override
  Future<Result<String>> loadFileAsString(String filePath) async {
    try {
      final fileData = await rootBundle.loadString(filePath);
      return Result.success(
          message: "Successfully loaded file: $filePath", data: fileData);
    } catch (e, stackTrace) {
      return Result.failure(
          message: "Error reading file as string: $e",
          exception: e,
          stackTrace: stackTrace);
    }
  }

  @override
  Future<Result<List<DatabaseDataFile>>> fetchDataFiles(
      {DataFileType? filterType}) async {
    try {
      final directory = await _getAppDirectory();
      final files = directory.listSync().whereType<File>();

      final filteredFiles = files.where((file) {
        final fileType = _determineFileType(file);
        return filterType == null || fileType == filterType;
      }).map((file) {
        final fileType = _determineFileType(file);
        return DatabaseDataFile(
          filePath: file.path,
          fileName: file.uri.pathSegments.last,
          creationDate: file.statSync().changed,
          fileType: fileType,
          measurementType: MeasurementType.fluoride, // Placeholder
        );
      }).toList();

      return Result.success(
          message: 'Data files fetched successfully', data: filteredFiles);
    } catch (e) {
      return Result.failure(message: "Failed to fetch data files: $e");
    }
  }

  @override
  Future<Result<void>> saveFile(
      DatabaseDataFile dataFile, List<int> content) async {
    try {
      final file = File(dataFile.filePath);
      await file.writeAsBytes(content);
      return Result.success(
          message: "File saved successfully: ${dataFile.fileName}");
    } catch (e) {
      return Result.failure(message: "Failed to save file: $e");
    }
  }

  @override
  Future<Result<void>> deleteFile(String fileName) async {
    try {
      final directory = await _getAppDirectory();
      final file = File('${directory.path}/$fileName');
      if (await file.exists()) {
        await file.delete();
        return Result.success(message: "File deleted: $fileName");
      } else {
        return Result.failure(message: "File not found: $fileName");
      }
    } catch (e) {
      return Result.failure(message: "Failed to delete file: $e");
    }
  }

  @override
  Future<Result<List<int>>> exportDataAsImage(DatabaseDataFile dataFile) async {
    try {
      if (dataFile.fileType == DataFileType.image) {
        final file = File(dataFile.filePath);
        final imageData = await file.readAsBytes();
        return Result.success(
            message: "Image exported successfully", data: imageData);
      } else {
        return Result.failure(
            message: "File is not an image and cannot be exported as such.");
      }
    } catch (e) {
      return Result.failure(message: "Failed to export image: $e");
    }
  }

  DataFileType _determineFileType(File file) {
    final extension = file.uri.pathSegments.last.split('.').last.toLowerCase();

    switch (extension) {
      case 'csv':
        return DataFileType.csv;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return DataFileType.image;
      case 'pdf':
        return DataFileType.pdf;
      case 'json':
        return DataFileType.json;
      default:
        logger.logWarning("Unknown file type for file: ${file.path}");
        return DataFileType.unknown; // Updated to unknown for clarity
    }
  }

  @override
  Future<Result<List<int>>> loadFileData(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final fileData = await file.readAsBytes();
        return Result.success(
            message: 'File data loaded successfully', data: fileData);
      } else {
        return Result.failure(message: "File not found at path: $filePath");
      }
    } catch (e) {
      return Result.failure(
          message: "An error occurred while loading file data: $e");
    }
  }

  @override
  Future<Result<List<FlSpot>>> loadCsvFileAsFlSpots(String filePath) async {
    try {
      final file = File(filePath);
      final csvString = await file.readAsString();
      final lines = const LineSplitter().convert(csvString);

      List<FlSpot> spots = [];
      for (var line in lines) {
        final values = line.split(',');
        if (values.length >= 2) {
          final x = double.tryParse(values[0]);
          final y = double.tryParse(values[1]);
          if (x != null && y != null) {
            spots.add(FlSpot(x, y));
          }
        }
      }

      return Result.success(
          message: 'CSV data parsed successfully', data: spots);
    } catch (e) {
      return Result.failure(message: "Failed to parse CSV file: $e");
    }
  }

  Future<Result<List<FlSpot>>> loadJsonFileAsFlSpots(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return Result.failure(message: "File not found: $filePath");
      }

      final jsonString = await file.readAsString();
      final List<dynamic> jsonData = json.decode(jsonString);

      List<FlSpot> spots = [];
      for (var entry in jsonData) {
        if (entry is Map<String, dynamic>) {
          final x = entry['x'];
          final y = entry['y'];
          if (x is num && y is num) {
            spots.add(FlSpot(x.toDouble(), y.toDouble()));
          }
        }
      }

      return Result.success(
          message: 'JSON data parsed successfully', data: spots);
    } catch (e) {
      return Result.failure(message: "Failed to parse JSON file: $e");
    }
  }
}
