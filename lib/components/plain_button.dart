import 'package:flutter/material.dart';

class PlainButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  const PlainButton({
    super.key,
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        //color: Theme.of(context).colorScheme.surface,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          side: WidgetStateProperty.all<BorderSide>(
            BorderSide(
                color: Theme.of(context).colorScheme.onSurface, width: 1),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
      ),
    );
  }
}
