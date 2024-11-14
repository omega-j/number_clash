import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/common/result.dart';
import 'iuser_settings_service.dart';

class UserSettingsService implements IUserSettingsService {
  UserSettingsService();

  @override
  Future<Result<String?>> loadLanguagePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final language = prefs.getString('language');
      return Result.success(data: language);
    } catch (e, stackTrace) {
      return Result.failure(
          message: "Failed to load language preference",
          exception: e,
          stackTrace: stackTrace);
    }
  }

  @override
  Future<Result<bool>> loadNotificationPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool('notifications') ?? true;
      return Result.success(data: isEnabled);
    } catch (e, stackTrace) {
      return Result.failure(
          message: "Failed to load notification preference",
          exception: e,
          stackTrace: stackTrace);
    }
  }

  @override
  Future<Result<bool>> loadAccessibilityPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool('accessibility') ?? false;
      return Result.success(data: isEnabled);
    } catch (e, stackTrace) {
      return Result.failure(
          message: "Failed to load accessibility preference",
          exception: e,
          stackTrace: stackTrace);
    }
  }

  @override
  Future<Result<void>> saveLanguagePreference(String language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', language);
      return Result.success();
    } catch (e, stackTrace) {
      return Result.failure(
          message: "Failed to save language preference",
          exception: e,
          stackTrace: stackTrace);
    }
  }

  @override
  Future<Result<void>> saveNotificationPreference(bool isEnabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications', isEnabled);
      return Result.success();
    } catch (e, stackTrace) {
      return Result.failure(
          message: "Failed to save notification preference",
          exception: e,
          stackTrace: stackTrace);
    }
  }

  @override
  Future<Result<void>> saveAccessibilityPreference(bool isEnabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('accessibility', isEnabled);
      return Result.success();
    } catch (e, stackTrace) {
      return Result.failure(
          message: "Failed to save accessibility preference",
          exception: e,
          stackTrace: stackTrace);
    }
  }
}