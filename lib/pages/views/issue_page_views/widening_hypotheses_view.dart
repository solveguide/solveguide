import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/auth/auth_bloc.dart';
import 'package:guide_solve/bloc/issue/issue_bloc.dart';
import 'package:guide_solve/components/issue_solving_widgets/popover_widening_hypotheses.dart';
import 'package:guide_solve/components/issue_solving_widgets/process_status_bar.dart';
import 'package:guide_solve/models/hypothesis.dart';
import 'package:provider/provider.dart';

class WideningHypothesesView extends StatelessWidget {
  WideningHypothesesView({
    required this.issueId,
    super.key,
  });

  final String issueId;
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final issueBloc = context.read<IssueBloc>(); // Get the Bloc instance
    final currentUserId =
        Provider.of<AuthBloc>(context, listen: false).currentUserId!;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          BlocBuilder<IssueBloc, IssueState>(
            builder: (context, state) {
              if (state is IssueProcessState) {
                final focusedIssue = issueBloc.focusedIssue;
                if (focusedIssue == null) {
                  return const Text('No seed statement available...');
                }
                return Expanded(
                  child: Column(
                    children: [
                      //Issue Status & Navigation
                      _issueProcessNav(context),
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

                      // Widening User Input
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: ShadInput(
                          controller: _textController,
                          placeholder: const Text('Enter theories here.'),
                          keyboardType: TextInputType.text,
                          onSubmitted: (value) => {
                            if (value.isNotEmpty)
                              {
                                context.read<IssueBloc>().add(
                                      NewHypothesisCreated(
                                        newHypothesis: value,
                                      ),
                                    ),
                              },
                            _textController.clear(),
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
                                      NewHypothesisCreated(
                                        newHypothesis: _textController.text,
                                      ),
                                    );
                                _textController.clear();
                              }
                            },
                          ),
                        ),
                      ),
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
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _issueProcessNav(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: ProcessStatusBar(
        currentStage: 0,
        onSegmentTapped: (index) {
          var stage = IssueProcessStage.wideningHypotheses;
          switch (index) {
            case 0:
              stage = IssueProcessStage.wideningHypotheses;
            case 1:
              stage = IssueProcessStage.narrowingToRootCause;
            case 2:
              stage = IssueProcessStage.wideningSolutions;
            case 3:
              stage = IssueProcessStage.narrowingToSolve;
          }
          BlocProvider.of<IssueBloc>(context).add(
            FocusIssueNavigationRequested(
              stage: stage,
            ),
          );
        },
        conflictStages: const [],
        disabledStages: const [],
        completedStages: const [],
      ),
    );
  }
}

  Widget _hypothesisList(BuildContext context, String currentUserId, IssueBloc issueBloc) {
    return Expanded(
      child: BlocBuilder<IssueBloc, IssueState>(
        builder: (context, state) {
          if (state is IssueProcessState) {
            final hypothesesStream = state.hypothesesStream;

            if (hypothesesStream != null) {
              return StreamBuilder<List<Hypothesis>>(
                stream: hypothesesStream,
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
                    hypothesis.rank = perspective.calculateRank(state.stage);
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
                              .perspective(currentUserId,
                                  issueBloc.focusedIssue!.invitedUserIds!)
                              .getCurrentUserVote();
                          final everyoneElseAgrees = hypothesis
                              .perspective(currentUserId,
                                  issueBloc.focusedIssue!.invitedUserIds!)
                              .allOtherStakeholdersAgree();
                          return ShadCard(
                            title: Text(
                              hypothesis.desc,
                              style: UITextStyle.subtitle1,
                            ),
                            backgroundColor:
                                currentUserVote == HypothesisVote.spinoff
                                    ? AppColors.conflictLight
                                    : everyoneElseAgrees
                                        ? AppColors.consensus
                                        : AppColors.public,
                            trailing: WidenHypothesesPopoverPage(
                              hypothesis: hypothesis,
                              currentUserId: currentUserId,
                              invitedUserIds:
                                  issueBloc.focusedIssue!.invitedUserIds!,
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
