import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/auth/auth_bloc.dart';
import 'package:guide_solve/bloc/issue/issue_bloc.dart';
import 'package:guide_solve/models/hypothesis.dart';
import 'package:guide_solve/models/issue.dart';
import 'package:guide_solve/models/solution.dart';
import 'package:guide_solve/pages/issue_page.dart';
import 'package:guide_solve/repositories/issue_repository.dart';

class SolveSummaryWidget extends StatelessWidget {
  final String issueId;

  const SolveSummaryWidget({
    super.key,
    required this.issueId,
  });

  @override
  Widget build(BuildContext context) {
    final issueRepository = context.read<IssueRepository>();

    return StreamBuilder<Issue>(
      stream: issueRepository.getFocusedIssueStream(issueId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading issue'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final issue = snapshot.data!;
        return Column(
          children: [
            _buildSummaryContainer(context, issue),
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 1000,
                decoration: BoxDecoration(
                  color: Colors.grey[300] ?? Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(width: 5, color: Colors.black),
                ),
                padding: const EdgeInsets.all(15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hypotheses Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              "Root Theories Considered:",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // StreamBuilder for hypotheses
                          StreamBuilder<List<Hypothesis>>(
                            stream: issueRepository.getHypotheses(issueId),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return const Center(
                                    child: Text('Error loading hypotheses'));
                              }
                              if (!snapshot.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              final hypotheses = snapshot.data!;
                              return _buildHypothesesList(hypotheses, issue);
                            },
                          ),
                        ],
                      ),
                    ),
                    // Solutions Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              "Solutions Considered:",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // StreamBuilder for solutions
                          StreamBuilder<List<Solution>>(
                            stream: issueRepository.getSolutions(issueId),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return const Center(
                                    child: Text('Error loading solutions'));
                              }
                              if (!snapshot.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              final solutions = snapshot.data!;
                              return _buildSolutionsList(solutions, issue);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHypothesesList(List<Hypothesis> hypotheses, Issue issue) {
    final filteredHypotheses = hypotheses
        .where((hypothesis) => hypothesis.desc != issue.root)
        .toList();

    if (filteredHypotheses.isEmpty) {
      return const Text('No other hypotheses considered.');
    }

    return Align(
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: filteredHypotheses
            .map((hypothesis) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(hypothesis.desc),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildSolutionsList(List<Solution> solutions, Issue issue) {
    final filteredSolutions =
        solutions.where((solution) => solution.desc != issue.solve).toList();

    if (filteredSolutions.isEmpty) {
      return const Text('No other solutions considered.');
    }

    return Align(
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: filteredSolutions
            .map((solution) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(solution.desc),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildSummaryContainer(BuildContext context, Issue issue) {
    return Center(
      child: Container(
        width: 500,
        decoration: BoxDecoration(
          color: Colors.lightBlue[200] ?? Colors.orange,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(width: 5, color: Colors.black),
        ),
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Your Solve:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  const TextSpan(
                      text: 'I will: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                    text: issue.solve,
                    style: const TextStyle(fontWeight: FontWeight.normal),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // Handle tap on the solution
                        // For example, navigate back to the solution selection
                        BlocProvider.of<IssueBloc>(context, listen: false).add(
                            FocusSolveConfirmed(
                                solutionId: issue.solveSolutionId));
                      },
                  ),
                  const TextSpan(
                      text: '\n\nResolving that: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                    text: issue.root,
                    style: const TextStyle(fontWeight: FontWeight.normal),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // Handle tap on the root cause
                        BlocProvider.of<IssueBloc>(context, listen: false).add(
                            FocusRootConfirmed(
                                confirmedRootHypothesisId:
                                    issue.rootHypothesisId));
                      },
                  ),
                  const TextSpan(
                      text: '\n\nChanging that: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text: issue.seedStatement,
                      style: const TextStyle(fontWeight: FontWeight.normal)),
                  TextSpan(
                    text: '\n\n\nReconsider this Solve',
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.underline,
                      fontSize: 12,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        final authState = context.read<AuthBloc>().state;

                        if (authState is AuthSuccess) {
                          BlocProvider.of<IssueBloc>(context, listen: false)
                              .add(FocusIssueSelected(issueId: issue.issueId!));
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  IssuePage(issueId: issue.issueId!),
                            ),
                            (route) => false,
                          );
                        } else {
                          // Handle unauthenticated state
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'You must be logged in to reconsider the solve.')),
                          );
                        }
                      },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
