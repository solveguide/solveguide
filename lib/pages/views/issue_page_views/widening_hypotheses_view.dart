import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/issue/issue_bloc.dart';
import 'package:guide_solve/models/hypothesis.dart';
import 'package:guide_solve/repositories/issue_repository.dart';

class WideningHypothesesView extends StatelessWidget {
  final String issueId;
  final TextEditingController _textController = TextEditingController();

  WideningHypothesesView({super.key, required this.issueId});

  @override
  Widget build(BuildContext context) {
    final issueBloc = context.read<IssueBloc>(); // Get the Bloc instance

    // Access the current focused issue directly from the bloc
    final focusedIssue = issueBloc.focusedIssue;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (focusedIssue != null)
            Text(focusedIssue.seedStatement)
          else
            const Text('No seed statement available...'),
          const SizedBox(height: 20),
          // Input field for adding new hypotheses
          TextField(
            controller: _textController,
            decoration: const InputDecoration(
              labelText: 'What is the root issue?',
              hintText: 'Enter theories here.',
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                context.read<IssueBloc>().add(
                      NewHypothesisCreated(newHypothesis: value),
                    );
                _textController.clear();
              }
            },
          ),
          const SizedBox(height: 20),
          // List of hypotheses
          Expanded(
            child: StreamBuilder<List<Hypothesis>>(
              stream: context.read<IssueRepository>().getHypotheses(issueId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading hypotheses'));
                }
                if (!snapshot.hasData) {
                  return const Center(
                      child: Text('Submit a root issue theory.'));
                }
                final hypotheses = snapshot.data!;
                return ListView.builder(
                  itemCount: hypotheses.length,
                  itemBuilder: (context, index) {
                    final hypothesis = hypotheses[index];
                    String dropdownValue = "Agree";
                    return ListTile(
                      title: Text(hypothesis.desc),
                      trailing: DropdownButton(
                        items: const [
                          DropdownMenuItem(
                              value: "Agree", child: Text('Agree')),
                          DropdownMenuItem(
                              value: "Disagree", child: Text('Disagree')),
                          DropdownMenuItem(
                              value: "Modify", child: Text('Modify')),
                          DropdownMenuItem(
                              value: "Spinoff", child: Text('Spinoff')),
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
