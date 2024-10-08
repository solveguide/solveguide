import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/issue/issue_bloc.dart';
import 'package:guide_solve/components/my_navigation_drawer.dart';
import 'package:guide_solve/pages/views/issue_page_views/issue_page_views.dart';

class IssuePage extends StatelessWidget {
  final String issueId;

  const IssuePage({super.key, required this.issueId});

  @override
  Widget build(BuildContext context) {
    // Start listening to the focused issue when the page is built
    context.read<IssueBloc>().add(FocusIssueSelected(issueId: issueId));
    final issueBloc = context.read<IssueBloc>(); // Get the Bloc instance

    // Access the current focused issue directly from the bloc
    final focusedIssue = issueBloc.focusedIssue;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Issue in Focus"),
        backgroundColor: Colors.orange[50],
      ),
      backgroundColor: Colors.orange[50],
      drawer: const MyNavigationDrawer(),
      body: BlocBuilder<IssueBloc, IssueState>(
        builder: (context, state) {
          if (state is IssueProcessState) {
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
                return ScopingSolveView(
                  issueId: issueId,
                  solutionId: focusedIssue!.solveSolutionId,
                );
              case IssueProcessStage.solveSummaryReview:
                return SolveSummaryReviewView(issueId: issueId);
              default:
                return const Center(child: Text('Unknown stage'));
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
