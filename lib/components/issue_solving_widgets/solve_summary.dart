import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/auth/auth_bloc.dart';
import 'package:guide_solve/bloc/issue/issue_bloc.dart';
import 'package:guide_solve/models/issue.dart';
import 'package:guide_solve/pages/issue_page.dart';

class SolveSummaryWidget extends StatelessWidget {
  final Issue issue;

  const SolveSummaryWidget({
    super.key,
    required this.issue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSummaryContainer(context),
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
                      Align(
                        alignment: Alignment.topLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: issue.hypotheses
                              .where(
                                  (hypothesis) => hypothesis.desc != issue.root)
                              .map((hypothesis) => ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(hypothesis.desc),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
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
                      Align(
                        alignment: Alignment.topLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: issue.solutions
                              .where((solution) => solution.desc != issue.solve)
                              .map((solution) => ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(solution.desc),
                                  ))
                              .toList(),
                        ),
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
  }

  Widget _buildSummaryContainer(BuildContext context) {
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
                        BlocProvider.of<IssueBloc>(context, listen: false)
                            .add(FocusRootConfirmed(confirmedRoot: issue.root));
                        // You can also navigate or do anything else
                      },
                  ),
                  const TextSpan(
                      text: '\n\nResolving that: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text: issue.root,
                      style: const TextStyle(fontWeight: FontWeight.normal)),
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
                              .add(FocusIssueSelected(issueID: issue.issueId!));
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => IssuePage(issue: issue)),
                            (route) => false,
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
