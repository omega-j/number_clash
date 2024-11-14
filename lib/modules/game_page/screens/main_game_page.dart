import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../enums/common_enums.dart';
import '../models/game_dot.dart';
import '../models/player_dot.dart';
import '../providers/dot_manager.dart';

class MainGamePage extends ConsumerWidget {
  const MainGamePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dotManager = ref.read(dotManagerProvider.notifier);
    
    Future.microtask(() {
      final gameDots = [
        GameDot(dotType: DotType.five, position: Offset(130.0, 390.0)),
        GameDot(dotType: DotType.twenty, position: Offset(180.0, 400.0)),
        GameDot(dotType: DotType.one, position: Offset(230.0, 410.0)),
      ];
      dotManager.addDots(gameDots);
    });

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: MediaQuery.of(context).size.width / 2,
            top: MediaQuery.of(context).size.height / 2,
            child: PlayerDot(
              dotType: DotType.one,
              initialPosition: Offset(
                MediaQuery.of(context).size.width / 2,
                MediaQuery.of(context).size.height / 2,
              ),
            ),
          ),
          Consumer(
            builder: (context, ref, child) {
              final dots = ref.watch(dotManagerProvider);
              return Stack(
                children: dots
                    .whereType<GameDot>()
                    .map((dot) => Positioned(
                          left: dot.position.dx,
                          top: dot.position.dy,
                          child: dot,
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}