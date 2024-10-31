import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/issue/issue_bloc.dart';
import 'package:guide_solve/components/issue_solving_widgets/process_status_bar.dart';
import 'package:guide_solve/components/issue_solving_widgets/vote_button_hypotheses_widen.dart';
import 'package:guide_solve/models/hypothesis.dart';
import 'package:guide_solve/models/issue.dart';

class WideningHypothesesView extends StatelessWidget {
  WideningHypothesesView({
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
          StreamBuilder<Issue>(
              stream: issueBloc.focusedIssueStream,
              builder: (context, issueSnapshot) {
                if (issueSnapshot.hasError) {
                  return const Center(child: Text('Error loading issue.'));
                }

                if (!issueSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
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
                      //TODO: Add a footer here that is a list of "rootable" hypothesis
                      const SizedBox(height: AppSpacing.md),

                      // Widening User Input
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: ShadInput(
                          controller: _textController,
                          focusNode: _focusNode,
                          placeholder: const Text('Enter theories here.'),
                          keyboardType: TextInputType.text,
                          autofocus: true,
                          minLines: 1,
                          maxLines: 3,
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
                                      NewHypothesisCreated(
                                        newHypothesis: _textController.text,
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
                      _hypothesisList(context, currentUserId, issueBloc,
                          _textController, _focusNode),
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
    BuildContext context,
    String currentUserId,
    IssueBloc issueBloc,
    TextEditingController textController,
    FocusNode focusNode) {
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
        hypothesis.rank = perspective.calculateRank(
            (context.read<IssueBloc>().state as IssueProcessState).stage);
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
                  trailing: WidenHypothesesSegmentButton(
                    hypothesis: hypothesis,
                    currentUserId: currentUserId,
                    invitedUserIds: issueBloc.focusedIssue!.invitedUserIds!,
                    textController: textController,
                    focusNode: focusNode,
                  ),
                ),
              );
            },
          ),
        ),
      );
    },
  ));
}
