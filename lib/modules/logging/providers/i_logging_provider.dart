import 'logging_provider.dart';

abstract class ILoggingProvider {
  Future<void> logInfo(String message);
  Future<void> logWarning(String message);
  Future<void> logError(String message, {StackTrace? stackTrace});
  Future<void> logScreenView(String screenName);
  Stream<LogEvent> get logEventStream;
}
