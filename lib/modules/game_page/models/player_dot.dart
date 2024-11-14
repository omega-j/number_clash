import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../enums/common_enums.dart';
import '../providers/dot_manager.dart';

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
    position = widget.initialPosition;
  }

  void _onPanUpdate(DragUpdateDetails details, WidgetRef ref) {
    setState(() {
      position += details.delta;
      print("PlayerDot moved to $position");
    });
    ref.read(dotManagerProvider.notifier).updatePlayerPosition(position);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) => Positioned(
        left: position.dx,
        top: position.dy,
        child: GestureDetector(
          onPanUpdate: (details) => _onPanUpdate(details, ref),
          child: CircleAvatar(
            radius: 25 + (widget.dotType.value / 10),
            backgroundColor: widget.dotType.value > 0 ? Colors.blue : Colors.red,
            child: Text(
              '${widget.dotType.value.abs()}',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}