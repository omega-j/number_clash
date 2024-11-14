import '../../../models/common/result.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsService {
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
}
