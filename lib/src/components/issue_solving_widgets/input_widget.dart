import 'package:flutter/material.dart';

class InputWidget extends StatelessWidget {
  const InputWidget({
    required this.controller,
    required this.onSubmitted,
    super.key,
    this.focusNode,
    this.labelText,
    this.hintText,
  });

  final TextEditingController controller;
  final VoidCallback onSubmitted;
  final FocusNode? focusNode;
  final String? labelText;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 750,
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
