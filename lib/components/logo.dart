import 'dart:math';

import 'package:flutter/material.dart';

Widget logoTitle(double height, {bool title = true, double iconSize = 75}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _buildIconRow(iconSize),
      if (title) ...[
        SizedBox(height: height),
        _buildMainText(),
      ],
    ],
  );
}

Widget _buildIconRow(double iconSize) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Transform(
        transform: Matrix4.rotationY(pi),
        alignment: Alignment.center,
        child: Icon(Icons.psychology_outlined, size: iconSize),
      ),
      Icon(Icons.psychology_alt, size: iconSize),
    ],
  );
}

Widget _buildMainText() => const Text(
      'Solve Guide',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
