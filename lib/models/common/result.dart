import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../modules/provider_setup/providers.dart';

class Result<T> {
  final bool success;
  final String message;
  final T? data;
  final DateTime timestamp;

  // Private constructor to initialize immutable properties
  Result._internal({
    required this.success,
    required this.message,
    this.data,
  }) : timestamp = DateTime.now() {
    _logResult();
  }

  static const String successPrefix = 'Result Success:';
  static const String failurePrefix = 'Result Failure:';

  // Factory for success result with named parameters
  factory Result.success({String? message, T? data}) {
    final prefixedMessage = message != null ? '$successPrefix $message' : '';
    return Result<T>._internal(
      success: true,
      message: prefixedMessage,
      data: data,
    );
  }

  // Factory for failure result with named parameters
  factory Result.failure({
    required String message,
    Object? exception,
    StackTrace? stackTrace,
  }) {
    final prefixedMessage = '$failurePrefix $message';
    return Result<T>._internal(
      success: false,
      message: prefixedMessage,
    );
  }

  // Log result
  void _logResult() {
    try {
      final container = ProviderContainer();
      final logger = container.read(loggingProvider);
      if (success) {
        logger.logInfo(message);
      } else {
        logger.logError(message);
      }
    } catch (e) {
      print("Error accessing logging provider: $e");
    }
  }

  // Read-only properties for success and failure checks
  bool get isSuccessful => success;
  bool get isFailure => !success;
  bool get isSuccessfulAndDataIsNotNull => success && data != null;
  bool get dataIsNull => data == null;
}
