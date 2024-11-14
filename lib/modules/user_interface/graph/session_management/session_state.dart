import 'package:equatable/equatable.dart';
import 'package:fl_chart/fl_chart.dart';

class SessionState extends Equatable {
  final String sessionId;
  final bool isActive;
  final DateTime startTime;
  final DateTime? endTime;
  final List<FlSpot> sessionData;
  final bool isComplete;

  const SessionState({
    required this.sessionId,
    this.isActive = false,
    required this.startTime,
    this.endTime,
    this.sessionData = const [],
    this.isComplete = false,
  });

  // Start a new session by setting a new ID and marking it active
  SessionState startNewSession(String newSessionId) {
    return SessionState(
      sessionId: newSessionId,
      isActive: true,
      startTime: DateTime.now(),
      sessionData: [], // Clear data for a new session
    );
  }

  // End the session by setting it inactive and adding the end time
  SessionState endSession() {
    return SessionState(
      sessionId: sessionId,
      isActive: false,
      startTime: startTime,
      endTime: DateTime.now(),
      sessionData: sessionData,
      isComplete: isComplete,
    );
  }

  // Method to mark session as complete
  SessionState markComplete() {
    return SessionState(
      sessionId: sessionId,
      isActive: isActive,
      startTime: startTime,
      endTime: endTime,
      sessionData: sessionData,
      isComplete: true,
    );
  }

  @override
  List<Object?> get props =>
      [sessionId, isActive, startTime, endTime, sessionData, isComplete];
}
