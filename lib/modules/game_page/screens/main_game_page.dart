import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../../enums/common_enums.dart';
import '../models/player_dot.dart';
import '../models/game_dot.dart';

@RoutePage()
class MainGamePage extends StatelessWidget {
  const MainGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Display PlayerDot in the center
          Positioned(
            left: MediaQuery.of(context).size.width / 2,
            top: MediaQuery.of(context).size.height / 2,
            child: PlayerDot(
              dotType: DotType.one,
              position: Offset.zero, // Starting position
            ),
          ),
          // Add some scattered GameDots
          ..._generateGameDots(),
        ],
      ),
    );
  }

  // Function to generate scattered GameDots for testing
  List<Widget> _generateGameDots() {
    return [
      GameDot(dotType: DotType.five, position: Offset(100, 200)),
      GameDot(dotType: DotType.twenty, position: Offset(200, 300)),
      GameDot(dotType: DotType.one, position: Offset(300, 400)),
    ].map((dot) => Positioned(
      left: dot.position.dx,
      top: dot.position.dy,
      child: dot,
    )).toList();
  }
}