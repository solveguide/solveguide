/*

Any issue that is not currently in focus will be displayed using this issue tile

*/

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:guide_solve/src/components/core.dart';
import 'package:guide_solve/models/issue.dart';

class IssueTile extends StatefulWidget {
  const IssueTile({
    required this.issue,
    required this.firstButton,
    super.key,
    this.secondButton,
  });

  final Issue issue;
  final VoidCallback firstButton;
  final VoidCallback? secondButton;

  @override
  State<IssueTile> createState() => _IssueTileState();
}

class _IssueTileState extends State<IssueTile> {
  @override
  Widget build(BuildContext context) {
    var public = widget.issue.invitedUserIds!.length > 1;

    return Tappable(
      onTap: () => widget.firstButton(),
      child: ShadCard(
        title: Text(
          widget.issue.label,
          style: UITextStyle.subtitle1.copyWith(fontWeight: FontWeight.bold),
        ),
        description: Text(
          'Updated: ${formattedDate(widget.issue.lastUpdatedTimestamp)}',
          style: const TextStyle(fontSize: 10),
        ),
        backgroundColor: public ? AppColors.public : AppColors.private,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Actions --
            // Start solving Issue
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // PlainButton(
                //   onPressed: solved
                //       ? () => _showReveiwDialog(widget.issue)
                //       : () => widget.firstButton(),
                //   text: solved ? 'Review' : 'Solve',
                //   color: solved
                //       ? Theme.of(context).colorScheme.primaryContainer
                //       : Theme.of(context).colorScheme.tertiaryContainer,
                // ),
                if (public)
                  Row(
                    children: [
                      SizedBox(width: AppSpacing.md),
                      Text(
                        (widget.issue.invitedUserIds!.length - 1).toString(),
                        style: UITextStyle.subtitle1,
                      ),
                      SizedBox(width: AppSpacing.xxs),
                      Icon(
                        Icons.person_add,
                        size: 16,
                      ),
                    ],
                  ),
              ],
            ),
            // Delete Issue
            if (widget.secondButton != null)
              IconButton(
                onPressed: widget.secondButton,
                icon: const Icon(Icons.delete),
                color: Theme.of(context).colorScheme.onSurface,
              ),
            // View Stakeholders
            //
          ],
        ),
      ),
    );
  }
}
