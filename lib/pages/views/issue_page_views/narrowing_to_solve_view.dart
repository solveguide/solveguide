import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/issue/issue_bloc.dart';
import 'package:guide_solve/components/issue_solving_widgets/process_status_bar.dart';
import 'package:guide_solve/models/fact.dart';
import 'package:guide_solve/models/solution.dart';

class NarrowingToSolveView extends StatelessWidget {
  NarrowingToSolveView({
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

          final focusedIssue = state.issue;
          final hypotheses = state.hypotheses;
          final solutions = state.solutions;
          final agreedRoot = focusedIssue
                  .perspective(currentUserId, hypotheses, solutions)
                  .getConsensusRoot()
                  ?.desc ??
              "No consensus root found";

          // Calculate and sort ranks for the hypotheses
          for (final solution in solutions) {
            final perspective = solution.perspective(
              currentUserId,
              focusedIssue.invitedUserIds!,
            );
            solution.rank = perspective.calculateNarrowingRank();
          }
          solutions.sort((a, b) => b.rank.compareTo(a.rank));
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
                      'Agreed Root:',
                      style: UITextStyle.overline,
                      textAlign: TextAlign.left,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxs),
                  ShadCard(
                    width: 600,
                    title: Text(
                      agreedRoot,
                      style: UITextStyle.headline6,
                    ),
                    backgroundColor: AppColors.consensus,
                    child: _possibleSolvesList(
                      context,
                      currentUserId,
                      solutions,
                      state.issue.invitedUserIds!,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  const SizedBox(height: AppSpacing.md),
                  // Widening Options so far (Hypotheses list)
                  _solutionList(
                    context,
                    currentUserId,
                    solutions,
                    agreedRoot,
                  ),
                ],
              ),
            )
          ]);
        },
      ),
    );
  }

  Widget _possibleSolvesList(
    BuildContext context,
    String currentUserId,
    List<Solution> solutions,
    List<String> invitedUserIds,
  ) {
    // Filter for hypotheses where all stakeholders agree
    final possibleSolves = solutions
        .where((solution) => solution
            .perspective(currentUserId, invitedUserIds)
            .allOtherStakeholdersAgree())
        .toList();

    // Display list of possible root hypotheses
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: ShadCard(
          padding: EdgeInsets.all(AppSpacing.xs),
          description: Text("is best solved by . . ."),
          backgroundColor: AppColors.public,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 80),
              child: ListView.builder(
                itemCount: possibleSolves.length,
                itemBuilder: (context, index) {
                  final solution = possibleSolves[index];
                  final currentUserVote = solution
                      .perspective(currentUserId, invitedUserIds)
                      .getCurrentUserVote();
                  final descLength = solution.desc.length;

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                    child: ShadCard(
                      padding: EdgeInsets.all(AppSpacing.xxs),
                      title: Tooltip(
                        message: solution.desc,
                        child: Text(
                          solution.desc
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
                      ),
                      trailing: ShadCheckbox(
                        value: currentUserVote == SolutionVote.solve,
                        onChanged: (v) {
                          context.read<IssueBloc>().add(
                                SolutionVoteSubmitted(
                                  voteValue: v == true
                                      ? SolutionVote.solve
                                      : SolutionVote.agree,
                                  solutionId: solution.solutionId!,
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

  Widget _solutionList(BuildContext context, String currentUserId,
      List<Solution> solutions, String agreedRoot) {
    final TextEditingController _textController = TextEditingController();
    final currentState = context.read<IssueBloc>().state as IssueProcessState;
    if (solutions.isEmpty) {
      // Display message if there are no hypotheses
      return Center(
        child: Tappable(
          onTap: () => {
            context.read<IssueBloc>().add(FocusIssueNavigationRequested(
                stage: IssueProcessStage.wideningSolutions))
          },
          child: Text(
            'Submit a possible solution.',
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
          itemCount: solutions.length,
          itemBuilder: (context, index) {
            final solution = solutions[index];
            final perspective = solution.perspective(
                currentUserId, currentState.issue.invitedUserIds!);
            final currentUserVote = perspective.getCurrentUserVote();
            final everyoneElseAgrees = perspective.allOtherStakeholdersAgree();
            final conflict = perspective.isCurrentUserInConflict();
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
              child: Tappable(
                onTap: () {
                  if (solution.factIds[currentUserId] == null) {
                    showCreateSolutionFactDialog(context, currentState,
                        solution, currentUserVote, _textController, agreedRoot);
                  } else {
                    showSolutionVoteFactDialog(context, currentState, solution,
                        currentUserVote, _textController);
                  }
                },
                child: ShadCard(
                  title: Text(
                    solution.desc,
                    style: UITextStyle.subtitle1,
                  ),
                  backgroundColor: currentUserVote == SolutionVote.failed
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
                  trailing: NarrowToSolveSegmentButton(
                    solution: solution,
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

Future<bool?> showCreateSolutionFactDialog(
  BuildContext context,
  IssueProcessState currentState,
  Solution solution,
  SolutionVote? currentUserVote,
  TextEditingController _textController,
  String agreedRoot,
) {
  //Fact Submitting Dialog
  return showShadDialog<bool>(
    context: context,
    builder: (context) => ShadDialog(
      title: const Text('Resolving Conflicts'),
      description:
          const Text("Add reasoning to your votes to help find a solution."),
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
                  text: ' $agreedRoot ',
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
                  text: ' ${solution.desc} ',
                  style: UITextStyle.subtitle2.copyWith(
                      backgroundColor: AppColors.public,
                      fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: currentUserVote == SolutionVote.agree ||
                          currentUserVote == SolutionVote.solve
                      ? ' IS  '
                      : ' IS NOT  ',
                  style: UITextStyle.subtitle2.copyWith(
                      fontWeight: FontWeight.w600, fontStyle: FontStyle.italic),
                ),
                TextSpan(
                  text: 'a possible solution because: ',
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
                        newFactContext: currentUserVote == SolutionVote.agree
                            ? ' IS '
                            : ' IS NOT ' + 'a possible solution',
                        referenceObjectId: solution.solutionId!,
                        referenceObjectType: ReferenceObjectType.solution),
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
                      newFactContext: (currentUserVote == SolutionVote.agree
                              ? ' IS '
                              : ' IS NOT ') +
                          'a possible root issue',
                      referenceObjectId: solution.solutionId!,
                      referenceObjectType: ReferenceObjectType.solution),
                );
            Navigator.of(context).pop(); // Close the dialog
            _textController.clear();
          },
        )
      ],
    ),
  );
}

Future<bool?> showSolutionVoteFactDialog(
  BuildContext context,
  IssueProcessState currentState,
  Solution solution,
  SolutionVote? currentUserVote,
  TextEditingController _textController,
) {
  //Fact voting Dialog
  return showShadDialog<bool>(
      context: context,
      builder: (context) {
        final facts = currentState.facts
            .where((fact) => fact
                .referenceObjects[ReferenceObjectType.solution]!
                .contains(solution.solutionId))
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

class NarrowToSolveSegmentButton extends StatefulWidget {
  const NarrowToSolveSegmentButton({
    required this.solution,
    required this.currentUserId,
    required this.invitedUserIds,
    //required this.textController,
    //required this.focusNode,
    super.key,
  });

  final Solution solution;
  final String currentUserId;
  final List<String> invitedUserIds;
  //final TextEditingController textController;
  //final FocusNode focusNode;

  @override
  State<NarrowToSolveSegmentButton> createState() =>
      _NarrowToSolveSegmentButtonState();
}

class _NarrowToSolveSegmentButtonState
    extends State<NarrowToSolveSegmentButton> {
  SolutionVote? currentUserVote;

  @override
  void initState() {
    super.initState();
    // Initialize the current vote
    currentUserVote = widget.solution.votes[widget.currentUserId];
  }

  void _handleVote(SolutionVote value) {
    context.read<IssueBloc>().add(
          SolutionVoteSubmitted(
            voteValue: value,
            solutionId: widget.solution.solutionId!,
          ),
        );
  }

  // void _modifyHypothesis() {
  //   widget.textController.text = widget.hypothesis.desc;
  //   widget.focusNode.requestFocus();
  // }

  @override
  Widget build(BuildContext context) {
    currentUserVote = widget.solution.votes[widget.currentUserId];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<SolutionVote>(
              segments: [
                ButtonSegment<SolutionVote>(
                    value: SolutionVote.disagree,
                    label: const Text('Disagree'),
                    tooltip: 'Disagree with this solution.'),
                if (currentUserVote != SolutionVote.solve) ...[
                  ButtonSegment<SolutionVote>(
                      value: SolutionVote.agree,
                      label: const Text('Agree'),
                      tooltip:
                          'Agree that this solution could be part of the solution.'),
                ],
                if (currentUserVote == SolutionVote.solve) ...[
                  ButtonSegment<SolutionVote>(
                      value: SolutionVote.solve,
                      label: const Text('Solve'),
                      tooltip: 'Selected as Solve.'),
                ]
              ],
              selected: currentUserVote != null ? {currentUserVote!} : {},
              multiSelectionEnabled: false,
              showSelectedIcon: false,
              emptySelectionAllowed: true,
              onSelectionChanged: (Set<SolutionVote> newSelection) {
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
                      return currentUserVote == SolutionVote.agree
                          ? AppColors.consensus
                          : currentUserVote == SolutionVote.solve
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
