import 'package:flutter/material.dart';
import 'package:guide_solve/models/hypothesis.dart';
import 'package:guide_solve/models/solution.dart';

class EditItemDialog<T> extends StatefulWidget {
  final T item;
  final void Function(T updatedItem) onSave;
  final void Function(T item)? onCreateSeparateIssue;

  const EditItemDialog({
    super.key,
    required this.item,
    required this.onSave,
    this.onCreateSeparateIssue,
  });

  @override
  EditItemDialogState<T> createState() => EditItemDialogState<T>();
}

class EditItemDialogState<T> extends State<EditItemDialog<T>> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    if (widget.item is Hypothesis) {
      _controller =
          TextEditingController(text: (widget.item as Hypothesis).desc);
    } else if (widget.item is Solution) {
      _controller = TextEditingController(text: (widget.item as Solution).desc);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item is Hypothesis ? 'Edit' : 'Edit'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: widget.item is Hypothesis
                  ? 'Hypothesis Description'
                  : 'Solution Description',
              hintText: widget.item is Hypothesis
                  ? 'Edit your hypothesis here'
                  : 'Edit your solution here',
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (widget.item is Hypothesis) {
              final updatedHypothesis = Hypothesis(desc: _controller.text);
              widget.onSave(updatedHypothesis as T);
            } else if (widget.item is Solution) {
              final updatedSolution = Solution(desc: _controller.text);
              widget.onSave(updatedSolution as T);
            }
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
        if (widget.item is Hypothesis && widget.onCreateSeparateIssue != null)
          TextButton(
            onPressed: () {
              widget.onCreateSeparateIssue!(widget.item);
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
