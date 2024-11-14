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
    playerDot = PlayerDotModel(dotType: DotType.one, position: Offset.zero);
    state = [playerDot];
  }

  void addDot(GameDot dot) {
    state = [...state, dot];
  }

  void updateDots() {
    for (var dot in state) {
      if (dot != playerDot && dot is GameDot && _isCloseEnough(playerDot, dot)) {
        _linkDots(playerDot, dot);
      }
    }
  }

  bool _isCloseEnough(PlayerDotModel player, GameDot other) {
    final dx = player.position.dx - other.position.dx;
    final dy = player.position.dy - other.position.dy;
    final distance = sqrt(dx * dx + dy * dy);
    return distance < 50;
  }

  void _linkDots(PlayerDotModel player, GameDot other) {
    state = state.where((dot) => dot != other).toList();
    player.increaseValue(other.value); 
  }
}