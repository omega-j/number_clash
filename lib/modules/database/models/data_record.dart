import 'dart:io';
import 'dart:typed_data';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../../enums/common_enums.dart';
import '../../../models/common/result.dart';

part 'data_record.g.dart';

@HiveType(typeId: 0)
class DataRecord {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String fileName;
  @HiveField(2)
  String filePath; // Make filePath mutable to update after export if needed
  @HiveField(3)
  final MeasurementType measurementType;
  @HiveField(4)
  final DataFileType fileType;
  @HiveField(5)
  final DateTime creationDate;
  @HiveField(6)
  final Map<String, dynamic> metadata;
  @HiveField(7)
  final Map<String, dynamic>? data;
  @HiveField(8)
  bool isMarkedForDeletion;

  // New field for binary data storage (e.g., images in-memory)
  @HiveField(9)
  final Uint8List? binaryData;

  DataRecord({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.measurementType,
    required this.fileType,
    required this.creationDate,
    required this.metadata,
    this.data,
    this.isMarkedForDeletion = false, // Default to false
    this.binaryData,
  });

  Future<Result<void>> exportImage() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      String formattedDateTime =
          DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final imagePath = '${directory.path}/$fileName\_$formattedDateTime.png';

      if (binaryData == null) {
        return Result.failure(message: 'No binary data available to export.');
      }

      final file = File(imagePath);
      await file.writeAsBytes(binaryData!); // Write binary data to file
      filePath = imagePath;

      return Result.success(message: 'Image exported successfully');
    } catch (e) {
      return Result.failure(message: 'Failed to export image: $e');
    }
  }

  // Add the copyWith method
  DataRecord copyWith({
    String? id,
    String? fileName,
    String? filePath,
    MeasurementType? measurementType,
    DataFileType? fileType,
    DateTime? creationDate,
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? data,
    bool? isMarkedForDeletion,
    Uint8List? binaryData,
  }) {
    return DataRecord(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      measurementType: measurementType ?? this.measurementType,
      fileType: fileType ?? this.fileType,
      creationDate: creationDate ?? this.creationDate,
      metadata: metadata ?? this.metadata,
      data: data ?? this.data,
      isMarkedForDeletion: isMarkedForDeletion ?? this.isMarkedForDeletion,
      binaryData: binaryData ?? this.binaryData,
    );
  }
}