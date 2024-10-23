import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/issue/issue_bloc.dart';
import 'package:guide_solve/components/issue_solving_widgets/popover_narrowing_hypotheses.dart';
import 'package:guide_solve/components/issue_solving_widgets/process_status_bar.dart';
import 'package:guide_solve/models/hypothesis.dart';

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
          BlocBuilder<IssueBloc, IssueState>(
            builder: (context, state) {
              if (state is IssueProcessState) {
                final focusedIssue = issueBloc.focusedIssue;
                if (focusedIssue == null) {
                  return const Text('No seed statement available...');
                }
                final perspective = state.perspective;
                return Expanded(
                  child: Column(
                    children: [
                      //Issue Status & Navigation
                      ProcessStatusBar(perspective: perspective!),
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

Widget _hypothesisList(
    BuildContext context, String currentUserId, IssueBloc issueBloc) {
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
                        final conflict = hypothesis
                            .perspective(currentUserId,
                                issueBloc.focusedIssue!.invitedUserIds!)
                            .isCurrentUserInConflict();
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.xxs),
                          child: ShadCard(
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
                            trailing: Stack(clipBehavior: Clip.none, children: [
                              NarrowingHypothesesPopoverPage(
                                hypothesis: hypothesis,
                                currentUserId: currentUserId,
                                invitedUserIds:
                                    issueBloc.focusedIssue!.invitedUserIds!,
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
