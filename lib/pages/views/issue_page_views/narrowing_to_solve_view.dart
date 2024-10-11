import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/issue/issue_bloc.dart';
import 'package:guide_solve/models/solution.dart';
import 'package:guide_solve/repositories/issue_repository.dart';

class NarrowingToSolveView extends StatelessWidget {
  const NarrowingToSolveView({
    required this.issueId,
    super.key,
  });

  final String issueId;

  @override
  Widget build(BuildContext context) {
    final issueBloc = context.read<IssueBloc>(); // Get the Bloc instance
    final issueRepository = context.read<IssueRepository>();

    // Access the current focused issue directly from the bloc
    final focusedIssue = issueBloc.focusedIssue;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (focusedIssue != null)
            Text(focusedIssue.root)
          else
            const Text('No root issue available...'),
          const SizedBox(height: 20),
          const Text(
            'Select the best solution to implement.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<List<Solution>>(
              stream: issueRepository.getSolutions(issueId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading solutions'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final solutions = snapshot.data!;
                if (solutions.isEmpty) {
                  return const Center(child: Text('No solutions available.'));
                }
                return ListView.builder(
                  itemCount: solutions.length,
                  itemBuilder: (context, index) {
                    final solution = solutions[index];
                    const dropdownValue = 'Agree';
                    return ListTile(
                      title: Text(solution.desc),
                      trailing: DropdownButton(
                        items: const [
                          DropdownMenuItem(
                            value: 'Agree',
                            child: Text('Agree'),
                          ),
                          DropdownMenuItem(
                            value: 'Disagree',
                            child: Text('Disagree'),
                          ),
                          DropdownMenuItem(
                            value: 'Scope',
                            child: Text('Scope'),
                          ),
                          DropdownMenuItem(
                            value: 'Facts',
                            child: Text('Facts'),
                          ),
                        ],
                        value: dropdownValue,
                        onChanged: null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
