import 'package:flutter/material.dart';
import '../../../enums/common_enums.dart';
import 'base_dot.dart';
import 'game_dot.dart';

class PlayerDotModel extends BaseDot {
  final DotType dotType;
  final Offset position;

  PlayerDotModel({required this.dotType, required this.position})
      : super(dotType: dotType, position: position);

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

  @override
  void onCollision(BaseDot otherDot) {
    if (otherDot is GameDot) {
      // Increase value on collision and return a new instance with updated value
      increaseValue(otherDot.value);
      print("PlayerDot collided with GameDot. New PlayerDot value: ${value}");
    }
  }
}
