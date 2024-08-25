import 'package:flutter/material.dart';
import 'package:guide_solve/models/hypothesis.dart';

class EditHypothesisDialog extends StatefulWidget {
  final Hypothesis hypothesis;
  final void Function(Hypothesis updatedHypothesis) onSave;
  final void Function(Hypothesis hypothesis) onCreateSeparateIssue;

  const EditHypothesisDialog({
    super.key,
    required this.hypothesis,
    required this.onSave,
    required this.onCreateSeparateIssue,
  });

  @override
  EditHypothesisDialogState createState() => EditHypothesisDialogState();
}

class EditHypothesisDialogState extends State<EditHypothesisDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.hypothesis.desc);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Hypothesis'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Hypothesis Description',
              hintText: 'Edit your hypothesis here',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            final updatedHypothesis = Hypothesis(desc: _controller.text);
            widget.onSave(updatedHypothesis);
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
        TextButton(
          onPressed: () {
            widget.onCreateSeparateIssue(widget.hypothesis);
            Navigator.of(context).pop();
          },
          child: const Text('Create Spinoff Issue'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
