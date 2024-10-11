import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/issue/issue_bloc.dart';
import 'package:guide_solve/models/hypothesis.dart';
import 'package:guide_solve/repositories/issue_repository.dart';

class NarrowingToRootCauseView extends StatelessWidget {
  const NarrowingToRootCauseView({
    required this.issueId,
    super.key,
  });

  final String issueId;

  @override
  Widget build(BuildContext context) {
    final issueBloc = context.read<IssueBloc>(); // Get the Bloc instance

    // Access the current focused issue directly from the bloc
    final focusedIssue = issueBloc.focusedIssue;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Consenesus Statement
          if (focusedIssue != null)
            Text(focusedIssue.seedStatement)
          else
            const Text('No seed statement available...'),
          const SizedBox(height: 20),
          // Instructions
          const Text(
            'Select the most probable root cause from the hypotheses '
            'based on the facts established.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          //Hypothesis List
          Expanded(
            child: StreamBuilder<List<Hypothesis>>(
              stream: context.read<IssueRepository>().getHypotheses(issueId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading hypotheses'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final hypotheses = snapshot.data!;
                if (hypotheses.isEmpty) {
                  return const Center(child: Text('No hypotheses available.'));
                }
                return ListView.builder(
                  itemCount: hypotheses.length,
                  itemBuilder: (context, index) {
                    final hypothesis = hypotheses[index];
                    const dropdownValue = 'Agree';
                    return ListTile(
                      title: Text(hypothesis.desc),
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
                            value: 'Modify',
                            child: Text('Modify'),
                          ),
                          DropdownMenuItem(
                            value: 'Spinoff',
                            child: Text('Spinoff'),
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
