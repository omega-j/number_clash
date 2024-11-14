import 'package:beta_app/enums/common_enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../models/common/result.dart';
import '../../../database/providers/i_database_provider.dart';
import 'session_state.dart';

class SessionController extends StateNotifier<SessionState> {
  final IDatabaseProvider databaseProvider;

  SessionController({required this.databaseProvider})
      : super(SessionState(
          sessionId: '',
          isActive: false,
          startTime: DateTime.now(),
        ));

  Future<void> startSession() async {
    final newSessionId = Uuid().v4();
    state = state.startNewSession(newSessionId);
  }

  Future<void> endSession() async {
    if (state.isActive) {
      await saveSessionData();
      state = state.endSession();
    }
  }

  Future<Result<void>> saveSessionData() async {
    try {
      final jsonData = state.sessionData.map((e) => {'x': e.x, 'y': e.y}).toList();
      final metadata = {
        'sessionId': state.sessionId,
        'startTime': state.startTime.toIso8601String(),
        'endTime': DateTime.now().toIso8601String(),
        'isComplete': true,
      };

      final saveResult = await databaseProvider.addRecord(
        fileName: '${state.sessionId}.json',
        creationDate: state.startTime,
        measurementType: MeasurementType.data,
        fileType: DataFileType.json,
        data: {'points': jsonData},
        metadata: metadata,
      );

      if (saveResult.isSuccessful) {
        markComplete(); // Mark session as complete if saved successfully
        return Result.success();
      } else {
        return Result.failure(message: "Failed to save session data.");
      }
    } catch (e) {
      return Result.failure(message: "Error saving session data: $e");
    }
  }

  void markComplete() {
    state = state.markComplete();
  }
}