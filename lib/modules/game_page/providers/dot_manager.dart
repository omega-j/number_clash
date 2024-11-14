import 'dart:math';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../enums/common_enums.dart';
import '../models/base_dot.dart';
import '../models/game_dot.dart';
import '../models/player_dot_model.dart';

class DotManager extends StateNotifier<List<BaseDot>> {
  late PlayerDotModel playerDot;

  DotManager() : super([]) {
    // Initialize playerDot with a starting position
    playerDot = PlayerDotModel(dotType: DotType.one, position: Offset(200, 300));
    // Set initial state to contain playerDot only
    state = [playerDot];
    print("DotManager initialized with PlayerDot at ${playerDot.position}");
  }

  // Method to add GameDots from the MainGamePage initialization
  void addDots(List<GameDot> gameDots) {
    state = [...state, ...gameDots];
    print("Added GameDots to state:");
    for (var dot in gameDots) {
      print("GameDot at ${dot.position} with value ${dot.value}");
    }
  }

  void updatePlayerPosition(Offset newPosition) {
    print("updatePlayerPosition called with $newPosition");
    playerDot = playerDot.copyWith(position: newPosition);
    updateDots();
  }

  void updateDots() {
  // Copy of current state to prevent concurrent modification
  List<BaseDot> updatedState = List.from(state);
  bool hasLinked = false;

  print("Initial State of Dots:");
  for (var dot in updatedState) {
    if (dot is GameDot) {
      print("GameDot at ${dot.position} with value ${dot.value}");
    }
  }

  // Collect dots to remove in a separate list
  List<GameDot> dotsToRemove = [];

  for (var dot in updatedState) {
    if (dot is GameDot) {
      final distance = _calculateDistance(playerDot.position, dot.position);
      print("Checking GameDot at ${dot.position} with value ${dot.value}");
      print("Distance between PlayerDot and GameDot: $distance");

      if (_isCloseEnough(playerDot.position, dot.position)) {
        print("Linking PlayerDot with GameDot of value ${dot.value}");
        playerDot = playerDot.increaseValue(dot.value);
        dotsToRemove.add(dot); // Add dot to the list for removal
        hasLinked = true;
        print("PlayerDot new value after linking: ${playerDot.value}");
        break; // Only link one dot per update
      }
    }
  }

  // Update the state by removing the linked dots after the loop
  if (hasLinked) {
    updatedState.removeWhere((dot) => dotsToRemove.contains(dot));
    state = updatedState;
    print("Updated State after linking:");
    for (var dot in state) {
      if (dot is GameDot) {
        print("Remaining GameDot at ${dot.position} with value ${dot.value}");
      }
    }
  }
}

  double _calculateDistance(Offset position1, Offset position2) {
    final dx = position1.dx - position2.dx;
    final dy = position1.dy - position2.dy;
    return sqrt(dx * dx + dy * dy);
  }

  bool _isCloseEnough(Offset playerPosition, Offset dotPosition) {
    final distance = _calculateDistance(playerPosition, dotPosition);
    return distance < 100; // Threshold for linking
  }
}
final dotManagerProvider = StateNotifierProvider<DotManager, List<BaseDot>>((ref) {
  return DotManager();
});