import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/issue/issue_bloc.dart';
import 'package:guide_solve/components/issue_solving_widgets/process_status_bar.dart';
import 'package:guide_solve/models/hypothesis.dart';
import 'package:guide_solve/models/issue.dart';

class NarrowingToRootCauseView extends StatelessWidget {
  NarrowingToRootCauseView({
    required this.issueId,
    super.key,
  });

  final String issueId;
  //final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final issueBloc = context.read<IssueBloc>(); // Get the Bloc instance
    final currentUserId = issueBloc.currentUserId!;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          StreamBuilder<Issue>(
              stream: issueBloc.focusedIssueStream,
              builder: (context, issueSnapshot) {
                if (issueSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (issueSnapshot.hasError) {
                  return const Center(child: Text('Error loading issue.'));
                }
                if (!issueSnapshot.hasData) {
                  return const Center(child: Text('No issue data available.'));
                }
                final focusedIssue = issueSnapshot.data!;
                return Expanded(
                  child: Column(
                    children: [
                      //Issue Status & Navigation
                      ProcessStatusBar(),
                      const SizedBox(height: AppSpacing.lg),
                      // Consensus IssueOwner noticed the seedStatement
                      SizedBox(
                        width: 575,
                        child: Text(
                          '${focusedIssue.ownerId} noticed:',
                          style: UITextStyle.overline,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxxs),
                      ShadCard(
                        width: 600,
                        title: Text(
                          focusedIssue.seedStatement,
                          style: UITextStyle.headline6,
                        ),
                        backgroundColor: AppColors.consensus,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      const SizedBox(height: AppSpacing.md),
                      // Widening Options so far (Hypotheses list)
                      _hypothesisList(
                        context,
                        currentUserId,
                        issueBloc,
                      ),
                    ],
                  ),
                );
              }),
        ],
      ),
    );
  }
}

Widget _hypothesisList(
    BuildContext context, String currentUserId, IssueBloc issueBloc) {
  return Expanded(
    child: StreamBuilder<List<Hypothesis>>(
      stream: issueBloc.hypothesesStream,
      builder: (context, hypothesesSnapshot) {
        if (hypothesesSnapshot.hasError) {
          return const Center(
            child: Text('Error loading hypotheses'),
          );
        }
        if (!hypothesesSnapshot.hasData) {
          return const Center(
            child: Text('Submit a root issue theory.'),
          );
        }
        final hypotheses = hypothesesSnapshot.data!;

        // Calculate rank for each hypothesis using
        // Perspective and update rank value
        for (final hypothesis in hypotheses) {
          final perspective = hypothesis.perspective(
            currentUserId,
            issueBloc.focusedIssue!.invitedUserIds!,
          );
          hypothesis.rank = perspective.calculateNarrowingRank();
        }
        // Sort hypotheses based on rank in
        // descending order (higher rank first)
        hypotheses.sort(
          (a, b) => b.rank.compareTo(a.rank),
        );

        return Align(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: ListView.builder(
              itemCount: hypotheses.length,
              itemBuilder: (context, index) {
                final hypothesis = hypotheses[index];
                final currentUserVote = hypothesis
                    .perspective(
                        currentUserId, issueBloc.focusedIssue!.invitedUserIds!)
                    .getCurrentUserVote();
                final everyoneElseAgrees = hypothesis
                    .perspective(
                        currentUserId, issueBloc.focusedIssue!.invitedUserIds!)
                    .allOtherStakeholdersAgree();
                final conflict = hypothesis
                    .perspective(
                        currentUserId, issueBloc.focusedIssue!.invitedUserIds!)
                    .isCurrentUserInConflict();
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                  child: ShadCard(
                    title: Text(
                      hypothesis.desc,
                      style: UITextStyle.subtitle1,
                    ),
                    backgroundColor: currentUserVote == HypothesisVote.spinoff
                        ? AppColors.conflictLight
                        : everyoneElseAgrees
                            ? AppColors.consensus
                            : AppColors.public,
                    trailing: Stack(clipBehavior: Clip.none, children: [
                      NarrowToRootSegmentButton(
                        hypothesis: hypothesis,
                        currentUserId: currentUserId,
                        invitedUserIds: issueBloc.focusedIssue!.invitedUserIds!,
                      ),
                      if (conflict)
                        Positioned(
                          top: -8,
                          right: -8,
                          child: ShadBadge.destructive(
                            child: const Text(''),
                          ),
                        ),
                    ]),
                  ),
                );
              },
            ),
          ),
        );
      },
    ),
  );
}

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
    currentUserVote = widget.hypothesis.votes[widget.currentUserId];
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
