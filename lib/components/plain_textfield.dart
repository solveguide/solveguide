import 'package:flutter/material.dart';

class PlainTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback? onSubmit;
  const PlainTextField({
    super.key,
    required this.hintText,
    required this.controller,
    required this.obscureText,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        //keyboardType: TextInputType.multiline, // Enables line breaks
        //maxLines: null,
        controller: controller,
        obscureText: obscureText,
        onSubmitted: (value) {
          // Call onSubmit if it's not null
          if (onSubmit != null) {
            onSubmit!();
          }
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
