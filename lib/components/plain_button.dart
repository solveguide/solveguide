import 'package:flutter/material.dart';

class PlainButton extends StatelessWidget {
  const PlainButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.red,
      ),
      child: const Center(
        child: Text(
          "Submit",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
