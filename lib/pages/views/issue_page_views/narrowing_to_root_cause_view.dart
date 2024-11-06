import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/issue/issue_bloc.dart';
import 'package:guide_solve/components/issue_solving_widgets/process_status_bar.dart';
import 'package:guide_solve/models/fact.dart';
import 'package:guide_solve/models/hypothesis.dart';
import 'package:guide_solve/models/issue.dart';

class NarrowingToRootCauseView extends StatelessWidget {
  NarrowingToRootCauseView({
    required this.issueId,
    super.key,
  });

  final String issueId;

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
                        child: _possibleRootsList(
                          context,
                          currentUserId,
                          issueBloc,
                        ),
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

Widget _possibleRootsList(
    BuildContext context, String currentUserId, IssueBloc issueBloc) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: ShadCard(
        padding: EdgeInsets.all(AppSpacing.xs),
        description: Text("is a symptom of the root issue. . ."),
        backgroundColor: AppColors.public,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 80),
            child: StreamBuilder<List<Hypothesis>>(
              stream: issueBloc.hypothesesStream,
              builder: (context, hypothesesSnapshot) {
                if (hypothesesSnapshot.hasError) {
                  return const Center(
                    child: Text('Error loading root theories'),
                  );
                }
                if (!hypothesesSnapshot.hasData) {
                  return const Center(
                    child: Text('No Root Issue candidates available'),
                  );
                }
                final hypotheses = hypothesesSnapshot.data!
                    .where((hypothesis) => hypothesis
                        .perspective(currentUserId,
                            issueBloc.focusedIssue!.invitedUserIds!)
                        .allOtherStakeholdersAgree())
                    .toList();

                // Calculate rank for each hypothesis using
                // Perspective and update rank value
                for (final hypothesis in hypotheses) {
                  final perspective = hypothesis.perspective(
                    currentUserId,
                    issueBloc.focusedIssue!.invitedUserIds!,
                  );
                  hypothesis.rank = perspective.calculateConsensusRank();
                }
                // Sort hypotheses based on rank in
                // descending order (higher rank first)
                hypotheses.sort(
                  (a, b) => b.rank.compareTo(a.rank),
                );

                return ListView.builder(
                  itemCount: hypotheses.length,
                  itemBuilder: (context, index) {
                    final hypothesis = hypotheses[index];
                    final currentUserVote = hypothesis
                        .perspective(currentUserId,
                            issueBloc.focusedIssue!.invitedUserIds!)
                        .getCurrentUserVote();
                    final descLength = hypothesis.desc.length;
                    return Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                      child: ShadCard(
                        padding: EdgeInsets.all(AppSpacing.xxs),
                        title: Text(
                          hypothesis.desc
                              .substring(0, descLength < 50 ? descLength : 49),
                          style: UITextStyle.subtitle1,
                        ),
                        backgroundColor: AppColors.consensus,
                        trailing: ShadCheckbox(
                          value: currentUserVote == HypothesisVote.root
                              ? true
                              : false,
                          onChanged: (v) => context.read<IssueBloc>().add(
                                HypothesisVoteSubmitted(
                                  voteValue: v == true
                                      ? HypothesisVote.root
                                      : HypothesisVote.agree,
                                  hypothesisId: hypothesis.hypothesisId!,
                                ),
                              ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _hypothesisList(
    BuildContext context, String currentUserId, IssueBloc issueBloc) {
  final TextEditingController _textController = TextEditingController();
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
                  child: Tappable(
                    onTap: () {
                      if (hypothesis.factIds[currentUserId] == null) {
                        showCreateFactDialog(context, issueBloc, hypothesis,
                            currentUserVote, _textController);
                      } else {
                        showVoteFactDialog(context, issueBloc, hypothesis,
                            currentUserVote, _textController);
                      }
                    },
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
                      border: conflict
                          ? Border(
                              top: BorderSide(
                                color: AppColors.conflict,
                                width: 3,
                              ),
                              right: BorderSide(
                                color: AppColors.conflict,
                                width: 3,
                              ))
                          : null,
                      trailing: NarrowToRootSegmentButton(
                        hypothesis: hypothesis,
                        currentUserId: currentUserId,
                        invitedUserIds: issueBloc.focusedIssue!.invitedUserIds!,
                      ),
                    ),
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

Future<bool?> showCreateFactDialog(
  BuildContext context,
  IssueBloc issueBloc,
  Hypothesis hypothesis,
  HypothesisVote? currentUserVote,
  TextEditingController _textController,
) {
  //Fact Submitting Dialog
  return showShadDialog<bool>(
    context: context,
    builder: (context) => ShadDialog(
      title: const Text('Resolving Conflicts'),
      description:
          const Text("Add reasoning to your votes to help get to the root."),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(),
          SizedBox(height: AppSpacing.xxlg),
          // When it comes to addressing [seedStatement]
          Text.rich(
            TextSpan(
              text: 'With respect to ',
              style: UITextStyle.subtitle2,
              children: [
                TextSpan(
                  text: ' ${issueBloc.focusedIssue!.seedStatement} ',
                  style: UITextStyle.subtitle2.copyWith(
                      backgroundColor: AppColors.consensus,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          // [Current Hypothesis] [[IS/IS NOT]] a possible root of the issue because
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: ' ${hypothesis.desc} ',
                  style: UITextStyle.subtitle2.copyWith(
                      backgroundColor: AppColors.public,
                      fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: currentUserVote == HypothesisVote.agree
                      ? ' IS  '
                      : ' IS NOT  ',
                  style: UITextStyle.subtitle2.copyWith(
                      fontWeight: FontWeight.w600, fontStyle: FontStyle.italic),
                ),
                TextSpan(
                  text: 'a possible root issue because: ',
                  style: UITextStyle.subtitle2,
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md),
          // [New Fact]
          ShadInput(
            controller: _textController,
            placeholder: const Text("Enter reasoning here..."),
            onSubmitted: (value) {
              context.read<IssueBloc>().add(
                    NewFactCreated(
                        newFact: _textController.text,
                        newFactContext: currentUserVote == HypothesisVote.agree
                            ? ' IS '
                            : ' IS NOT ' + 'a possible root issue',
                        referenceObjectId: hypothesis.hypothesisId!,
                        referenceObjectType: ReferenceObjectType.hypothesis),
                  );
              Navigator.of(context).pop(); // Close the dialog
              _textController.clear();
            },
          ),
        ],
      ),
      actions: [
        ShadButton(
          child: Text('Share Reasoning'),
          onPressed: () {
            context.read<IssueBloc>().add(
                  NewFactCreated(
                      newFact: _textController.text,
                      newFactContext: (currentUserVote == HypothesisVote.agree
                              ? ' IS '
                              : ' IS NOT ') +
                          'a possible root issue',
                      referenceObjectId: hypothesis.hypothesisId!,
                      referenceObjectType: ReferenceObjectType.hypothesis),
                );
            Navigator.of(context).pop(); // Close the dialog
            _textController.clear();
          },
        )
      ],
    ),
  );
}

Future<bool?> showVoteFactDialog(
  BuildContext context,
  IssueBloc issueBloc,
  Hypothesis hypothesis,
  HypothesisVote? currentUserVote,
  TextEditingController _textController,
) {
  //Fact voting Dialog
  return showShadDialog<bool>(
    context: context,
    builder: (context) => ShadDialog(
      title: const Text('Resolving Conflicts'),
      description:
          const Text("Opine on the reasoning of others to move forward."),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(),
          SizedBox(height: AppSpacing.xxlg),
          StreamBuilder<List<Fact>>(
            stream: issueBloc.factsStream,
            builder: (context, factsSnapshot) {
              if (factsSnapshot.hasError) {
                return const Center(
                  child: Text('Error loading facts'),
                );
              }
              if (!factsSnapshot.hasData) {
                return const Center(
                  child: Text('No facts available.'),
                );
              }
              final facts = factsSnapshot.data!
                  .where((fact) => fact
                      .referenceObjects[ReferenceObjectType.hypothesis]!
                      .contains(hypothesis.hypothesisId))
                  .toList();
              if (facts.length > 0) {
                return ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: ListView.builder(
                    itemCount: facts.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xxs),
                        child: ShadCard(
                          padding: EdgeInsets.all(AppSpacing.xxs),
                          title: Text(
                            facts[index].desc,
                            style: UITextStyle.subtitle1,
                          ),
                          backgroundColor: AppColors.public,
                          trailing: Icon(Icons.how_to_vote),
                        ),
                      );
                    },
                  ),
                );
              } else {
                return const Center(
                  child: Text('No facts available.'),
                );
              }
            },
          )
        ],
      ),
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
              emptySelectionAllowed: true,
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
