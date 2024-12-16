import 'package:flutter/material.dart';

class PlainButton extends StatelessWidget {
  // Optional color parameter

  const PlainButton({
    required this.onPressed,
    required this.text,
    super.key,
    this.color, // Add color to the constructor
  });

  final VoidCallback onPressed;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(),
      child: MaterialButton(
        onPressed: onPressed,
        color: color ??
            Theme.of(context)
                .colorScheme
                .tertiaryContainer, // Use the provided color or default
        disabledColor: Colors.grey.shade100,
        disabledTextColor: Colors.grey.shade700,
        child: Text(
          text,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
      ),
    );
  }
}
