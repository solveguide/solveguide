import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/issue/issue_bloc.dart';
import 'package:guide_solve/src/components/issue_solving_widgets/process_status_bar.dart';
import 'package:guide_solve/models/solution.dart';

class WideningSolutionsView extends StatelessWidget {
  WideningSolutionsView({
    required this.issueId,
    super.key,
  });

  final String issueId;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final issueBloc = context.read<IssueBloc>(); // Get the Bloc instance
    final currentUserId = issueBloc.currentUserId!;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: BlocBuilder<IssueBloc, IssueState>(
        buildWhen: (previous, current) {
          // Only rebuild when the text controller is empty, so it won’t clear typed text on state updates
          return _textController.text.isEmpty;
        },
        builder: (context, state) {
          // Ensure the state is the specific IssueProcessState type
          if (state is! IssueProcessState) {
            return Center(child: Text('$state'));
          }

          // Access the data directly from the state
          final focusedIssue = state.issue;
          final solutions = state.solutions;
          final hypotheses = state.hypotheses;

          // Calculate rank for each hypothesis
          for (final solution in solutions) {
            final perspective = solution.perspective(
              currentUserId,
              focusedIssue.invitedUserIds!,
            );
            solution.rank = perspective.calculateConsensusRank();
          }

          // Sort hypotheses based on rank in descending order
          solutions.sort((a, b) => b.rank.compareTo(a.rank));
          return Column(
            children: [
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
                        'Agreed Root Issue:',
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
                        focusedIssue
                                .perspective(
                                    currentUserId, hypotheses, solutions)
                                .getConsensusRoot()
                                ?.desc ??
                            "No consensus root found",
                        style: UITextStyle.subtitle1
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: AppColors.consensus,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Widening User Input
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: ShadInput(
                        controller: _textController,
                        focusNode: _focusNode,
                        placeholder: const Text('Enter solutions here.'),
                        keyboardType: TextInputType.text,
                        autofocus: true,
                        minLines: 1,
                        maxLines: 3,
                        onSubmitted: (value) => {
                          if (value.isNotEmpty)
                            {
                              context.read<IssueBloc>().add(
                                    NewSolutionCreated(
                                      newSolution: value,
                                    ),
                                  ),
                            },
                          _textController.clear(),
                          _focusNode.requestFocus(),
                        },
                        suffix: ShadButton(
                          width: 24,
                          height: 24,
                          padding: EdgeInsets.zero,
                          backgroundColor: AppColors.public,
                          decoration: const ShadDecoration(
                            secondaryBorder: ShadBorder.none,
                            secondaryFocusedBorder: ShadBorder.none,
                          ),
                          icon: const Icon(Icons.check),
                          onPressed: () {
                            if (_textController.text.isNotEmpty) {
                              context.read<IssueBloc>().add(
                                    NewSolutionCreated(
                                      newSolution: _textController.text,
                                    ),
                                  );
                              _textController.clear();
                              _focusNode.requestFocus();
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Widening Options so far (Hypotheses list)
                    _solutionList(context, currentUserId, solutions,
                        _textController, _focusNode),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Widget _solutionList(
    BuildContext context,
    String currentUserId,
    List<Solution> solutions,
    TextEditingController textController,
    FocusNode focusNode) {
  if (solutions.isEmpty) {
    // Display a message when there are no hypotheses
    return Center(
      child: Text(
        'No solutions submitted yet. Start by adding one!',
        style: UITextStyle.bodyText2,
        textAlign: TextAlign.center,
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
            final currentState =
                context.read<IssueBloc>().state as IssueProcessState;
            final currentUserVote = solution
                .perspective(currentUserId, currentState.issue.invitedUserIds!)
                .getCurrentUserVote();
            final everyoneElseAgrees = solution
                .perspective(currentUserId, currentState.issue.invitedUserIds!)
                .allOtherStakeholdersAgree();

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
              child: ShadCard(
                padding: EdgeInsets.all(AppSpacing.lg),
                title: Tappable(
                  child: Text(
                    solution.desc,
                    style: UITextStyle.subtitle1,
                  ),
                  onLongPress: () {
                    textController.text = solution.desc;
                    focusNode.requestFocus();
                  },
                ),
                backgroundColor: currentUserVote == SolutionVote.failed
                    ? AppColors.conflictLight
                    : everyoneElseAgrees
                        ? AppColors.consensus
                        : AppColors.public,
                trailing: WidenSolutionsSegmentButton(
                  solution: solution,
                  currentUserId: currentUserId,
                  invitedUserIds: currentState.issue.invitedUserIds!,
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}

class WidenSolutionsSegmentButton extends StatefulWidget {
  const WidenSolutionsSegmentButton({
    required this.solution,
    required this.currentUserId,
    required this.invitedUserIds,
    super.key,
  });

  final Solution solution;
  final String currentUserId;
  final List<String> invitedUserIds;

  @override
  State<WidenSolutionsSegmentButton> createState() =>
      _WidenSolutionsSegmentButtonState();
}

class _WidenSolutionsSegmentButtonState
    extends State<WidenSolutionsSegmentButton> {
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

  @override
  Widget build(BuildContext context) {
    final solution = widget.solution;

    // Use the latest vote from the hypothesis instead of local state
    final currentUserVote = solution.votes[widget.currentUserId];
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.md),
      child: Row(
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
            selected: currentUserVote != null ? {currentUserVote} : {},
            multiSelectionEnabled: false,
            emptySelectionAllowed: true,
            showSelectedIcon: false,
            onSelectionChanged: (Set<SolutionVote> newSelection) {
              if (newSelection.isNotEmpty) {
                final selectedVote = newSelection.first;
                _handleVote(selectedVote);
              }
            },
            style: SegmentedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              maximumSize: const Size(40, 20),
              textStyle: const TextStyle(fontSize: 11),
              backgroundColor: currentUserVote == null
                  ? AppColors.private
                  : AppColors.public,
              selectedBackgroundColor: currentUserVote == SolutionVote.agree
                  ? AppColors.consensus
                  : currentUserVote == SolutionVote.solve
                      ? AppColors.consensus
                      : currentUserVote == SolutionVote.disagree
                          ? AppColors.conflictLight
                          : AppColors.private,
            ),
          ),
        ],
      ),
    );
  }
}
