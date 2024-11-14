import 'package:fl_chart/fl_chart.dart';

import '../../../models/common/result.dart';
import '../../data_management/models/database_data_file.dart';
import '../../../enums/common_enums.dart';

abstract class IFileService {
  // Loads all files in the application's document directory
  Future<Result<List<DatabaseDataFile>>> loadAllFiles();

  // Fetches specific data files, optionally filtered by type
  Future<Result<List<DatabaseDataFile>>> fetchDataFiles({DataFileType? filterType});

  // Saves the given content to a file at the specified data file's path
  Future<Result<void>> saveFile(DatabaseDataFile dataFile, List<int> content);

  // Deletes a file by its name in the application's document directory
  Future<Result<void>> deleteFile(String fileName);

  // Exports a data file as an image if its type is compatible
  Future<Result<List<int>>> exportDataAsImage(DatabaseDataFile dataFile);

  // Loads a file's content as raw bytes, useful for binary files
  Future<Result<List<int>>> loadFileData(String filePath);

  // Loads a file's content as a string, useful for JSON or text files
  Future<Result<String>> loadFileAsString(String filePath);

  Future<Result<List<FlSpot>>> loadCsvFileAsFlSpots(String filePath);

  Future<Result<List<FlSpot>>> loadJsonFileAsFlSpots(String filePath);
}
