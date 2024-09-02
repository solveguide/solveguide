/*

Any issue that is not currently in focus will be displayed using this issue tile.

*/

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/auth/auth_bloc.dart';
import 'package:guide_solve/bloc/issue/issue_bloc.dart';
import 'package:guide_solve/components/core.dart';
import 'package:guide_solve/components/issue_solving_widgets/solve_summary.dart';
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
    bool solved = false;
    if (widget.issue.solve.isNotEmpty) {
      solved = true;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          //color of the tile
          color: solved
              ? Theme.of(context).colorScheme.tertiaryContainer
              : Theme.of(context).colorScheme.primaryContainer,
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
              Text(
                _truncateString(widget.issue.label),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
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
              PlainButton(
                onPressed: solved
                    ? () => _showReveiwDialog(widget.issue)
                    : () => widget.firstButton(),
                text: solved ? "Review" : "Solve",
                color: solved
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.tertiaryContainer,
              ),
              // Delete Issue
              if (widget.secondButton != null)
                IconButton(
                  onPressed: widget.secondButton!,
                  icon: const Icon(Icons.delete),
                  color: Theme.of(context).colorScheme.onSurface,
                ),
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

  void _showReveiwDialog(issue) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding:
            EdgeInsets.zero, // Optional: Adjust padding for custom layout
        content: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SolveSummaryWidget(issue: issue),
            ),
            Positioned(
              right: 0.0,
              top: 0.0,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              final authState = context.read<AuthBloc>().state;

              if (authState is AuthSuccess) {
                BlocProvider.of<IssueBloc>(context, listen: false).add(
                    SolveProvenByOwner(issue: issue, userId: authState.uid));
                /*
            Find the solution that matches the solve
            Check that the current UserId matches the assignedStakeholderUserId
            Add the issueId to the list of provenIssueIds on that solution
            Ask the user if they discovered more spin-off issues.

            */
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .tertiaryContainer, // Background color
              foregroundColor:
                  Theme.of(context).colorScheme.onSurface, // Text color
            ),
            child: const Text('This worked!'),
          ),
          ElevatedButton(
            onPressed: () {
              final authState = context.read<AuthBloc>().state;

              if (authState is AuthSuccess) {
                BlocProvider.of<IssueBloc>(context, listen: false).add(
                    SolveDisprovenByOwner(issue: issue, userId: authState.uid));
                /*
            Find the solution that matches the solve
            Add the issueId to the list of disprovenIssueIds on that solution
            delete the issue.solve field, so the issue can be re-assessed.
            ask the user if they picked the correct root theory 
             Yes - Do they have an idea for a new solution
             No - Do they have an idea for a new hypothesis
            */
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .secondaryContainer, // Background color
              foregroundColor:
                  Theme.of(context).colorScheme.onSurface, // Text color
            ),
            child: const Text('This didn\'t work.'),
          ),
        ],
      ),
    );
  }
}
