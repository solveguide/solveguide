import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/issue/issue_bloc.dart';
import 'package:guide_solve/models/hypothesis.dart';
import 'package:app_ui/app_ui.dart';

class NarrowToRootSegmentButton extends StatefulWidget {
  const NarrowToRootSegmentButton({
    required this.hypothesis,
    required this.currentUserId,
    required this.invitedUserIds,
    //required this.textController,
    //required this.focusNode,
    super.key,
  });

  final Hypothesis hypothesis;
  final String currentUserId;
  final List<String> invitedUserIds;
  //final TextEditingController textController;
  //final FocusNode focusNode;

  @override
  State<NarrowToRootSegmentButton> createState() =>
      _NarrowToRootSegmentButtonState();
}

class _NarrowToRootSegmentButtonState extends State<NarrowToRootSegmentButton> {
  HypothesisVote? currentUserVote;

  @override
  void initState() {
    super.initState();
    // Initialize the current vote
    currentUserVote = widget.hypothesis.votes[widget.currentUserId];
  }

  void _handleVote(HypothesisVote value) {
    setState(() {
      currentUserVote = value;
    });
    context.read<IssueBloc>().add(
          HypothesisVoteSubmitted(
            voteValue: value,
            hypothesisId: widget.hypothesis.hypothesisId!,
          ),
        );
  }

  // void _modifyHypothesis() {
  //   widget.textController.text = widget.hypothesis.desc;
  //   widget.focusNode.requestFocus();
  // }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<HypothesisVote>(
              segments: [
                ButtonSegment<HypothesisVote>(
                    value: HypothesisVote.disagree,
                    label: const Text('Disagree'),
                    tooltip: 'Disagree with this hypothesis.'),
                if (currentUserVote != HypothesisVote.root) ...[
                  ButtonSegment<HypothesisVote>(
                      value: HypothesisVote.agree,
                      label: const Text('Agree'),
                      tooltip:
                          'Agree that this hypothesis could be part of the issue.'),
                ],
                if (currentUserVote == HypothesisVote.root) ...[
                  ButtonSegment<HypothesisVote>(
                      value: HypothesisVote.root,
                      label: const Text('Root'),
                      tooltip: 'Select as Root Issue.'),
                ]
              ],
              selected: currentUserVote != null ? {currentUserVote!} : {},
              multiSelectionEnabled: false,
              showSelectedIcon: false,
              onSelectionChanged: (Set<HypothesisVote> newSelection) {
                if (newSelection.isNotEmpty) {
                  final selectedVote = newSelection.first;
                  _handleVote(selectedVote);
                }
              },
              style: ButtonStyle(
                padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                  EdgeInsets.symmetric(
                      horizontal: 2, vertical: 2), // Adjust padding
                ),
                minimumSize: WidgetStateProperty.all<Size>(
                  const Size(40, 20), // Reduce the minimum size of the button
                ),
                textStyle: WidgetStateProperty.all<TextStyle>(
                  const TextStyle(fontSize: 11), // Adjust font size if needed
                ),
                backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                  (states) {
                    if (states.contains(WidgetState.selected)) {
                      return currentUserVote == HypothesisVote.agree
                          ? AppColors.consensus
                          : currentUserVote == HypothesisVote.root
                              ? AppColors.consensus
                              : AppColors.conflictLight;
                    }
                    return AppColors.public;
                  },
                ),
                //padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // if (currentUserVote == 'disagree')
            //   Tooltip(
            //     message: 'Modify this hypothesis.',
            //     child: ShadButton(
            //       width: 24,
            //       height: 24,
            //       padding: EdgeInsets.zero,
            //       backgroundColor: AppColors.public,
            //       foregroundColor: AppColors.black,
            //       decoration: const ShadDecoration(
            //         secondaryBorder: ShadBorder.none,
            //         secondaryFocusedBorder: ShadBorder.none,
            //       ),
            //       icon: const Icon(Icons.arrow_upward),
            //       onPressed: _modifyHypothesis,
            //     ),
            //   ),
          ],
        ),
      ],
    );
  }
}
