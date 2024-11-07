import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/issue/issue_bloc.dart';
import 'package:guide_solve/components/narrow_wide.dart';
import 'package:guide_solve/models/issue.dart';

class ProcessStatusBar extends StatefulWidget {
  ProcessStatusBar({super.key});

  @override
  State<ProcessStatusBar> createState() => _ProcessStatusBarState();
}

class _ProcessStatusBarState extends State<ProcessStatusBar> {
  bool _isInstructionalCardVisible = false;

  void _onSegmentTapped(BuildContext context, IssueProcessStage stage) {
    context.read<IssueBloc>().add(FocusIssueNavigationRequested(stage: stage));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final issueBloc = context.read<IssueBloc>();
    if (context.read<IssueBloc>().state is! IssueProcessState) {
      return const Center(child: Text('No Process Navigation Available.'));
    }
    final currentState = context.read<IssueBloc>().state as IssueProcessState;

    // Use the focusedIssue directly
    final issue = currentState.issue;

    // List of icons representing the process
    final processIcons = [
      widenIcon(size: 16), // Widening Hypotheses
      narrowIcon(size: 16), // Narrowing to Root Cause
      widenIcon(size: 16), // Widening Solutions
      narrowIcon(size: 16), // Narrowing to Solve
    ];

    // List of process stages
    List<IssueProcessStage> processStages = [
      IssueProcessStage.wideningHypotheses,
      IssueProcessStage.narrowingToRootCause,
      IssueProcessStage.wideningSolutions,
      IssueProcessStage.narrowingToSolve,
    ];
    final hypotheses = currentState.hypotheses;
    final solutions = currentState.solutions;
    final perspective = issue.perspective(
      issueBloc.currentUserId!,
      hypotheses,
      solutions,
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(processStages.length, (index) {
                    final stage = processStages[index];
                    final currentStage =
                        (context.read<IssueBloc>().state as IssueProcessState)
                            .stage;
                    final isActive = currentStage == stage;

                    bool hasConflict;
                    bool isDisabled;
                    bool isCompleted;

                    switch (stage) {
                      case IssueProcessStage.wideningHypotheses:
                        hasConflict =
                            !perspective.hasCurrentUserVotedOnAllHypotheses();
                        isDisabled = false;
                        isCompleted =
                            (perspective.hasCurrentUserVotedOnAllHypotheses() &&
                                    perspective.numberOfHypotheses() > 1) ||
                                perspective.hasConsensusRoot();
                        break;
                      case IssueProcessStage.narrowingToRootCause:
                        hasConflict =
                            perspective.numberOfHypothesesInConflict() > 0;
                        isDisabled = false;
                        isCompleted = perspective.hasConsensusRoot();
                        break;
                      case IssueProcessStage.wideningSolutions:
                        hasConflict =
                            !perspective.hasCurrentUserVotedOnAllSolutions();
                        isDisabled = false;
                        isCompleted =
                            perspective.hasCurrentUserVotedOnAllSolutions() &&
                                perspective.numberOfSolutions() > 1;
                        break;
                      case IssueProcessStage.narrowingToSolve:
                        hasConflict =
                            perspective.numberOfSolutionsInConflict() > 0;
                        isDisabled = !perspective.hasConsensusRoot();
                        isCompleted = perspective.hasConsensusSolve();
                        break;
                      default:
                        hasConflict = false;
                        isDisabled = true;
                        isCompleted = false;
                        break;
                    }

                    return Flexible(
                      fit: FlexFit.loose,
                      child: GestureDetector(
                        onTap: isDisabled
                            ? null
                            : () =>
                                _onSegmentTapped(context, processStages[index]),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xxs),
                          padding: const EdgeInsets.all(AppSpacing.xxs),
                          decoration: BoxDecoration(
                            color: isDisabled
                                ? AppColors.grey
                                : isCompleted
                                    ? theme.primaryColorLight
                                    : theme.scaffoldBackgroundColor,
                            border: Border.all(
                              color: hasConflict
                                  ? AppColors.conflictLight
                                  : (isActive
                                      ? AppColors.blue
                                      : AppColors.grey),
                              width: isActive ? 4.0 : 1.0,
                            ),
                            borderRadius: BorderRadius.horizontal(
                              left: index == 0
                                  ? const Radius.circular(100)
                                  : Radius.zero,
                              right: index == 3
                                  ? const Radius.circular(100)
                                  : Radius.zero,
                            ),
                          ),
                          child: SizedBox(
                            width: isActive ? 70 : 50,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                processIcons[index],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: DecoratedContainer(
                  child: IconButton(
                    icon: Icon(_isInstructionalCardVisible
                        ? Icons.close
                        : Icons.question_mark),
                    onPressed: () {
                      setState(() {
                        _isInstructionalCardVisible =
                            !_isInstructionalCardVisible;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          if (_isInstructionalCardVisible)
            SizedBox(
              height: AppSpacing.md,
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isInstructionalCardVisible)
                DecoratedContainer(
                  child: SizedBox(
                    width: 450,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xlg),
                      child: InstructionBody(
                        currentStage: (context.read<IssueBloc>().state
                                as IssueProcessState)
                            .stage,
                        perspective: perspective,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class InstructionBody extends StatelessWidget {
  const InstructionBody({
    super.key,
    required this.currentStage,
    required this.perspective,
  });

  final IssueProcessStage currentStage;
  final IssuePerspective perspective;

  @override
  Widget build(BuildContext context) {
    switch (currentStage) {
      case IssueProcessStage.wideningHypotheses
          when perspective.hasCurrentUserVotedOnAllHypotheses():
        return const Center(
          child: Text(
            '''You've already voted on all hypotheses. Your job here is to ensure all possible underlying causes have been explored.''',
          ),
        );
      case IssueProcessStage.wideningHypotheses
          when !perspective.hasCurrentUserVotedOnAllHypotheses():
        return const Center(
          child: Text(
            '''Your job here is to capture all the possible underlying causes and addressable root issues that contribute to the noticed issue below.''',
          ),
        );
      case IssueProcessStage.narrowingToRootCause:
        return const Center(
          child: Text(
            '''Your job here is to select a single root issue that, if solved, will have a large impact on the original issue, but is also within your power to solve.''',
          ),
        );
      case IssueProcessStage.wideningSolutions:
        return const Center(
          child: Text(
            '''Your job here is to capture all the various ways you could address the agreed root to solve it.''',
          ),
        );
      case IssueProcessStage.narrowingToSolve:
        return const Center(
          child: Text(
            '''Your job here is to select the solution that has the best chance of resolving the agreed root issue and is within your power to achieve.''',
          ),
        );
      default:
        return const Center(
          child: Text(
            '''No instructional content available for this stage.''',
          ),
        );
    }
  }
}
