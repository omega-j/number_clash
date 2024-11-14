import 'dart:typed_data';

import 'package:beta_app/models/common/result.dart';
import '../../../enums/common_enums.dart';
import '../models/data_record.dart';
import 'database_provider.dart';

abstract class IDatabaseProvider {
  /// Adds a new data record with metadata and optional data content.
  /// Returns the generated GUID as a Result.
  Future<Result<String>> addRecord({
    required String fileName,
    required DateTime creationDate,
    Uint8List? binaryData, // Optional for image data or other binary formats
    Map<String, dynamic>? data, // For JSON or structured data content
    required MeasurementType measurementType,
    required DataFileType fileType,
    Map<String, dynamic>? metadata,
  });

  /// Retrieves a data record by its unique ID (GUID).
  Result<DataRecord> getRecord(String id);

  /// Updates the metadata of an existing data record identified by its ID.
  Future<Result<void>> updateRecordMetadata(
      String id, Map<String, dynamic> newMetadata);

  /// Deletes a data record by its unique ID.
  Future<Result<void>> deleteRecord(String id);

  /// Retrieves all records, with optional filtering by a specific session type.
  getRecords({Map<String, dynamic>? filter, required String sessionType});

  Future<void> clearData();

  Future<Result<String>> saveGraphFileMetadata({
    required String filePath,
    required String fileName,
    required DateTime creationDate,
    required MeasurementType measurementType,
    String? sessionId,
  });

  Result<List<DataRecord>> getRecordsBySession(String sessionId);

  Future<Result<void>> markRecordAsDeleted(String id);
  Result<Uint8List?> getRecordData(String id);
}
