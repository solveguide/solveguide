import 'package:flutter/material.dart';

class HelpTextWidget extends StatelessWidget {
  const HelpTextWidget({
    required this.helpText,
    super.key,
  });

  final String helpText;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.help_outline),
      onPressed: () {
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Help'),
            content: Text(helpText),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}
