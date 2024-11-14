import 'dart:typed_data';
import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import '../../../enums/common_enums.dart';
import '../../../models/common/result.dart';
import '../../user_interface/graph/graph_widget_parameters.dart';
import '../../data_management/models/database_data_file.dart';

abstract class IInputOutputProvider {
  Future<List<String>> getAvailableThemes(); // Scans for available themes

  Future<Result<void>> deleteFile(String filename); // Deletes a specified file

  Future<Result<DatabaseDataFile>> shareFile(
      String filename); // Shares specified file

  Future<Result<List<Locale>>>
      loadSupportedLocales(); // Loads supported locales

  Future<Result<Map<String, String>>> loadLocalizationFile(
      String languageCode); // Loads localization file

  Future<Result<void>> saveFile(Uint8List imageData, String fileName);
}
