import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class MockPathProviderPlatform extends PathProviderPlatform {
  /// Return a fixed temporary path for testing.
  @override
  Future<String> getTemporaryPath() async => '/tmp/beta_app_test';

  /// Optionally, you can mock other path provider methods if needed:
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
