import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


// Function to create a sideways narrow icon
Widget narrowIcon() {
  return Transform.rotate(
    angle: -1.5708, // 90 degrees in radians
    child: Icon(Icons.compress),
  );
}

// Function to create a sideways widen icon
Widget widenIcon() {
  return Transform.rotate(
    angle: -1.5708, // 90 degrees in radians
    child: Icon(Icons.expand),
  );
}

// Function for displaying narrow instruction with text
Widget narrowInstructionText(String boldText,{String? text}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      narrowIcon(),
      SizedBox(width: 16), // Spacing between icon and text
      Text(boldText, style: TextStyle(fontWeight: FontWeight.bold)),
      if (text != null) ...[
        SizedBox(width: 6),
        Expanded(
          child: Text(text, softWrap: true,),
        ),
      ],
    ],
  );
}

// Function for displaying widen instruction with text
Widget widenInstructionText(String boldText,{String? text}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      widenIcon(),
      SizedBox(width: 16), // Spacing between icon and text
      Text(boldText, style: TextStyle(fontWeight: FontWeight.bold)),
      if (text != null) ...[ 
       SizedBox(width: 6),
        Expanded(
          child: Text(text, softWrap: true,),
        ),
      ],
    ],
  );
}