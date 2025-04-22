import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/issue/issue_bloc.dart';
import 'package:guide_solve/components/issue_solving_widgets/process_status_bar.dart';
import 'package:guide_solve/models/issue.dart';

class SolveSummaryReviewView extends StatelessWidget {
  const SolveSummaryReviewView({
    required this.issueId,
    super.key,
  });

  final String issueId;

  @override
  Widget build(BuildContext context) {
    final issueBloc = context.read<IssueBloc>(); // Get the Bloc instance
    final currentUserId = issueBloc.currentUserId!;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: BlocBuilder<IssueBloc, IssueState>(
        builder: (context, state) {
          if (state is! IssueProcessState) {
            return Center(child: Text('$state'));
          }

          final issue = state.issue;
          final consensusRoot = issue
              .perspective(currentUserId, state.hypotheses, state.solutions)
              .getConsensusRoot();
          final consensusSolve = issue
              .perspective(currentUserId, state.hypotheses, state.solutions)
              .getConsensusSolve();
          final otherHypotheses =
              state.hypotheses.where((hypo) => hypo != consensusRoot).toList();
          final otherSolutions =
              state.solutions.where((sol) => sol != consensusSolve).toList();
          final facts = state.facts;

          return AppConstrainedScrollView(
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      // Process Status
                      ProcessStatusBar(),
                      const SizedBox(height: AppSpacing.lg),

                      // Solution Summary Card
                      Center(
                        child: ShadCard(
                          width: 1000,
                          backgroundColor: AppColors.consensus,
                          padding: EdgeInsets.all(AppSpacing.md),
                          title: Center(
                            child: Text(
                              'Solution Summary',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: AppSpacing.md),
                              _buildSummaryRow(
                                  'Agreed Solution:',
                                  consensusSolve?.desc ??
                                      "No solution selected"),
                              const SizedBox(height: AppSpacing.sm),
                              _buildSummaryRow('Addressing Root Issue:',
                                  consensusRoot?.desc ?? "No root selected"),
                              const SizedBox(height: AppSpacing.sm),
                              _buildSummaryRow(
                                  'Identified from:', issue.seedStatement),
                              const SizedBox(height: AppSpacing.md),

                              // Segmented Button for Solve Outcome
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SolveOutcomeSegmentedButton(issue: issue),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Alternative Hypotheses and Solutions Card
                      Center(
                        child: ShadCard(
                          width: 1000,
                          backgroundColor: AppColors.public,
                          padding: EdgeInsets.all(AppSpacing.md),
                          title: Center(
                            child: Text(
                              'Considerations',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: AppSpacing.sm,
                                    ),
                                    Text(
                                      'Root Issues',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    ...otherHypotheses
                                        .map((hypothesis) => Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: AppSpacing.sm),
                                              child: Text(
                                                hypothesis.desc,
                                                style: UITextStyle.bodyText2,
                                              ),
                                            )),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: AppSpacing.sm,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: AppSpacing.sm,
                                    ),
                                    Text(
                                      'Solutions',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    ...otherSolutions.map((solution) => Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: AppSpacing.sm),
                                          child: Text(
                                            solution.desc,
                                            style: UITextStyle.bodyText2,
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Facts Card
                      Center(
                        child: ShadCard(
                          width: 1000,
                          backgroundColor: AppColors.public,
                          padding: EdgeInsets.all(AppSpacing.md),
                          title: Center(
                            child: Text(
                              'Supporting Facts',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: facts
                                .map((fact) => Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: AppSpacing.sm),
                                      child: Text(
                                        fact.desc,
                                        style: UITextStyle.bodyText2,
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper widget for displaying label-value pairs in the summary section
  Widget _buildSummaryRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: UITextStyle.bodyText2,
        children: [
          TextSpan(
              text: label, style: const TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: ' $value'),
        ],
      ),
    );
  }
}

// Custom segmented button for selecting solve outcome
class SolveOutcomeSegmentedButton extends StatefulWidget {
  const SolveOutcomeSegmentedButton({
    required this.issue,
    super.key,
  });

  final Issue issue;

  @override
  State<SolveOutcomeSegmentedButton> createState() =>
      _SolveOutcomeSegmentedButtonState();
}

class _SolveOutcomeSegmentedButtonState
    extends State<SolveOutcomeSegmentedButton> {
  void _handleOutcomeSelection(SolveOutcome outcome) {
    final issueBloc = context.read<IssueBloc>();
    if (outcome == SolveOutcome.proven) {
      issueBloc.add(SolveProvenByOwner(issue: widget.issue));
    } else if (outcome == SolveOutcome.disproven) {
      issueBloc.add(SolveDisprovenByOwner(issue: widget.issue));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<SolveOutcome>(
      segments: [
        ButtonSegment<SolveOutcome>(
          value: SolveOutcome.disproven,
          label: const Text('Solve Failed'),
          tooltip: 'Mark the solve as unsuccessful.',
        ),
        ButtonSegment<SolveOutcome>(
          value: SolveOutcome.proven,
          label: const Text('Solve Worked'),
          tooltip: 'Mark the solve as successful.',
        ),
      ],
      selected: {},
      multiSelectionEnabled: false,
      emptySelectionAllowed: true,
      showSelectedIcon: false,
      onSelectionChanged: (Set<SolveOutcome> newSelection) {
        if (newSelection.isNotEmpty) {
          final selectedOutcome = newSelection.first;
          _handleOutcomeSelection(selectedOutcome);
        }
      },
      style: SegmentedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: TextStyle(fontSize: 14),
        backgroundColor: AppColors.public,
        selectedBackgroundColor: AppColors.consensus,
      ),
    );
  }
}

enum SolveOutcome {
  proven,
  disproven,
}
