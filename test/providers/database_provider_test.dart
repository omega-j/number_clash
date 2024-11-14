import 'dart:typed_data';

import 'package:beta_app/enums/common_enums.dart';
import 'package:beta_app/models/common/result.dart';
import 'package:beta_app/modules/data_management/models/database_data_file.dart';
import 'package:beta_app/modules/database/adapters/data_file_type_adapter.dart';
import 'package:beta_app/modules/database/adapters/measurement_type_adapter.dart';
import 'package:beta_app/modules/database/models/data_record.dart';
import 'package:beta_app/modules/database/providers/database_provider.dart';
import 'package:beta_app/modules/input_output/providers/input_output_provider.dart';
import 'package:beta_app/modules/provider_setup/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'dart:io';
import 'package:hive/hive.dart';

import '../mocks/mock_file_service_provider.mocks.dart';
import '../mocks/mock_logging_provider.mocks.dart';

late String tempPath;

class MockPathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String> getTemporaryPath() async => '/tmp/beta_app_test';

  @override
  Future<String> getApplicationDocumentsPath() async =>
      '/tmp/beta_app_test/documents';

  @override
  Future<String> getApplicationSupportPath() async =>
      '/tmp/beta_app_test/support';

  @override
  Future<String> getLibraryPath() async => '/tmp/beta_app_test/library';

  @override
  Future<String> getDownloadsPath() async => '/tmp/beta_app_test/downloads';
}

final databaseProviderOverride =
    StateNotifierProvider<DatabaseProvider, Map<String, DataRecord>>((ref) {
  final mockLogger = MockLoggingProvider();
  final provider = DatabaseProvider(logger: mockLogger);
  provider.init(customDirectoryPath: tempPath);
  return provider;
});

void main() {
  setUpAll(() async {
    // Initialize the mock path provider and temp path
    PathProviderPlatform.instance = MockPathProviderPlatform();
    tempPath = (await PathProviderPlatform.instance.getTemporaryPath())!;

    // Ensure directories exist
    Directory(tempPath).createSync(recursive: true);

    // Initialize Hive and register adapters
    Hive.init(tempPath);
    Hive.registerAdapter(DataRecordAdapter());
    Hive.registerAdapter(MeasurementTypeAdapter());
    Hive.registerAdapter(DataFileTypeAdapter());
  });

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithProvider(databaseProviderOverride),
      ],
    );
  });

  tearDown(() async {
    // Dispose the container after each test to clean up providers
    container.dispose();
    // Ensure Hive boxes and temp files are cleaned up
    await Hive.close();
    if (Directory(tempPath).existsSync()) {
      Directory(tempPath).deleteSync(recursive: true);
    }
  });

  test('Add a new record successfully', () async {
    final dbProvider = container.read(databaseProvider.notifier);

    final result = await dbProvider.addRecord(
      fileName: "test_file",
      creationDate: DateTime.now(),
      filePath: "/path/to/test_file",
      measurementType: MeasurementType.fluoride,
      fileType: DataFileType.csv,
    );

    expect(result.isSuccessful, true);
    expect(result.data, isNotNull);
  });

  test('Retrieve an existing record', () async {
    final dbProvider = container.read(databaseProvider.notifier);

    final addResult = await dbProvider.addRecord(
      fileName: "retrieve_test_file",
      creationDate: DateTime.now(),
      filePath: "/path/to/retrieve_test_file",
      measurementType: MeasurementType.ph,
      fileType: DataFileType.json,
    );

    final record = dbProvider.getRecord(addResult.data!);
    expect(record.isSuccessful, true);
    expect(record.data?.fileName, "retrieve_test_file");
  });

  test('Update metadata of an existing record', () async {
    final dbProvider = container.read(databaseProvider.notifier);

    final addResult = await dbProvider.addRecord(
      fileName: "update_test_file",
      creationDate: DateTime.now(),
      filePath: "/path/to/update_test_file",
      measurementType: MeasurementType.temperature,
      fileType: DataFileType.csv,
    );

    final updateResult = await dbProvider.updateRecordMetadata(
      addResult.data!,
      {"newKey": "newValue"},
    );

    expect(updateResult.isSuccessful, true);

    // Verify the metadata is updated
    final updatedRecord = dbProvider.getRecord(addResult.data!);
    expect(updatedRecord.data?.metadata['newKey'], "newValue");
  });

  test('Delete an existing record', () async {
    final dbProvider = container.read(databaseProvider.notifier);

    final addResult = await dbProvider.addRecord(
      fileName: "delete_test_file",
      creationDate: DateTime.now(),
      filePath: "/path/to/delete_test_file",
      measurementType: MeasurementType.fluoride,
      fileType: DataFileType.csv,
    );

    final deleteResult = await dbProvider.deleteRecord(addResult.data!);
    expect(deleteResult.isSuccessful, true);

    // Verify the record is deleted and check the failure message within the Result object
    final record = dbProvider.getRecord(addResult.data!);
    expect(record.isFailure, true);
    expect(record.message, contains("Record not found"));
  });

  test('Retrieve records filtered by session type', () async {
    final dbProvider = container.read(databaseProvider.notifier);

    await dbProvider.addRecord(
      fileName: "session_test_file1",
      creationDate: DateTime.now(),
      filePath: "/path/to/session_test_file1",
      measurementType: MeasurementType.ph,
      fileType: DataFileType.json,
      metadata: {"sessionType": "session1"},
    );

    await dbProvider.addRecord(
      fileName: "session_test_file2",
      creationDate: DateTime.now(),
      filePath: "/path/to/session_test_file2",
      measurementType: MeasurementType.temperature,
      fileType: DataFileType.csv,
      metadata: {"sessionType": "session2"},
    );

    final records = dbProvider.getRecords(sessionType: "session1");
    expect(records.length, equals(1));
    expect(records.first.fileName, equals("session_test_file1"));
  });

  test('Confirm file path exists after adding record', () async {
    final dbProvider = container.read(databaseProvider.notifier);

    final filePath = '/path/to/test_image.png';
    final result = await dbProvider.addRecord(
      fileName: "test_image",
      creationDate: DateTime.now(),
      filePath: filePath,
      measurementType: MeasurementType.fluoride,
      fileType: DataFileType.image,
    );

    final addedRecord = dbProvider.getRecord(result.data!);
    expect(addedRecord.isSuccessful, true);

    final file = File(filePath);
    expect(file.existsSync(), isTrue, reason: "File should exist on disk.");
  });

  test('Retrieve non-existent record', () async {
    final dbProvider = container.read(databaseProvider.notifier);

    final record = dbProvider.getRecord("non_existent_id");
    expect(record.isFailure, true);
    expect(record.message, contains("Record not found"));
  });

  test('Attempt to delete non-existent record', () async {
    final dbProvider = container.read(databaseProvider.notifier);

    final result = await dbProvider.deleteRecord("invalid_id");
    expect(result.isFailure, true);
    expect(result.message, contains("Record not found"));
  });

  test('Export image functionality test', () async {
    final dbProvider = container.read(databaseProvider.notifier);

    final addResult = await dbProvider.addRecord(
      fileName: "export_test_image",
      creationDate: DateTime.now(),
      filePath: "/path/to/export_test_image.png",
      measurementType: MeasurementType.ph,
      fileType: DataFileType.image,
    );

    final record = dbProvider.getRecord(addResult.data!);
    expect(record.isSuccessful, true);

    final Result<void>? exportResult = await record.data?.exportImage();
    expect(exportResult?.isSuccessful, true,
        reason: "Image export should be successful.");

    final file = File(record.data!.filePath);
    expect(file.existsSync(), isTrue,
        reason: "Exported file should exist on disk.");
  });
  test('saveGraphImage creates a file with expected name and content',
      () async {
    final provider = InputOutputProvider(MockFileService());
    final serialNumber = '12345';
    final measurementTitle = 'TestMeasurement';
    final imageData =
        Uint8List.fromList([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]); // Sample image data
    final MeasurementType measurementType = MeasurementType.fluoride;

    // Call the saveGraphImage function
    await provider.saveGraphImage(
      imageData,
      measurementTitle,
      serialNumber,
      measurementType,
    );

    // Generate expected filename format
    final directory = await getApplicationDocumentsDirectory();
    final formattedDateTime =
        DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
    final measurementTitleFormatted = measurementTitle
        .replaceAll(' ', '')
        .replaceAllMapped(
            RegExp(r'(^\w)|(\s\w)'), (match) => match.group(0)!.toUpperCase());
    final expectedFileName =
        '${directory.path}/${serialNumber}_${measurementTitleFormatted}_graph_$formattedDateTime.png';

    // Check if file exists
    final file = File(expectedFileName);
    expect(file.existsSync(), true,
        reason: "File should exist after saveGraphImage call.");

    // Check file content
    final fileBytes = await file.readAsBytes();
    expect(fileBytes, imageData,
        reason: "File content should match the image data provided.");

    // Cleanup - delete the test file after the test
    await file.delete();
  });

  test('saveGraphImage saves image data correctly', () async {
    final Uint8List sampleImageData = Uint8List.fromList([0, 1, 2, 3, 4]);
    final String measurementTitle = "TestMeasurement";
    final String serialNumber = "Serial123";
    final MeasurementType measurementType = MeasurementType.fluoride;

    final mockFileService = MockFileService();
    final inputOutputProvider = InputOutputProvider(mockFileService);

    // Define the behavior of the mock
    when(mockFileService.saveFile(any, any))
        .thenAnswer((_) async => Result.success());

    // Call the function with the added measurementType parameter
    final result = await inputOutputProvider.saveGraphImage(
      sampleImageData,
      measurementTitle,
      serialNumber,
      measurementType,
    );

    // Verify that the saveFile method was called with the correct DatabaseDataFile and content
    verify(mockFileService.saveFile(
      argThat(isA<DatabaseDataFile>()),
      sampleImageData,
    )).called(1);

    // Check that the result was successful
    expect(result.isSuccessful, isTrue,
        reason: 'The image should save successfully');
  });
}
