import 'package:flutter/material.dart';

// Function to create a sideways narrow icon
Widget narrowIcon({double size = 24.0}) {
  return Transform.rotate(
    angle: -1.5708, // 90 degrees in radians
    child: Icon(
      Icons.compress,
      size: size,
    ),
  );
}

// Function to create a sideways widen icon with size parameter
Widget widenIcon({double size = 24.0}) {
  return Transform.rotate(
    angle: -1.5708, // 90 degrees in radians
    child: Icon(
      Icons.expand,
      size: size,
    ),
  );
}

// Function for displaying narrow instruction with text
Widget narrowInstructionText(String boldText, {String? text}) {
  return RichText(
    text: TextSpan(
      children: [
        WidgetSpan(
          child: Padding(
            padding: const EdgeInsets.only(right: 16), // Space after the icon
            child: narrowIcon(),
          ),
        ),
        TextSpan(
          text: boldText,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ), // Ensure text color is set
        ),
        if (text != null) ...[
          TextSpan(
            text: ' $text', // Added space for separation
            style: const TextStyle(
              color: Colors.black,
            ), // Ensure text color is set
          ),
        ],
      ],
    ),
  );
}

// Function for displaying widen instruction with text
Widget widenInstructionText(String boldText, {String? text}) {
  return RichText(
    text: TextSpan(
      children: [
        WidgetSpan(
          child: Padding(
            padding: const EdgeInsets.only(right: 16), // Space after the icon
            child: widenIcon(),
          ),
        ),
        TextSpan(
          text: boldText,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ), // Ensure text color is set
        ),
        if (text != null) ...[
          TextSpan(
            text: ' $text', // Added space for separation
            style: const TextStyle(
              color: Colors.black,
            ), // Ensure text color is set
          ),
        ],
      ],
    ),
  );
}
