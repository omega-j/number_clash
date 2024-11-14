import 'package:flutter/material.dart';
import '../../../enums/common_enums.dart';
import 'base_dot.dart';

class GameDot extends BaseDot {
  GameDot({required DotType dotType, required Offset position})
      : super(dotType: dotType, position: position);

  // Custom method to get the integer value of the dot
  static int getValue(DotType type) {
    switch (type) {
      case DotType.one:
        return 1;
      case DotType.five:
        return 5;
      case DotType.twenty:
        return 20;
      case DotType.fifty:
        return 50;
    }
  }

  @override
  void onCollision(BaseDot otherDot) {
    if (otherDot is GameDot) {
      // Example: Combine values or change color based on collision type
    }
  }
}
