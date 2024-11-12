import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/auth/auth_bloc.dart';
import 'package:guide_solve/bloc/issue/issue_bloc.dart';
import 'package:guide_solve/components/issue_solving_widgets/process_status_bar.dart';
import 'package:guide_solve/models/fact.dart';
import 'package:guide_solve/models/hypothesis.dart';

class NarrowingToRootCauseView extends StatelessWidget {
  NarrowingToRootCauseView({
    required this.issueId,
    super.key,
  });

  final String issueId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: BlocBuilder<IssueBloc, IssueState>(
        builder: (context, state) {
          // Ensure the state is the specific IssueProcessState type
          if (state is! IssueProcessState) {
            return Center(child: Text('$state'));
          }
          final currentUserId = context.read<IssueBloc>().currentUserId!;
          final currentAppUserContacts = context
              .read<AuthBloc>()
              .currentAppUser!
              .contacts; // Get the current user

          final focusedIssue = state.issue;
          final hypotheses = state.hypotheses;

          // Calculate and sort ranks for the hypotheses
          for (final hypothesis in hypotheses) {
            final perspective = hypothesis.perspective(
              currentUserId,
              focusedIssue.invitedUserIds!,
            );
            hypothesis.rank = perspective.calculateNarrowingRank();
          }
          hypotheses.sort((a, b) => b.rank.compareTo(a.rank));
          return Column(children: [
            Expanded(
              child: Column(
                children: [
                  //Issue Status & Navigation
                  ProcessStatusBar(),
                  const SizedBox(height: AppSpacing.lg),
                  // Consensus IssueOwner noticed the seedStatement
                  SizedBox(
                    width: 575,
                    child: Text(
                      '${currentAppUserContacts[focusedIssue.ownerId]} noticed:',
                      style: UITextStyle.overline,
                      textAlign: TextAlign.left,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxs),
                  ShadCard(
                    width: 600,
                    padding: EdgeInsets.symmetric(
                        vertical: AppSpacing.md, horizontal: AppSpacing.lg),
                    title: Text(
                      focusedIssue.seedStatement,
                      style: UITextStyle.subtitle1
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: AppColors.consensus,
                    child: _possibleRootsList(
                      context,
                      currentUserId,
                      hypotheses,
                      state.issue.invitedUserIds!,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Widening Options so far (Hypotheses list)
                  _hypothesisList(
                    context,
                    currentUserId,
                    hypotheses,
                  ),
                ],
              ),
            )
          ]);
        },
      ),
    );
  }

  Widget _possibleRootsList(
    BuildContext context,
    String currentUserId,
    List<Hypothesis> hypotheses,
    List<String> invitedUserIds,
  ) {
    // Filter for hypotheses where all stakeholders agree
    final possibleRoots = hypotheses
        .where((hypothesis) => hypothesis
            .perspective(currentUserId, invitedUserIds)
            .allOtherStakeholdersAgree())
        .toList();

    // Display list of possible root hypotheses
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: ShadCard(
          padding: EdgeInsets.all(AppSpacing.md),
          description: Text("is a symptom of the root issue. . ."),
          backgroundColor: AppColors.public,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 80),
              child: ListView.builder(
                itemCount: possibleRoots.length,
                itemBuilder: (context, index) {
                  final hypothesis = possibleRoots[index];
                  final currentUserVote = hypothesis
                      .perspective(currentUserId, invitedUserIds)
                      .getCurrentUserVote();
                  final descLength = hypothesis.desc.length;

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                    child: ShadCard(
                      padding: EdgeInsets.all(AppSpacing.xxs),
                      title: Tooltip(
                        message: hypothesis.desc,
                        child: Text(
                          hypothesis.desc
                              .substring(0, descLength < 50 ? descLength : 49),
                          style: UITextStyle.subtitle1,
                        ),
                      ),
                      backgroundColor: AppColors.public,
                      border: Border(
                        top: BorderSide(
                          color: AppColors.consensus,
                          width: 2.0,
                        ),
                        bottom: BorderSide(
                          color: AppColors.consensus,
                          width: 2.0,
                        ),
                        left: BorderSide(
                          color: AppColors.consensus,
                          width: 2.0,
                        ),
                        right: BorderSide(
                          color: AppColors.consensus,
                          width: 2.0,
                        ),
                      ),
                      trailing: ShadCheckbox(
                        value: currentUserVote == HypothesisVote.root,
                        onChanged: (v) {
                          context.read<IssueBloc>().add(
                                HypothesisVoteSubmitted(
                                  voteValue: v == true
                                      ? HypothesisVote.root
                                      : HypothesisVote.agree,
                                  hypothesisId: hypothesis.hypothesisId!,
                                ),
                              );
                        },
                      ),
                    ),
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
      BuildContext context, String currentUserId, List<Hypothesis> hypotheses) {
    final TextEditingController _textController = TextEditingController();
    final currentState = context.read<IssueBloc>().state as IssueProcessState;
    if (hypotheses.isEmpty) {
      // Display message if there are no hypotheses
      return Center(
        child: Tappable(
          onTap: () => {
            context.read<IssueBloc>().add(FocusIssueNavigationRequested(
                stage: IssueProcessStage.wideningHypotheses))
          },
          child: Text(
            'Submit a root issue theory.',
            style: UITextStyle.bodyText2,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return Expanded(
        child: Align(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: ListView.builder(
          itemCount: hypotheses.length,
          itemBuilder: (context, index) {
            final hypothesis = hypotheses[index];
            final perspective = hypothesis.perspective(
                currentUserId, currentState.issue.invitedUserIds!);
            final currentUserVote = perspective.getCurrentUserVote();
            final everyoneElseAgrees = perspective.allOtherStakeholdersAgree();
            final conflict = perspective.isCurrentUserInConflict();
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
              child: Tappable(
                onTap: () {
                  if (hypothesis.factIds[currentUserId] == null) {
                    showCreateFactDialog(context, currentState, hypothesis,
                        currentUserVote, _textController);
                  } else {
                    showVoteFactDialog(context, currentState, hypothesis,
                        currentUserVote, _textController);
                  }
                },
                child: ShadCard(
                  padding: EdgeInsets.all(AppSpacing.lg),
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
                    invitedUserIds: currentState.issue.invitedUserIds!,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ));
  }
}

Future<bool?> showCreateFactDialog(
  BuildContext context,
  IssueProcessState currentState,
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
                  text: ' ${currentState.issue.seedStatement} ',
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
                  text: currentUserVote == HypothesisVote.agree ||
                          currentUserVote == HypothesisVote.root
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
  IssueProcessState currentState,
  Hypothesis hypothesis,
  HypothesisVote? currentUserVote,
  TextEditingController _textController,
) {
  //Fact voting Dialog
  return showShadDialog<bool>(
      context: context,
      builder: (context) {
        final facts = currentState.facts
            .where((fact) => fact
                .referenceObjects[ReferenceObjectType.hypothesis]!
                .contains(hypothesis.hypothesisId))
            .toList();
        return ShadDialog(
          title: const Text('Resolving Conflicts'),
          description:
              const Text("Opine on the reasoning of others to move forward."),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(),
              SizedBox(height: AppSpacing.xxlg),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  itemCount: facts.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
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
              ),
            ],
          ),
        );
      });
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
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.md),
      child: Row(
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
                        label: currentUserVote == HypothesisVote.root
                            ? Text('Root')
                            : Text('Agree'),
                        tooltip:
                            'Agree that this hypothesis could be part of the issue.'),
                  ],
                  if (currentUserVote == HypothesisVote.root) ...[
                    ButtonSegment<HypothesisVote>(
                        value: HypothesisVote.root,
                        label: const Text('Root'),
                        tooltip: 'Selected as Root Issue.'),
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
      ),
    );
  }
}
