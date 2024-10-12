import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/issue/issue_bloc.dart';
import 'package:guide_solve/components/my_navigation_drawer.dart';
import 'package:guide_solve/pages/views/issue_page_views/issue_page_views.dart';

class IssuePage extends StatelessWidget {
  const IssuePage({required this.issueId, super.key});

  final String issueId;

  @override
  Widget build(BuildContext context) {
    // Start listening to the focused issue when the page is built
    context.read<IssueBloc>().add(FocusIssueSelected(issueId: issueId));
    return AppScaffold(
      releaseFocus: true,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Issue in Focus'),
      ),
      drawer: const MyNavigationDrawer(),
      body: BlocBuilder<IssueBloc, IssueState>(
        builder: (context, state) {
          if (state is IssueProcessState) {
            final focusedIssue = context.read<IssueBloc>().focusedIssue;
            switch (state.stage) {
              case IssueProcessStage.wideningHypotheses:
                return WideningHypothesesView(issueId: issueId);
              case IssueProcessStage.establishingFacts:
                return EstablishingFactsView(issueId: issueId);
              case IssueProcessStage.narrowingToRootCause:
                return NarrowingToRootCauseView(issueId: issueId);
              case IssueProcessStage.wideningSolutions:
                return WideningSolutionsView(issueId: issueId);
              case IssueProcessStage.narrowingToSolve:
                return NarrowingToSolveView(issueId: issueId);
              case IssueProcessStage.scopingSolve:
                // Add a null check for focusedIssue
                if (focusedIssue == null) {
                  return const Center(
                    child: Text('No focused issue available for solving.'),
                  );
                }
                return ScopingSolveView(
                  issueId: issueId,
                  solutionId: focusedIssue.solveSolutionId,
                );
              case IssueProcessStage.solveSummaryReview:
                return SolveSummaryReviewView(issueId: issueId);
            }
          } else if (state is IssuesListFailure) {
            return Center(child: Text('Error: ${state.error}'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
