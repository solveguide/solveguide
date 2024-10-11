import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/issue/issue_bloc.dart';
import 'package:guide_solve/models/issue.dart';
import 'package:guide_solve/repositories/issue_repository.dart';

class SolveSummaryReviewView extends StatelessWidget {
  const SolveSummaryReviewView({
    required this.issueId,
    super.key,
  });

  final String issueId;

  @override
  Widget build(BuildContext context) {
    final issueRepository = context.read<IssueRepository>();

    return FutureBuilder<Issue?>(
      future: issueRepository.getIssueById(issueId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading issue'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final issue = snapshot.data;
        if (issue == null) {
          return const Center(child: Text('Issue not found.'));
        }
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Solution Summary',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                'Root Cause:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(issue.root),
              const SizedBox(height: 20),
              const Text(
                'Solution:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(issue.solve),
              const SizedBox(height: 20),
              // Buttons to mark as proven or disproven
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      context.read<IssueBloc>().add(
                            SolveProvenByOwner(issue: issue),
                          );
                    },
                    child: const Text('Mark as Proven'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.read<IssueBloc>().add(
                            SolveDisprovenByOwner(issue: issue),
                          );
                    },
                    child: const Text('Mark as Disproven'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
