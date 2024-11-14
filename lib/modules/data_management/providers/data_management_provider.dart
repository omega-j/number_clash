import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import '../../../enums/common_enums.dart';
import '../../database/models/data_record.dart';
import '../../logging/providers/i_logging_provider.dart';
import '../models/database_data_file.dart';
import '../../input_output/services/i_file_service.dart';
import '../../../models/common/result.dart';
import '../../database/providers/i_database_provider.dart';

class DataManagementProvider extends ChangeNotifier {
  final ILoggingProvider logger;
  final IFileService fileService;
  final IDatabaseProvider databaseProvider;

  final List<DatabaseDataFile> _dataFiles = [];
  bool _showImagesOnly = false;
  DatabaseDataFile? _previewedFile;
  bool _isDataLoaded = false;
  final _uuid = Uuid();

  DataManagementProvider({
    required this.logger,
    required this.fileService,
    required this.databaseProvider,
  });

  List<DatabaseDataFile> get dataFiles => _dataFiles;
  bool get showImagesOnly => _showImagesOnly;
  DatabaseDataFile? get previewedFile => _previewedFile;

  List<DatabaseDataFile> get filteredFiles => _showImagesOnly
      ? _dataFiles
          .where((file) => file.isImage && !file.isMarkedForDeletion)
          .toList()
      : _dataFiles.where((file) => !file.isMarkedForDeletion).toList();

  List<String> get tableHeaders => ["File Name", "Date Created", "Type"];

  List<List<String>> get tableData => filteredFiles.map((file) {
        return [
          file.fileName,
          DateFormat.yMd().add_Hm().format(file.creationDate),
          file.fileType.toString(),
        ];
      }).toList();

  Future<void> initialize({required String sessionType}) async {
  await _loadToggleState();
  await loadDataFiles(sessionType: sessionType);
}

  Future<void> loadDataFiles({required String sessionType}) async {
  if (_isDataLoaded) return;

  try {
    _isDataLoaded = true;
    final result = await databaseProvider.getRecords(
      sessionType: sessionType, // Pass sessionType separately
      filter: {
        'isComplete': true, // Filter for completed sessions
      },
    );

    if (result.isSuccessful && result.data != null) {
      _dataFiles
        ..clear()
        ..addAll(result.data!.map((record) => DatabaseDataFile(
              id: record.id,
              fileName: record.fileName,
              filePath: record.filePath,
              measurementType: record.measurementType,
              creationDate: record.creationDate,
              fileType: record.fileType,
              metadata: record.metadata,
              data: record.data,
              isMarkedForDeletion: record.isMarkedForDeletion,
            )));
      _dataFiles.sort((a, b) => b.creationDate.compareTo(a.creationDate));
      notifyListeners();
    } else {
      logger.logError("No records found or failed to load data files.");
    }
  } catch (e) {
    logger.logError("Error loading data files: $e");
  }
}

  Future<void> toggleShowImages() async {
    _showImagesOnly = !_showImagesOnly;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showImagesOnly', _showImagesOnly);
    notifyListeners();
  }

  Future<void> _loadToggleState() async {
    final prefs = await SharedPreferences.getInstance();
    _showImagesOnly = prefs.getBool('showImagesOnly') ?? false;
    notifyListeners();
  }

  Future<void> previewFile(String filename) async {
    try {
      clearPreview();
      final file = _dataFiles.firstWhere((file) => file.fileName == filename);

      // Log to check the data content
      logger.logInfo("Attempting to load preview for file: ${file.fileName}");
      logger.logInfo("Data content: ${file.data}");
      logger.logInfo("Metadata content: ${file.metadata}");

      _previewedFile = file;
      notifyListeners();
    } catch (e) {
      logger.logError("Error previewing file: $e");
    }
  }

  Future<void> addFile(
      DatabaseDataFile file, Map<String, dynamic> metadata) async {
    try {
      final recordResult = await databaseProvider.addRecord(
        fileName: file.fileName,
        //filePath: file.filePath,
        measurementType: file.measurementType,
        fileType: file.fileType,
        creationDate: file.creationDate,
        metadata: metadata,
      );

      if (recordResult.isSuccessful) {
        _dataFiles.add(file);
        notifyListeners();
        logger.logInfo("File added with record ID: ${recordResult.data}");
      } else {
        logger.logError("Failed to create database record.");
      }
    } catch (e) {
      logger.logError("Error adding file: $e");
    }
  }

  Future<void> deleteFile(String filename) async {
    try {
      final file = _dataFiles.firstWhere((file) => file.fileName == filename);
      if (file.isImage) {
        await fileService.deleteFile(file.filePath);
      }

      file.isMarkedForDeletion = true;
      await databaseProvider.markRecordAsDeleted(file.fileName);

      notifyListeners();
      logger.logInfo("File and associated record marked for deletion.");
    } catch (e) {
      logger.logError("Error deleting file: $e");
    }
  }

  Future<void> updateFileMetadata(
      String id, Map<String, dynamic> metadata) async {
    try {
      final updateResult =
          await databaseProvider.updateRecordMetadata(id, metadata);
      if (updateResult.isSuccessful) {
        logger.logInfo("File metadata updated successfully.");
      } else {
        logger.logError("Failed to update metadata in database.");
      }
    } catch (e) {
      logger.logError("Error updating metadata: $e");
    }
  }

  Future<void> shareFile(String filename) async {
    try {
      final file = _dataFiles.firstWhere((file) => file.fileName == filename);
      await Share.shareXFiles([XFile(file.filePath)],
          text: 'Check out this file: ${file.fileName}');
    } catch (e) {
      logger.logError("Error sharing file: $e");
    }
  }

  void clearPreview() {
    _previewedFile = null;
    notifyListeners();
  }

  String generateFilename(String serialNumber) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return "${formattedDate}_$serialNumber";
  }

  Future<void> saveRealTimeData(
      Map<String, dynamic> data, String sessionType) async {
    final fileName = generateFilename("serialNumber");
    final metadata = {
      'sessionType': sessionType,
      'isComplete': true, // Mark session as complete
    };

    final recordResult = await databaseProvider.addRecord(
      fileName: fileName,
      measurementType: MeasurementType.realTime,
      fileType: DataFileType.json,
      creationDate: DateTime.now(),
      metadata: metadata,
      data: data,
    );

    if (recordResult.isSuccessful) {
      logger
          .logInfo("Real-time data saved successfully and marked as complete.");
      notifyListeners();
    } else {
      logger.logError("Failed to save real-time data.");
    }
  }

  Future<void> loadJsonDataFiles() async {
    try {
      final recordsResult = databaseProvider.getRecords(sessionType: "json");
      if (recordsResult.isSuccessful && recordsResult.data != null) {
        _dataFiles
          ..clear()
          ..addAll(recordsResult.data!.map((record) => DatabaseDataFile(
                id: record.id,
                fileName: record.fileName,
                filePath: record.filePath,
                measurementType: record.measurementType,
                creationDate: record.creationDate,
                fileType: record.fileType,
                metadata: record.metadata,
                data: record.data,
                isMarkedForDeletion: record.isMarkedForDeletion,
              )));
        notifyListeners();
      } else {
        logger.logError("Failed to load JSON data files.");
      }
    } catch (e) {
      logger.logError("Error loading JSON data files: $e");
    }
  }

  List<DataRecord> fetchGraphRecordsBySession(String sessionId) {
    final result = databaseProvider.getRecordsBySession(sessionId);
    return result.isSuccessful ? result.data ?? [] : [];
  }

  Future<void> markFileAsDeleted(String fileName) async {
    try {
      final file = _dataFiles.firstWhere((file) => file.fileName == fileName);
      file.metadata['isMarkedForDeletion'] =
          true; // Mark file as deleted in metadata
      await databaseProvider.updateRecordMetadata(file.id, file.metadata);

      // If the file is an image, delete the actual file from the device
      if (file.isImage) {
        await fileService.deleteFile(file.filePath);
        logger.logInfo("Image file deleted from device: ${file.fileName}");
      }

      notifyListeners();
      logger.logInfo("File marked for deletion: ${file.fileName}");
    } catch (e) {
      logger.logError("Error marking file as deleted: $e");
    }
  }
}
