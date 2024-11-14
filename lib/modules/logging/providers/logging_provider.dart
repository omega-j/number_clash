import 'dart:async';
import 'package:logger/logger.dart';
import '../../../enums/common_enums.dart';
import '../../analytics/providers/i_analytics_provider.dart';
import 'i_log_storage.dart';
import 'i_logging_provider.dart';

class LoggingProvider implements ILoggingProvider {
  // Singleton instance
  static LoggingProvider? _instance;

  final Logger _logger = Logger();
  // final IAnalyticsProvider _analyticsProvider;
  final ILogStorage? logStorage;
  LogLevel currentLogLevel = LogLevel.debug;

  final StreamController<LogEvent> _logEventStreamController =
      StreamController<LogEvent>.broadcast();

  // Private constructor for singleton pattern
  LoggingProvider._internal({
    this.logStorage,
    // required IAnalyticsProvider analyticsProvider,
  }); // : _analyticsProvider = analyticsProvider;

  // Factory constructor returns the singleton instance
  factory LoggingProvider(
      {ILogStorage? logStorage,
      // required IAnalyticsProvider analyticsProvider
      }) {
    _instance ??= LoggingProvider._internal(
      logStorage: logStorage,
      // analyticsProvider: analyticsProvider,
    );
    return _instance!;
  }

  @override
  Stream<LogEvent> get logEventStream => _logEventStreamController.stream;

  Future<void> initialize() async {
    await logInfo("LoggingProvider initialized.");
  }

  void setLogLevel(LogLevel newLevel) {
    currentLogLevel = newLevel;
    logInfo("Log level set to $newLevel");
  }

  @override
  Future<void> logInfo(String message) async {
    final logMessage = message.isEmpty ? _getLocation() : message;
    if (_shouldLog(LogLevel.info)) {
      _logger.i(logMessage);
      _logEventStreamController.add(LogEvent(LogLevel.info, logMessage));
    }
  }

  @override
  Future<void> logWarning(String message) async {
    final logMessage = message.isEmpty ? _getLocation() : message;
    if (_shouldLog(LogLevel.warning)) {
      _logger.w(logMessage);
      _logEventStreamController.add(LogEvent(LogLevel.warning, logMessage));
    }
  }

  @override
  Future<void> logError(String message, {StackTrace? stackTrace}) async {
    final logMessage = message.isEmpty ? _getLocation() : message;
    if (_shouldLog(LogLevel.error)) {
      _logger.e(logMessage, stackTrace: stackTrace);
      _logEventStreamController
          .add(LogEvent(LogLevel.error, logMessage, stackTrace: stackTrace));
    }
  }

  @override
  Future<void> logScreenView(String screenName) async {
    if (_shouldLog(LogLevel.info)) {
      final message = "Viewing screen: $screenName";
      await logInfo(message);
      // await _analyticsProvider.logScreenView(screenName);
    }
  }

  Future<void> logEvent(String eventName,
      {Map<String, Object>? parameters}) async {
    // await _analyticsProvider.logEvent(eventName, parameters: parameters);
  }

  String _getLocation() {
    final traceLines = StackTrace.current.toString().split('\n');
    for (var line in traceLines.skip(1).take(10)) {
      final match =
          RegExp(r'([a-zA-Z0-9_]+)\.dart\((\d+):(\d+)\)').firstMatch(line);
      if (match != null) {
        return 'Location: ${match.group(1)}.dart - Line ${match.group(2)}, Column ${match.group(3)}';
      }
    }
    return 'Location not found in stack trace.';
  }

  bool _shouldLog(LogLevel logLevel) => logLevel.index >= currentLogLevel.index;

  void dispose() {
    _logEventStreamController.close();
  }
}

class LogEvent {
  final LogLevel level;
  final String message;
  final StackTrace? stackTrace;

  LogEvent(this.level, this.message, {this.stackTrace});
}
