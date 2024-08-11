import 'package:flutter/material.dart';
import 'package:guide_solve/models/issue.dart';

class IssuePage extends StatelessWidget {
  final Issue issue;

  const IssuePage({
    super.key,
    required this.issue,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        backgroundColor: Colors.orange[50],
        title: Text(issue.label), // Display issue label or any other detail
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Issue Details:',
            ),
            const SizedBox(height: 10),
            Text(
              issue.label, // Assuming Issue has a description
            ),
            // Add more issue details here
          ],
        ),
      ),
    );
  }
}
