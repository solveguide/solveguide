import 'package:flutter/material.dart';

class InputWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmitted;
  final FocusNode? focusNode;
  final String? labelText;
  final String? hintText;

  const InputWidget({
    super.key,
    required this.controller,
    required this.onSubmitted,
    this.focusNode,
    this.labelText,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => onSubmitted(),
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText ?? 'Enter text here', // Default hint text
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Theme.of(context).colorScheme.tertiary,
          suffixIcon: IconButton(
            icon: const Icon(Icons.check),
            onPressed: onSubmitted,
          ),
        ),
      ),
    );
  }
}
