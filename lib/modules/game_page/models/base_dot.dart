import 'package:flutter/material.dart';
import '../../../enums/common_enums.dart';

abstract class BaseDot extends StatelessWidget {
  final DotType dotType;
  final Color color;
  final Offset position;

  BaseDot({required this.dotType, required this.position})
      : color = dotType.value > 0 ? Colors.blue : Colors.red;

  int get value => dotType.value;

  bool get isPositive => value > 0;

  void onCollision(BaseDot otherDot);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 25 + (value / 10),
      backgroundColor: color,
      child: Text(
        '${value.abs()}',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}