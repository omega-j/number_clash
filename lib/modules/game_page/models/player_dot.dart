import 'package:flutter/material.dart';
import '../../../enums/common_enums.dart';
import 'base_dot.dart';
import 'game_dot.dart';

class PlayerDot extends StatefulWidget {
  final DotType dotType;
  final Offset position;

  const PlayerDot({required this.dotType, required this.position, Key? key})
      : super(key: key);

  // Copy-with method for immutability
  PlayerDot copyWith({DotType? dotType, Offset? position}) {
    return PlayerDot(
      dotType: dotType ?? this.dotType,
      position: position ?? this.position,
    );
  }

  PlayerDot increaseValue(int addedValue) {
    final newType = _getDotTypeForValue(dotType.value + addedValue);
    return copyWith(
        dotType: newType); // Creates a new instance with updated dotType
  }

  DotType _getDotTypeForValue(int totalValue) {
    if (totalValue >= DotType.fifty.value) return DotType.fifty;
    if (totalValue >= DotType.twenty.value) return DotType.twenty;
    if (totalValue >= DotType.five.value) return DotType.five;
    return DotType.one;
  }

  @override
  _PlayerDotState createState() => _PlayerDotState();
}

class _PlayerDotState extends State<PlayerDot> {
  late Offset position;

  @override
  void initState() {
    super.initState();
    position = widget.position;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      position += details.delta; // Update position as the dot is dragged
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
