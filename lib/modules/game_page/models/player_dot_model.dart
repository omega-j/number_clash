import 'package:flutter/material.dart';
import '../../../enums/common_enums.dart';
import 'base_dot.dart';
import 'game_dot.dart';

class PlayerDotModel extends BaseDot {
  final DotType dotType;
  final Offset position;

  PlayerDotModel({required this.dotType, required this.position})
      : super(dotType: dotType, position: position);

  // Copy-with method for immutability
  PlayerDotModel copyWith({DotType? dotType, Offset? position}) {
    return PlayerDotModel(
      dotType: dotType ?? this.dotType,
      position: position ?? this.position,
    );
  }

  PlayerDotModel increaseValue(int addedValue) {
    final newType = _getDotTypeForValue(value + addedValue);
    return copyWith(dotType: newType);
  }

  DotType _getDotTypeForValue(int totalValue) {
    if (totalValue >= DotType.fifty.value) return DotType.fifty;
    if (totalValue >= DotType.twenty.value) return DotType.twenty;
    if (totalValue >= DotType.five.value) return DotType.five;
    return DotType.one;
  }

  // Implement the onCollision method required by BaseDot
  @override
  void onCollision(BaseDot otherDot) {
    if (otherDot is GameDot) {
      // Increase the value when colliding with a GameDot
      increaseValue(otherDot.value);
    }
  }
}