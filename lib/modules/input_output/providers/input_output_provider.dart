import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:beta_app/utils/asset_paths.dart';
import 'package:csv/csv.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../models/common/result.dart';
import '../../../enums/common_enums.dart';
import '../services/i_file_service.dart';
import '../../user_interface/graph/graph_widget_parameters.dart';
import '../../data_management/models/database_data_file.dart';
import 'i_input_output_provider.dart';

class InputOutputProvider extends StateNotifier<List<DatabaseDataFile>>
    implements IInputOutputProvider {
  final IFileService fileService;
  DatabaseDataFile? previewedFile;
  DatabaseDataFile? selectedFile;

  // Constructor takes IFileService without specifically requiring MockFileService
  InputOutputProvider(this.fileService) : super([]);

  // Loads a specific localization JSON file based on language code
  @override
  Future<Result<Map<String, String>>> loadLocalizationFile(
      String languageCode) async {
    try {
      final filePath = AssetPaths.localizationFile(languageCode);
      final loadFileResult = await fileService.loadFileAsString(filePath);

      if (loadFileResult.isSuccessfulAndDataIsNotNull) {
        final Map<String, dynamic> jsonMap = json.decode(loadFileResult.data!);
        final translations =
            jsonMap.map((key, value) => MapEntry(key, value.toString()));
        return Result.success(data: translations);
      } else {
        return Result.failure(
            message: "Failed to load localization file from: $filePath");
      }
    } catch (e) {
      return Result.failure(
          message: 'Failed to load localization file for $languageCode',
          exception: e);
    }
  }

  // Loads the supported locales from a manifest file
  @override
  Future<Result<List<Locale>>> loadSupportedLocales() async {
    try {
      final manifestJson = await fileService
          .loadFileAsString(AssetPaths.availableLanguagesManifest);
      final manifestData = json.decode(manifestJson.data!);
      final locales = (manifestData['locales'] as List)
          .map((localeData) => Locale(localeData['languageCode']))
          .toList();
      return Result.success(data: locales);
    } catch (e) {
      return Result.failure(
          message: 'Failed to load supported locales', exception: e);
    }
  }

  // Scans for available themes
  @override
  Future<List<String>> getAvailableThemes() async {
    try {
      final themeDir = Directory('assets/themes/clients');
      if (!await themeDir.exists()) return [];
      return await themeDir
          .list()
          .where((file) => file.path.endsWith('.json'))
          .map((file) => file.uri.pathSegments.last.replaceAll('.json', ''))
          .toList();
    } catch (e) {
      print("Error scanning theme files: $e");
      return [];
    }
  }

  // Deletes a specified file
  @override
  Future<Result<void>> deleteFile(String filename) async {
    try {
      final dataFile = state.firstWhere((file) => file.fileName == filename);
      state = List.from(state)..remove(dataFile);
      await fileService.deleteFile(dataFile.filePath);
      return Result.success(message: 'Data file removed successfully');
    } catch (e) {
      return Result.failure(
          message: "Error removing data file: ${e.toString()}", exception: e);
    }
  }

  // Shares specified file
  @override
  Future<Result<DatabaseDataFile>> shareFile(String filename) async {
    try {
      final file = state.firstWhere((file) => file.fileName == filename);
      final xFile = XFile(file.filePath);
      await Share.shareXFiles([xFile],
          text: 'Check out this file: ${file.fileName}');
      return Result.success(message: "File shared successfully.", data: file);
    } catch (e) {
      return Result.failure(
          message: "Error sharing file: ${e.toString()}", exception: e);
    }
  }

  @override
  Future<Result<void>> saveFile(
      Uint8List imageData, String fileName) async {
    try {
      // Get the application documents directory.
      final directory = await getApplicationDocumentsDirectory();

      // Generate the file path.
      final filePath = '${directory.path}/$fileName.png';

      // Save image data as a file in the directory.
      final file = File(filePath);
      await file.writeAsBytes(imageData);

      return Result.success(message: 'Graph image saved at $filePath');
    } catch (e, stackTrace) {
      return Result.failure(
        message: 'Failed to save graph image',
        exception: e,
        stackTrace: stackTrace,
      );
    }
  }
}
