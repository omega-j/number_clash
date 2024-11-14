import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../enums/common_enums.dart';
import '../models/base_dot.dart';
import '../models/game_dot.dart';
import '../models/player_dot.dart';
import 'dart:math';

class DotManager extends StateNotifier<List<BaseDot>> {
  late PlayerDot playerDot;

  DotManager() : super([]) {
    // Initialize the player dot with a starting position
    playerDot = PlayerDot(dotType: DotType.one, position: Offset.zero);
    state = [playerDot];
  }

  void addDot(GameDot dot) {
    state = [...state, dot];
  }

  void updateDots() {
    // Check for collisions or links between playerDot and other gameDots
    for (var dot in state) {
      if (dot != playerDot && dot is GameDot && _isCloseEnough(playerDot, dot)) {
        _linkDots(playerDot, dot);
      }
    }
  }

  bool _isCloseEnough(PlayerDot player, GameDot other) {
    final dx = player.position.dx - other.position.dx;
    final dy = player.position.dy - other.position.dy;
    final distance = sqrt(dx * dx + dy * dy);
    return distance < 50; // Adjust as needed
  }

  void _linkDots(PlayerDot player, GameDot other) {
    // Snap dot positions together, or apply linking effect
    // Optionally remove linked dot and increase player dot value
    state = state.where((dot) => dot != other).toList();
    player.increaseValue(other.value); // Hypothetical method to increase player value
  }
}

final dotManagerProvider = StateNotifierProvider<DotManager, List<BaseDot>>((ref) {
  return DotManager();
});