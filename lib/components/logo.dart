import 'dart:math';

import 'package:flutter/material.dart';
  
Widget logoTitle(double height, {bool title = true}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _buildIconRow(),
      if (title) ...[
        SizedBox(height: height),
        _buildMainText(),
      ],
    ],
  );
}

  
  Widget _buildIconRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Transform(
          transform: Matrix4.rotationY(pi),
          alignment: Alignment.center,
          child: const Icon(Icons.psychology_outlined, size: 75),
        ),
        const Icon(Icons.psychology_alt, size: 75),
      ],
    );
  }

  Widget _buildMainText() => const Text(
        'Solve Guide',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      );