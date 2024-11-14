// Mocks generated by Mockito 5.4.4 from annotations
// in beta_app/test/mocks/mock_data_management_provider.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i7;
import 'dart:ui' as _i10;

import 'package:beta_app/modules/data_management/models/database_data_file.dart'
    as _i6;
import 'package:beta_app/modules/data_management/providers/data_management_provider.dart'
    as _i2;
import 'package:beta_app/modules/database/providers/i_database_provider.dart'
    as _i5;
import 'package:beta_app/modules/input_output/services/i_file_service.dart'
    as _i4;
import 'package:beta_app/modules/logging/providers/i_logging_provider.dart'
    as _i3;
import 'package:fl_chart/fl_chart.dart' as _i8;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i9;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

/// A class which mocks [DataManagementProvider].
///
/// See the documentation for Mockito's code generation for more information.
class MockDataManagementProvider extends _i1.Mock
    implements _i2.DataManagementProvider {
  MockDataManagementProvider() {
    _i1.throwOnMissingStub(this);
  }

  @override
  set logger(_i3.ILoggingProvider? _logger) => super.noSuchMethod(
        Invocation.setter(
          #logger,
          _logger,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set fileService(_i4.IFileService? _fileService) => super.noSuchMethod(
        Invocation.setter(
          #fileService,
          _fileService,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set databaseProvider(_i5.IDatabaseProvider? _databaseProvider) =>
      super.noSuchMethod(
        Invocation.setter(
          #databaseProvider,
          _databaseProvider,
        ),
        returnValueForMissingStub: null,
      );

  @override
  List<_i6.DatabaseDataFile> get dataFiles => (super.noSuchMethod(
        Invocation.getter(#dataFiles),
        returnValue: <_i6.DatabaseDataFile>[],
      ) as List<_i6.DatabaseDataFile>);

  @override
  bool get showImagesOnly => (super.noSuchMethod(
        Invocation.getter(#showImagesOnly),
        returnValue: false,
      ) as bool);

  @override
  List<_i6.DatabaseDataFile> get filteredFiles => (super.noSuchMethod(
        Invocation.getter(#filteredFiles),
        returnValue: <_i6.DatabaseDataFile>[],
      ) as List<_i6.DatabaseDataFile>);

  @override
  bool get hasListeners => (super.noSuchMethod(
        Invocation.getter(#hasListeners),
        returnValue: false,
      ) as bool);

  @override
  _i7.Future<void> loadDataFiles() => (super.noSuchMethod(
        Invocation.method(
          #loadDataFiles,
          [],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i7.Future<void> toggleShowImages() => (super.noSuchMethod(
        Invocation.method(
          #toggleShowImages,
          [],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i7.Future<void> previewFile(String? filename) => (super.noSuchMethod(
        Invocation.method(
          #previewFile,
          [filename],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i7.Future<void> addFile(
    _i6.DatabaseDataFile? file,
    Map<String, dynamic>? metadata,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #addFile,
          [
            file,
            metadata,
          ],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i7.Future<void> deleteFile(String? filename) => (super.noSuchMethod(
        Invocation.method(
          #deleteFile,
          [filename],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i7.Future<void> updateFileMetadata(
    String? id,
    Map<String, dynamic>? metadata,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateFileMetadata,
          [
            id,
            metadata,
          ],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i7.Future<void> shareFile(String? filename) => (super.noSuchMethod(
        Invocation.method(
          #shareFile,
          [filename],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  void clearPreview() => super.noSuchMethod(
        Invocation.method(
          #clearPreview,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  double getMaxYValue(List<_i8.FlSpot>? data) => (super.noSuchMethod(
        Invocation.method(
          #getMaxYValue,
          [data],
        ),
        returnValue: 0.0,
      ) as double);

  @override
  String generateFilename(String? serialNumber) => (super.noSuchMethod(
        Invocation.method(
          #generateFilename,
          [serialNumber],
        ),
        returnValue: _i9.dummyValue<String>(
          this,
          Invocation.method(
            #generateFilename,
            [serialNumber],
          ),
        ),
      ) as String);

  @override
  _i7.Future<void> saveRealTimeData(
    Map<String, dynamic>? data,
    String? sessionType,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #saveRealTimeData,
          [
            data,
            sessionType,
          ],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i7.Future<void> loadJsonDataFiles() => (super.noSuchMethod(
        Invocation.method(
          #loadJsonDataFiles,
          [],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  void addListener(_i10.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(
          #addListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void removeListener(_i10.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(
          #removeListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void dispose() => super.noSuchMethod(
        Invocation.method(
          #dispose,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void notifyListeners() => super.noSuchMethod(
        Invocation.method(
          #notifyListeners,
          [],
        ),
        returnValueForMissingStub: null,
      );
}
