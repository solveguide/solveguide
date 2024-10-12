import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/issue/issue_bloc.dart';
import 'package:guide_solve/components/issue_solving_widgets/process_status_bar.dart';
import 'package:guide_solve/models/hypothesis.dart';
import 'package:guide_solve/repositories/issue_repository.dart';

class WideningHypothesesView extends StatelessWidget {
  WideningHypothesesView({
    required this.issueId,
    super.key,
  });

  final String issueId;
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final issueBloc = context.read<IssueBloc>(); // Get the Bloc instance

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
                return Flexible(
                  child: Column(
                    children: [
                      const ProcessStatusBar(currentStage: 0),
                      // Consensus IssueOwner noticed the seedStatement
                      Text(focusedIssue.seedStatement),
                      const SizedBox(height: AppSpacing.md),

                      // Widening User Input
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
                      const SizedBox(height: AppSpacing.md),

                      // Widening Options so far (Hypotheses list)
                      Expanded(
                        child: StreamBuilder<List<Hypothesis>>(
                          stream: context
                              .read<IssueRepository>()
                              .getHypotheses(issueId),
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
