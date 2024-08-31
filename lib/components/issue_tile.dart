/*

Any issue that is not currently in focus will be displayed using this issue tile.

*/

import 'package:flutter/material.dart';
import 'package:guide_solve/components/core.dart';
import 'package:guide_solve/components/plain_button.dart';
import 'package:guide_solve/models/issue.dart';

class IssueTile extends StatefulWidget {
  final Issue issue;
  final VoidCallback firstButton;
  final VoidCallback? secondButton;

  const IssueTile({
    super.key,
    required this.issue,
    required this.firstButton,
    this.secondButton,
  });

  @override
  State<IssueTile> createState() => _IssueTileState();
}

class _IssueTileState extends State<IssueTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          //color of the tile
          color: Theme.of(context).colorScheme.primaryContainer,
          border: Border.all(
              color: Theme.of(context).colorScheme.onSurface, width: 1),
          //curve corners
          borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Status
              // Issue Name
              Text(_truncateString(widget.issue.label)),
              const SizedBox(
                width: 4,
              ),
              // Priority
              // Age
              Text(
                'Updated: ${formattedDate(widget.issue.lastUpdatedTimestamp)}',
                style: const TextStyle(fontSize: 10.0),
              ),
            ],
          ),
          const SizedBox(
            height: 20.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Actions --
              // Start solving Issue
              PlainButton(onPressed: () => widget.firstButton(), text: "Solve"),
              // Delete Issue
              if (widget.secondButton != null)
                PlainButton(onPressed: widget.secondButton!, text: "Delete", color: Theme.of(context).colorScheme.secondaryContainer,),
              // View Stakeholders
              //
            ],
          )
        ],
      ),
    );
  }

  String _truncateString(String text, {int maxLength = 150}) {
    if (text.length > maxLength) {
      return '${text.substring(0, maxLength)}...';
    } else {
      return text;
    }
  }
}
