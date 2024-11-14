import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../../../enums/common_enums.dart';
import '../adapters/measurement_type_adapter.dart';
import '../../../models/common/result.dart';
import '../../logging/providers/i_logging_provider.dart';
import '../../provider_setup/providers.dart';
import '../adapters/data_file_type_adapter.dart';
import '../models/data_record.dart';
import 'i_database_provider.dart';

final _uuid = Uuid();

class DatabaseProvider extends StateNotifier<Map<String, DataRecord>>
    implements IDatabaseProvider {
  final ILoggingProvider logger;
  late Box<DataRecord> _dataBox;
  bool _isInitializing = false;

  DatabaseProvider({required this.logger}) : super({});

  // Initialize Hive and open the data box with an optional custom directory for testing
  Future<void> init({String? customDirectoryPath}) async {
    // Prevent concurrent initializations
    if (_isInitializing) {
      logger.logInfo("Database is currently initializing, waiting...");
      return;
    }
    _isInitializing = true;

    try {
      final dir = customDirectoryPath != null
          ? Directory(customDirectoryPath)
          : await getApplicationDocumentsDirectory();

      Hive.init(dir.path);
      logger.logInfo("Hive initialized at directory: ${dir.path}");

      // Register adapters if they haven’t been registered
      if (!Hive.isAdapterRegistered(0))
        Hive.registerAdapter(DataRecordAdapter());
      if (!Hive.isAdapterRegistered(1))
        Hive.registerAdapter(MeasurementTypeAdapter());
      if (!Hive.isAdapterRegistered(2))
        Hive.registerAdapter(DataFileTypeAdapter());

      // Directly open the data box without checking `isOpen`
      _dataBox = await Hive.openBox<DataRecord>('dataRecords');
      logger.logInfo("Data box initialized and opened successfully.");

      //clears database; only for testing... TODO
      //_dataBox.clear();

      // Load any existing records into the provider state
      state = Map.fromEntries(
          _dataBox.values.map((record) => MapEntry(record.id, record)));
    } on HiveError catch (e) {
      logger.logError("Hive initialization error: $e");
    } catch (e) {
      logger.logError("Failed to initialize database with error: $e");
    } finally {
      _isInitializing = false;
    }
  }

  // Add a record to the database
  Future<Result<String>> addRecord({
    required String fileName,
    required DateTime creationDate,
    Uint8List? binaryData, // Optional for image data or other binary formats
    Map<String, dynamic>? data, // For JSON or structured data content
    required MeasurementType measurementType,
    required DataFileType fileType,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_dataBox.isOpen) {
      return Result.failure(message: "Database box is not open.");
    }

    try {
      final id = _uuid.v4();
      final record = DataRecord(
        id: id,
        fileName: fileName,
        filePath: '', // Eliminated file path as data is stored in the database
        measurementType: measurementType,
        fileType: fileType,
        creationDate: creationDate,
        metadata: metadata ?? {},
        data: data, // Structured data for JSON content, etc.
        binaryData: binaryData, // Store binary data directly for images, etc.
      );

      await _dataBox.put(id, record);
      state = {...state, id: record};

      return Result.success(message: "Record added successfully", data: id);
    } catch (e) {
      logger.logError("Failed to add record: $e");
      return Result.failure(message: "Failed to add record: $e");
    }
  }

  // Retrieve records with optional filtering
  @override
  Result<List<DataRecord>> getRecords(
      {String? sessionType, Map<String, dynamic>? filter}) {
    try {
      final records = _dataBox.values.where((record) {
        // Exclude records marked for deletion
        if (record.isMarkedForDeletion) return false;

        // Check if the sessionType matches, if provided
        if (sessionType != null &&
            record.metadata['sessionType'] != sessionType) {
          return false;
        }

        // Apply each filter key-value pair, if provided
        if (filter != null) {
          for (var key in filter.keys) {
            if (record.metadata[key] != filter[key]) {
              return false;
            }
          }
        }
        return true;
      }).toList();

      return Result.success(data: records);
    } catch (e) {
      logger.logError("Error retrieving records: $e");
      return Result.failure(message: "Error retrieving records: $e");
    }
  }

  // Additions to support preview functionality
  @override
  Result<Uint8List?> getRecordData(String id) {
    try {
      final record = _dataBox.get(id);
      if (record != null && record.binaryData != null) {
        return Result.success(data: record.binaryData);
      } else {
        return Result.failure(message: "Data not available for record: $id");
      }
    } catch (e) {
      logger.logError("Error retrieving record data: $e");
      return Result.failure(message: "Error retrieving record data: $e");
    }
  }

  // Retrieve a record by ID
  @override
  Result<DataRecord> getRecord(String id) {
    try {
      final record = _dataBox.get(id);
      if (record != null) {
        return Result.success(data: record);
      } else {
        return Result.failure(message: "Record not found: $id");
      }
    } catch (e) {
      logger.logError("Error retrieving record: $e");
      return Result.failure(message: "Error retrieving record: $e");
    }
  }

  // Update metadata of a record
  @override
  Future<Result<void>> updateRecordMetadata(
      String id, Map<String, dynamic> newMetadata) async {
    try {
      final existingRecord = _dataBox.get(id);
      if (existingRecord != null) {
        final updatedRecord = existingRecord
            .copyWith(metadata: {...existingRecord.metadata, ...newMetadata});
        await _dataBox.put(id, updatedRecord);
        state = {...state, id: updatedRecord};
        return Result.success(message: "Record metadata updated successfully.");
      } else {
        return Result.failure(message: "Record not found: $id");
      }
    } catch (e) {
      logger.logError("Error updating record metadata: $e");
      return Result.failure(message: "Error updating record metadata: $e");
    }
  }

  // Delete a record by ID
  @override
  Future<Result<void>> deleteRecord(String id) async {
    try {
      if (_dataBox.containsKey(id)) {
        await _dataBox.delete(id);
        state = {...state}..remove(id);
        return Result.success(message: "Record deleted successfully.");
      } else {
        return Result.failure(message: "Record not found: $id");
      }
    } catch (e) {
      logger.logError("Error deleting record: $e");
      return Result.failure(message: "Error deleting record: $e");
    }
  }

  // Clear all data in the box (for testing purposes)
  @override
  Future<Result<void>> clearData() async {
    try {
      await _dataBox.clear();
      state = {};
      return Result.success(message: "All records cleared successfully.");
    } catch (e) {
      logger.logError("Error clearing data: $e");
      return Result.failure(message: "Error clearing data: $e");
    }
  }

  // Save graph file metadata with specific session ID
  @override
  Future<Result<String>> saveGraphFileMetadata({
    required String filePath,
    required String fileName,
    required DateTime creationDate,
    required MeasurementType measurementType,
    String? sessionId,
  }) async {
    if (!_dataBox.isOpen) {
      return Result.failure(message: "Database not initialized.");
    }
    try {
      final id = _uuid.v4();
      final record = DataRecord(
        id: id,
        fileName: fileName,
        filePath: filePath,
        measurementType: measurementType,
        fileType: DataFileType.image,
        creationDate: creationDate,
        metadata: {'sessionId': sessionId ?? ''},
      );

      await _dataBox.put(id, record);
      state = {...state, id: record};

      return Result.success(
          message: "Graph file metadata saved successfully.", data: id);
    } catch (e) {
      logger.logError("Error saving graph file metadata: $e");
      return Result.failure(message: "Error saving graph file metadata: $e");
    }
  }

  // Retrieve records by session ID
  @override
  Result<List<DataRecord>> getRecordsBySession(String sessionId) {
    try {
      final records = _dataBox.values
          .where((record) => record.metadata['sessionId'] == sessionId)
          .toList();
      return Result.success(data: records);
    } catch (e) {
      logger.logError("Error retrieving records by session: $e");
      return Result.failure(message: "Error retrieving records by session: $e");
    }
  }

  // Mark a record as deleted by setting isMarkedForDeletion to true
  @override
  Future<Result<void>> markRecordAsDeleted(String id) async {
    try {
      final existingRecord = _dataBox.get(id);
      if (existingRecord != null) {
        final updatedRecord =
            existingRecord.copyWith(isMarkedForDeletion: true);
        await _dataBox.put(id, updatedRecord);
        state = {...state, id: updatedRecord};
        return Result.success(
            message: "Record marked as deleted successfully.");
      } else {
        return Result.failure(message: "Record not found: $id");
      }
    } catch (e) {
      logger.logError("Error marking record as deleted: $e");
      return Result.failure(message: "Error marking record as deleted: $e");
    }
  }
}
