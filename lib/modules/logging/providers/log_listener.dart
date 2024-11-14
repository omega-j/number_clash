import 'dart:async';

import '../../../enums/common_enums.dart';
import 'i_logging_provider.dart';
import 'logging_provider.dart';

class LogListener {
  final ILoggingProvider loggingProvider;
  StreamSubscription<LogEvent>? _logSubscription; // Nullable to prevent re-initialization

  LogListener({required this.loggingProvider});

  void initialize() {
    // Check if _logSubscription is already active before initializing
    if (_logSubscription == null) {
      _logSubscription = loggingProvider.logEventStream.listen((LogEvent event) {
        switch (event.level) {
          case LogLevel.info:
            _handleInfo(event.message);
            break;
          case LogLevel.warning:
            _handleWarning(event.message);
            break;
          case LogLevel.error:
            _handleError(event);
            break;
          case LogLevel.view:
            _handleScreenView(event.message);
            break;
          default:
            print('Unhandled log level: ${event.level}');
        }
      });
    } else {
      print('LogListener already initialized. Skipping re-initialization.');
    }
  }

  void _handleInfo(String message) {
    print('Info: $message');
  }

  void _handleWarning(String message) {
    print('Warning: $message');
  }

  void _handleError(LogEvent event) {
    print('Error: ${event.message}');
    if (event.stackTrace != null) {
      print('Stack Trace: ${event.stackTrace}');
    }
  }

  void _handleScreenView(String screenName) {
    print('Screen viewed: $screenName');
  }

  void dispose() {
    // Cancel subscription if it exists
    _logSubscription?.cancel();
    _logSubscription = null; // Reset to allow re-initialization
  }
}