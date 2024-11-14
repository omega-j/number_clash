import '../../../models/common/result.dart';

abstract class IUserSettingsService {
  Future<Result<String?>> loadLanguagePreference();
  Future<Result<bool>> loadNotificationPreference();
  Future<Result<bool>> loadAccessibilityPreference();
  Future<Result<void>> saveLanguagePreference(String language);
  Future<Result<void>> saveNotificationPreference(bool isEnabled);
  Future<Result<void>> saveAccessibilityPreference(bool isEnabled);
}
