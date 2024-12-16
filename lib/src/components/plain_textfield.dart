import 'package:flutter/material.dart';

class PlainTextField extends StatelessWidget {
  const PlainTextField({
    required this.hintText,
    required this.controller,
    required this.obscureText,
    super.key,
    this.onSubmit,
  });

  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: TextField(
        //keyboardType: TextInputType.multiline, // Enables line breaks
        //maxLines: null,
        controller: controller,
        obscureText: obscureText,
        onSubmitted: (value) {
          // Call onSubmit if it's not null
          onSubmit?.call();
        },
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),
          fillColor: Theme.of(context).colorScheme.secondary,
          filled: true,
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.tertiary,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
