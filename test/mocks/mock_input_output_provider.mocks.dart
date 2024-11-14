// Mocks generated by Mockito 5.4.4 from annotations
// in beta_app/test/mocks/mock_input_output_provider.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i7;
import 'dart:typed_data' as _i11;
import 'dart:ui' as _i8;

import 'package:beta_app/models/common/result.dart' as _i3;
import 'package:beta_app/modules/data_management/models/database_data_file.dart'
    as _i5;
import 'package:beta_app/modules/input_output/providers/input_output_provider.dart'
    as _i4;
import 'package:beta_app/modules/input_output/services/i_file_service.dart'
    as _i2;
import 'package:beta_app/modules/user_interface/graph/graph_widget_parameters.dart'
    as _i9;
import 'package:fl_chart/fl_chart.dart' as _i10;
import 'package:flutter_riverpod/flutter_riverpod.dart' as _i6;
import 'package:mockito/mockito.dart' as _i1;
import 'package:state_notifier/state_notifier.dart' as _i12;

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

class _FakeIFileService_0 extends _i1.SmartFake implements _i2.IFileService {
  _FakeIFileService_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeResult_1<T> extends _i1.SmartFake implements _i3.Result<T> {
  _FakeResult_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [InputOutputProvider].
///
/// See the documentation for Mockito's code generation for more information.
class MockInputOutputProvider extends _i1.Mock
    implements _i4.InputOutputProvider {
  MockInputOutputProvider() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.IFileService get fileService => (super.noSuchMethod(
        Invocation.getter(#fileService),
        returnValue: _FakeIFileService_0(
          this,
          Invocation.getter(#fileService),
        ),
      ) as _i2.IFileService);

  @override
  set previewedFile(_i5.DatabaseDataFile? _previewedFile) => super.noSuchMethod(
        Invocation.setter(
          #previewedFile,
          _previewedFile,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set selectedFile(_i5.DatabaseDataFile? _selectedFile) => super.noSuchMethod(
        Invocation.setter(
          #selectedFile,
          _selectedFile,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set onError(_i6.ErrorListener? _onError) => super.noSuchMethod(
        Invocation.setter(
          #onError,
          _onError,
        ),
        returnValueForMissingStub: null,
      );

  @override
  bool get mounted => (super.noSuchMethod(
        Invocation.getter(#mounted),
        returnValue: false,
      ) as bool);

  @override
  _i7.Stream<List<_i5.DatabaseDataFile>> get stream => (super.noSuchMethod(
        Invocation.getter(#stream),
        returnValue: _i7.Stream<List<_i5.DatabaseDataFile>>.empty(),
      ) as _i7.Stream<List<_i5.DatabaseDataFile>>);

  @override
  List<_i5.DatabaseDataFile> get state => (super.noSuchMethod(
        Invocation.getter(#state),
        returnValue: <_i5.DatabaseDataFile>[],
      ) as List<_i5.DatabaseDataFile>);

  @override
  set state(List<_i5.DatabaseDataFile>? value) => super.noSuchMethod(
        Invocation.setter(
          #state,
          value,
        ),
        returnValueForMissingStub: null,
      );

  @override
  List<_i5.DatabaseDataFile> get debugState => (super.noSuchMethod(
        Invocation.getter(#debugState),
        returnValue: <_i5.DatabaseDataFile>[],
      ) as List<_i5.DatabaseDataFile>);

  @override
  bool get hasListeners => (super.noSuchMethod(
        Invocation.getter(#hasListeners),
        returnValue: false,
      ) as bool);

  @override
  _i7.Future<_i3.Result<Map<String, String>>> loadLocalizationFile(
          String? languageCode) =>
      (super.noSuchMethod(
        Invocation.method(
          #loadLocalizationFile,
          [languageCode],
        ),
        returnValue: _i7.Future<_i3.Result<Map<String, String>>>.value(
            _FakeResult_1<Map<String, String>>(
          this,
          Invocation.method(
            #loadLocalizationFile,
            [languageCode],
          ),
        )),
      ) as _i7.Future<_i3.Result<Map<String, String>>>);

  @override
  _i7.Future<_i3.Result<List<_i8.Locale>>> loadSupportedLocales() =>
      (super.noSuchMethod(
        Invocation.method(
          #loadSupportedLocales,
          [],
        ),
        returnValue: _i7.Future<_i3.Result<List<_i8.Locale>>>.value(
            _FakeResult_1<List<_i8.Locale>>(
          this,
          Invocation.method(
            #loadSupportedLocales,
            [],
          ),
        )),
      ) as _i7.Future<_i3.Result<List<_i8.Locale>>>);

  @override
  _i7.Future<List<String>> getAvailableThemes() => (super.noSuchMethod(
        Invocation.method(
          #getAvailableThemes,
          [],
        ),
        returnValue: _i7.Future<List<String>>.value(<String>[]),
      ) as _i7.Future<List<String>>);

  @override
  _i7.Future<_i3.Result<List<_i5.DatabaseDataFile>>> loadDataFiles() =>
      (super.noSuchMethod(
        Invocation.method(
          #loadDataFiles,
          [],
        ),
        returnValue: _i7.Future<_i3.Result<List<_i5.DatabaseDataFile>>>.value(
            _FakeResult_1<List<_i5.DatabaseDataFile>>(
          this,
          Invocation.method(
            #loadDataFiles,
            [],
          ),
        )),
      ) as _i7.Future<_i3.Result<List<_i5.DatabaseDataFile>>>);

  @override
  _i3.Result<_i9.GraphWidgetParameters> getGraphWidgetParameters() =>
      (super.noSuchMethod(
        Invocation.method(
          #getGraphWidgetParameters,
          [],
        ),
        returnValue: _FakeResult_1<_i9.GraphWidgetParameters>(
          this,
          Invocation.method(
            #getGraphWidgetParameters,
            [],
          ),
        ),
      ) as _i3.Result<_i9.GraphWidgetParameters>);

  @override
  _i7.Future<_i3.Result<void>> deleteFile(String? filename) =>
      (super.noSuchMethod(
        Invocation.method(
          #deleteFile,
          [filename],
        ),
        returnValue: _i7.Future<_i3.Result<void>>.value(_FakeResult_1<void>(
          this,
          Invocation.method(
            #deleteFile,
            [filename],
          ),
        )),
      ) as _i7.Future<_i3.Result<void>>);

  @override
  _i7.Future<_i3.Result<void>> exportDataFileAsImage(
          _i5.DatabaseDataFile? file) =>
      (super.noSuchMethod(
        Invocation.method(
          #exportDataFileAsImage,
          [file],
        ),
        returnValue: _i7.Future<_i3.Result<void>>.value(_FakeResult_1<void>(
          this,
          Invocation.method(
            #exportDataFileAsImage,
            [file],
          ),
        )),
      ) as _i7.Future<_i3.Result<void>>);

  @override
  _i7.Future<_i3.Result<_i5.DatabaseDataFile>> shareFile(String? filename) =>
      (super.noSuchMethod(
        Invocation.method(
          #shareFile,
          [filename],
        ),
        returnValue: _i7.Future<_i3.Result<_i5.DatabaseDataFile>>.value(
            _FakeResult_1<_i5.DatabaseDataFile>(
          this,
          Invocation.method(
            #shareFile,
            [filename],
          ),
        )),
      ) as _i7.Future<_i3.Result<_i5.DatabaseDataFile>>);

  @override
  _i3.Result<List<_i10.FlSpot>> extractStaticData(String? filename) =>
      (super.noSuchMethod(
        Invocation.method(
          #extractStaticData,
          [filename],
        ),
        returnValue: _FakeResult_1<List<_i10.FlSpot>>(
          this,
          Invocation.method(
            #extractStaticData,
            [filename],
          ),
        ),
      ) as _i3.Result<List<_i10.FlSpot>>);

  @override
  _i3.Result<List<_i10.FlSpot>> extractStaticDataFromCsv(String? filename) =>
      (super.noSuchMethod(
        Invocation.method(
          #extractStaticDataFromCsv,
          [filename],
        ),
        returnValue: _FakeResult_1<List<_i10.FlSpot>>(
          this,
          Invocation.method(
            #extractStaticDataFromCsv,
            [filename],
          ),
        ),
      ) as _i3.Result<List<_i10.FlSpot>>);

  @override
  _i7.Future<_i3.Result<List<_i10.FlSpot>>> loadCsvFileAsFlSpots(
          String? filePath) =>
      (super.noSuchMethod(
        Invocation.method(
          #loadCsvFileAsFlSpots,
          [filePath],
        ),
        returnValue: _i7.Future<_i3.Result<List<_i10.FlSpot>>>.value(
            _FakeResult_1<List<_i10.FlSpot>>(
          this,
          Invocation.method(
            #loadCsvFileAsFlSpots,
            [filePath],
          ),
        )),
      ) as _i7.Future<_i3.Result<List<_i10.FlSpot>>>);

  @override
  _i7.Future<_i3.Result<List<_i10.FlSpot>>> loadJsonFileAsFlSpots(
          String? filePath) =>
      (super.noSuchMethod(
        Invocation.method(
          #loadJsonFileAsFlSpots,
          [filePath],
        ),
        returnValue: _i7.Future<_i3.Result<List<_i10.FlSpot>>>.value(
            _FakeResult_1<List<_i10.FlSpot>>(
          this,
          Invocation.method(
            #loadJsonFileAsFlSpots,
            [filePath],
          ),
        )),
      ) as _i7.Future<_i3.Result<List<_i10.FlSpot>>>);

  @override
  _i7.Future<_i3.Result<void>> saveFile(
    _i5.DatabaseDataFile? dataFile,
    List<int>? content,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #saveFile,
          [
            dataFile,
            content,
          ],
        ),
        returnValue: _i7.Future<_i3.Result<void>>.value(_FakeResult_1<void>(
          this,
          Invocation.method(
            #saveFile,
            [
              dataFile,
              content,
            ],
          ),
        )),
      ) as _i7.Future<_i3.Result<void>>);

  @override
  _i7.Future<_i3.Result<void>> saveGraphImage(
    _i11.Uint8List? imageData,
    String? measurementTitle,
    String? serialNumber,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #saveGraphImage,
          [
            imageData,
            measurementTitle,
            serialNumber,
          ],
        ),
        returnValue: _i7.Future<_i3.Result<void>>.value(_FakeResult_1<void>(
          this,
          Invocation.method(
            #saveGraphImage,
            [
              imageData,
              measurementTitle,
              serialNumber,
            ],
          ),
        )),
      ) as _i7.Future<_i3.Result<void>>);

  @override
  bool updateShouldNotify(
    List<_i5.DatabaseDataFile>? old,
    List<_i5.DatabaseDataFile>? current,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateShouldNotify,
          [
            old,
            current,
          ],
        ),
        returnValue: false,
      ) as bool);

  @override
  _i6.RemoveListener addListener(
    _i12.Listener<List<_i5.DatabaseDataFile>>? listener, {
    bool? fireImmediately = true,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #addListener,
          [listener],
          {#fireImmediately: fireImmediately},
        ),
        returnValue: () {},
      ) as _i6.RemoveListener);

  @override
  void dispose() => super.noSuchMethod(
        Invocation.method(
          #dispose,
          [],
        ),
        returnValueForMissingStub: null,
      );
}
