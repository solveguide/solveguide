import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/issue/issue_bloc.dart';
import 'package:guide_solve/components/issue_solving_widgets/process_status_bar.dart';
import 'package:guide_solve/models/hypothesis.dart';

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
                return Expanded(
                  child: Column(
                    children: [
                      //Issue Status & Navigation
                      _issueProcessNav(context),
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
                        description: const Text(
                          'What are all the possible root issues '
                          'contributing in part or in whole to this?',
                        ),
                        backgroundColor: AppColors.consensus,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Widening User Input
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: ShadInput(
                          controller: _textController,
                          placeholder: const Text('Enter theories here.'),
                          keyboardType: TextInputType.text,
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
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Widening Options so far (Hypotheses list)
                      Expanded(
                        child: BlocBuilder<IssueBloc, IssueState>(
                          builder: (context, state) {
                            if (state is IssueProcessState) {
                              final hypothesesStream = state.hypothesesStream;

                              if (hypothesesStream != null) {
                                return StreamBuilder<List<Hypothesis>>(
                                  stream: hypothesesStream,
                                  builder: (context, hypothesesSnapshot) {
                                    if (hypothesesSnapshot.hasError) {
                                      return const Center(
                                        child: Text('Error loading hypotheses'),
                                      );
                                    }
                                    if (!hypothesesSnapshot.hasData) {
                                      return const Center(
                                        child:
                                            Text('Submit a root issue theory.'),
                                      );
                                    }
                                    final hypotheses = hypothesesSnapshot.data!;
                                    return ListView.builder(
                                      shrinkWrap: true,
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
                                );
                              }
                            }
                            return const Center(
                              child: CircularProgressIndicator(),
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

  Row _issueProcessNav(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        Expanded(
          flex: 3,
          child: ProcessStatusBar(
            currentStage: 0,
            onSegmentTapped: (index) {
              var stage = IssueProcessStage.wideningHypotheses;
              switch (index) {
                case 0:
                  stage = IssueProcessStage.wideningHypotheses;
                case 1:
                  stage = IssueProcessStage.narrowingToRootCause;
                case 2:
                  stage = IssueProcessStage.wideningSolutions;
                case 3:
                  stage = IssueProcessStage.narrowingToSolve;
              }
              BlocProvider.of<IssueBloc>(context).add(
                FocusIssueNavigationRequested(
                  stage: stage,
                ),
              );
            },
            conflictStages: const [1],
            disabledStages: const [3],
            completedStages: const [0],
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
