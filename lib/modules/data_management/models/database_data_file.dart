import 'dart:typed_data'; // Needed for Uint8List
import 'package:uuid/uuid.dart';
import '../../../enums/common_enums.dart';

class DatabaseDataFile {
  final String id; // Unique identifier for the file
  final String filePath; // Path to the file
  final String fileName; // Name of the file
  final MeasurementType measurementType;
  final bool isImage;
  final DateTime creationDate;
  final DataFileType fileType; // File type determined by extension
  final Map<String, dynamic>? data; // Data content for JSON/CSV
  final Map<String, dynamic> metadata; // Additional metadata
  bool isMarkedForDeletion; // Indicates if the file is marked for deletion
  final Uint8List? binaryData; // Binary data for image previews

  DatabaseDataFile({
    String? id,
    required this.filePath,
    required this.fileName,
    required this.measurementType,
    required this.creationDate,
    required this.fileType,
    this.data,
    this.metadata = const {},
    this.isMarkedForDeletion = false, // Default to false for new files
    this.binaryData, // Optional binary data for images
  })  : id = id ?? _generateUniqueId(), // Generate ID if not provided
        isImage = _checkIfImage(fileName);

  // Static method to generate a unique ID
  static String _generateUniqueId() {
    return const Uuid().v4();
  }

  // Check if the file is an image based on its extension
  static bool _checkIfImage(String fileName) {
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.tiff'];
    final extension = fileName.split('.').last.toLowerCase();
    return imageExtensions.contains('.$extension');
  }

  // Getter to check if the file is a CSV
  bool get isCsv => fileName.toLowerCase().endsWith('.csv');

  // Getter to check if the file is a JSON
  bool get isJson => fileName.toLowerCase().endsWith('.json');

  // Method to determine file type based on the extension
  static DataFileType _determineFileType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'csv':
        return DataFileType.csv;
      case 'json':
        return DataFileType.json;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'tiff':
        return DataFileType.image;
      case 'pdf':
        return DataFileType.pdf;
      default:
        return DataFileType.unknown; // Default to unknown if unrecognized
    }
  }

  // Getters to access the properties
  String get getFilePath => filePath;
  MeasurementType get getMeasurementType => measurementType;
  DataFileType get getFileType => fileType;
  Map<String, dynamic>? get getData => data;
}