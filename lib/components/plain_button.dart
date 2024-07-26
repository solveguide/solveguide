import 'package:flutter/material.dart';

class PlainButton extends StatelessWidget {
  final VoidCallback onPressed;
  const PlainButton({
    super.key,
    required this.onPressed,
    });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        child: const Text(
          "Sign In",
        ),
      ),
    );
  }
}
