import 'package:flutter/material.dart';

class PlainTextField extends StatelessWidget {
  final String hintText;
  const PlainTextField({
    super.key,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextField(
        keyboardType: TextInputType.multiline, // Enables line breaks
        maxLines: null,
        decoration: InputDecoration(
          hintText: hintText,
          fillColor: Theme.of(context).colorScheme.secondary,
          filled: true,
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.tertiary, width: 2.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary, width: 2.0),
          ),
        ),
      ),
    );
  }
}
