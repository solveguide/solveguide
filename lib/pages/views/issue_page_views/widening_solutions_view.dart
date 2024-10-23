import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/issue/issue_bloc.dart';
import 'package:guide_solve/components/issue_solving_widgets/popover_widening_solutions.dart';
import 'package:guide_solve/components/issue_solving_widgets/process_status_bar.dart';
import 'package:guide_solve/models/hypothesis.dart';
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
      child: Column(
        children: [
          BlocBuilder<IssueBloc, IssueState>(
            builder: (context, state) {
              if (state is IssueProcessState) {
                final focusedIssue = issueBloc.focusedIssue;
                if (focusedIssue == null) {
                  return const Text('No root issue available...');
                }
                final perspective = state.perspective;
                return Expanded(
                  child: Column(
                    children: [
                      //Issue Status & Navigation
                      ProcessStatusBar(
                        perspective: perspective!,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      // Consensus IssueOwner noticed the seedStatement
                      SizedBox(
                        width: 575,
                        child: Text(
                          'The agreed root issue:',
                          style: UITextStyle.overline,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxxs),
                      ShadCard(
                        width: 600,
                        title: Text(
                          focusedIssue.root.isEmpty ? 'TBD' : focusedIssue.root,
                          style: UITextStyle.headline6,
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
                          placeholder:
                              const Text('Enter possible solutions here.'),
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
                      _solutionList(
                        context,
                        currentUserId,
                        issueBloc,
                      ),
                    ],
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ],
      ),
    );
  }
}

Widget _solutionList(
    BuildContext context, String currentUserId, IssueBloc issueBloc) {
  return Expanded(
    child: BlocBuilder<IssueBloc, IssueState>(
      builder: (context, state) {
        if (state is IssueProcessState) {
          final solutionsStream = state.solutionsStream;

          if (solutionsStream != null) {
            return StreamBuilder<List<Solution>>(
              stream: solutionsStream,
              builder: (context, solutionsSnapshot) {
                if (solutionsSnapshot.hasError) {
                  return const Center(
                    child: Text('Error loading solutions'),
                  );
                }
                if (!solutionsSnapshot.hasData) {
                  return const Center(
                    child: Text('Submit a possible solution.'),
                  );
                }
                final solutions = solutionsSnapshot.data!;

                // Calculate rank for each hypothesis using
                // Perspective and update rank value
                for (final solution in solutions) {
                  final perspective = solution.perspective(
                    currentUserId,
                    issueBloc.focusedIssue!.invitedUserIds!,
                  );
                  solution.rank = perspective.calculateConsensusRank();
                }
                // Sort solutions based on rank in
                // descending order (higher rank first)
                solutions.sort(
                  (a, b) => b.rank.compareTo(a.rank),
                );

                return Align(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: ListView.builder(
                      itemCount: solutions.length,
                      itemBuilder: (context, index) {
                        final solution = solutions[index];
                        final currentUserVote = solution
                            .perspective(currentUserId,
                                issueBloc.focusedIssue!.invitedUserIds!)
                            .getCurrentUserVote();
                        final everyoneElseAgrees = solution
                            .perspective(currentUserId,
                                issueBloc.focusedIssue!.invitedUserIds!)
                            .allOtherStakeholdersAgree();
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical:AppSpacing.xxs),
                          child: ShadCard(
                            title: Text(
                              solution.desc,
                              style: UITextStyle.subtitle1,
                            ),
                            backgroundColor:
                                currentUserVote == HypothesisVote.spinoff
                                    ? AppColors.conflictLight
                                    : everyoneElseAgrees
                                        ? AppColors.consensus
                                        : AppColors.public,
                            trailing: WidenSolutionPopoverPage(
                              solution: solution,
                              currentUserId: currentUserId,
                              invitedUserIds:
                                  issueBloc.focusedIssue!.invitedUserIds!,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          }
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    ),
  );
}
