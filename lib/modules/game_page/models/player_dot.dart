import 'package:flutter/material.dart';
import '../../../enums/common_enums.dart';
import 'base_dot.dart';
import 'game_dot.dart';

class PlayerDot extends BaseDot {
  final DotType dotType;
  final Offset position;

  PlayerDot({required this.dotType, required this.position}) : super(dotType: dotType, position: position);

  // Copy-with method for immutability
  PlayerDot copyWith({DotType? dotType, Offset? position}) {
    return PlayerDot(
      dotType: dotType ?? this.dotType,
      position: position ?? this.position,
    );
  }

  PlayerDot increaseValue(int addedValue) {
    final newType = _getDotTypeForValue(value + addedValue);
    return copyWith(dotType: newType); // Creates a new instance with updated dotType
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
      increaseValue(otherDot.value); // Instead of modifying, returns a new instance with updated value
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Draggable(
        data: this,
        feedback: CircleAvatar(
          radius: 25 + (value / 10),
          backgroundColor: color,
          child: Text(
            '${value.abs()}',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        child: CircleAvatar(
          radius: 25 + (value / 10),
          backgroundColor: color,
          child: Text(
            '${value.abs()}',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        onDragUpdate: (details) {
          // This will create a new instance with updated position when dragged
          copyWith(position: position + details.delta);
        },
      ),
    );
  }
}