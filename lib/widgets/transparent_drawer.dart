import 'dart:ui';

import 'package:flutter/material.dart';

class TransparentDrawer extends StatelessWidget {
  final Widget child;

  TransparentDrawer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Stack(
        children: [
          // Transparent background layer with blur effect
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              color: Colors.red.withOpacity(0.3), // Adjust the opacity as needed
            ),
          ),
          // Content layer with your drawer items
          child,
        ],
      ),
    );
  }
}