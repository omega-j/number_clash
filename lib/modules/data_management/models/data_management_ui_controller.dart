// import 'package:beta_app/modules/logging/i_logging_provider.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../models/common/result.dart';
// import '../../providers/providers.dart';
// import '../../services/input_output/file_service.dart';
// import '../input_output/data_file.dart';
// import '../../services/file_service.dart';
// import '../logging/i_logging_controller.dart';

// class DataManagementUIController {
//   final ILoggingProvider logger;
//   final FileService fileService;
//   final StateProvider<bool> showImagesOnlyProvider = StateProvider((ref) => false);
//   DataFile? previewedFile;

//   DataManagementUIController({
//     required this.logger,
//     required this.fileService,
//   });

//   // Toggle Image Visibility
//   void toggleShowImages(WidgetRef ref) {
//     final currentValue = ref.read(showImagesOnlyProvider);
//     ref.read(showImagesOnlyProvider.notifier).state = !currentValue;
//   }

//   // Preview File
//   Future<Result<void>> previewFile(String filename) async {
//     final result = Result<void>();
//     try {
//       final fileDataResult = await fileService.loadFileData(filename);
//       if (fileDataResult.isSuccessful) {
//         previewedFile = fileDataResult.data as DataFile;
//         result.setSuccess(successMessage: 'File previewed successfully');
//       } else {
//         result.setFailure('Failed to load file for preview');
//       }
//     } catch (e) {
//       logger.logError("Error previewing file: ${e.toString()}");
//       result.setFailure(
//           "An error occurred while previewing the file: ${e.toString()}");
//     }
//     return result;
//   }

//   // Clear Preview
//   Result<void> clearPreview() {
//     previewedFile = null;
//     return Result<void>()
//       ..setSuccess(successMessage: 'File preview cleared successfully');
//   }
// }

// // Define a provider for DataManagementUIController
// final dataManagementUIControllerProvider = Provider<DataManagementUIController>((ref) {
//   return DataManagementUIController(
//     logger: ref.read(loggingProvider),
//     fileService: ref.read(fileServiceProvider),
//   );
// });