import 'package:flutter/material.dart';
import '../../../enums/common_enums.dart';
import 'base_dot.dart';
import 'game_dot.dart';

class PlayerDot extends StatefulWidget {
  final DotType dotType;
  final Offset initialPosition;

  const PlayerDot({required this.dotType, required this.initialPosition, Key? key}) : super(key: key);

  @override
  _PlayerDotState createState() => _PlayerDotState();
}

class _PlayerDotState extends State<PlayerDot> {
  late Offset position;

  @override
  void initState() {
    super.initState();
    // Initialize position based on initial position provided
    position = widget.initialPosition;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      // Update position based on drag delta
      position += details.delta;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanUpdate: _onPanUpdate,
        child: CircleAvatar(
          radius: 25 + (widget.dotType.value / 10),
          backgroundColor: widget.dotType.value > 0 ? Colors.blue : Colors.red,
          child: Text(
            '${widget.dotType.value.abs()}',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}