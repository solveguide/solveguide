import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/issue/issue_bloc.dart';
import 'package:guide_solve/components/narrow_wide.dart';
import 'package:guide_solve/models/issue.dart';

class ProcessStatusBar extends StatefulWidget {
  ProcessStatusBar({
    super.key,
    required this.perspective,
  });

  // Handle the segment tap
  void _onSegmentTapped(BuildContext context, IssueProcessStage stage) {
    BlocProvider.of<IssueBloc>(context).add(
      FocusIssueNavigationRequested(stage: stage),
    );
  }

  final IssuePerspective perspective;

  @override
  State<ProcessStatusBar> createState() => _ProcessStatusBarState();
}

class _ProcessStatusBarState extends State<ProcessStatusBar> {
  bool _isInstructionalCardVisible = false;

  @override
  Widget build(BuildContext context) {
    // Custom theme color (update with your AppColors)
    final theme = Theme.of(context);

    // List of icons representing the process
    final processIcons = [
      widenIcon(size: 16), // Widening Hypotheses
      narrowIcon(size: 16), // Narrowing to Root Cause
      widenIcon(size: 16), // Widening Solutions
      narrowIcon(size: 16), // Narrowing to Solve
    ];

    // List of process stages
    List<IssueProcessStage> _processStages = [
      IssueProcessStage.wideningHypotheses,
      IssueProcessStage.narrowingToRootCause,
      IssueProcessStage.wideningSolutions,
      IssueProcessStage.narrowingToSolve,
    ];

    return BlocBuilder<IssueBloc, IssueState>(
      builder: (context, state) {
        if (state is IssueProcessState) {
          final currentStage = state.stage;
          return ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Segments for process stages
                Row(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  // mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        // mainAxisSize: MainAxisSize.min,
                        children: List.generate(_processStages.length, (index) {
                          final stage = _processStages[index];
                          final isActive = currentStage == stage;

                          bool hasConflict;
                          bool isDisabled;
                          bool isCompleted;

                          // Determine the values of hasConflict, isDisabled, and isCompleted using a switch
                          switch (stage) {
                            case IssueProcessStage.wideningHypotheses:
                              hasConflict = !widget.perspective
                                  .hasCurrentUserVotedOnAllHypotheses();
                              isDisabled = false;
                              isCompleted = (widget.perspective
                                      .hasCurrentUserVotedOnAllHypotheses() &&
                                  widget.perspective.numberOfHypotheses() > 1);
                              break;

                            case IssueProcessStage.establishingFacts:
                              hasConflict = false;
                              isDisabled = true;
                              isCompleted = false;
                              break;

                            case IssueProcessStage.narrowingToRootCause:
                              hasConflict = widget.perspective
                                      .numberOfHypothesesInConflict() >
                                  0;
                              isDisabled = false;
                              isCompleted =
                                  widget.perspective.hasConsensusRoot();
                              break;

                            case IssueProcessStage.wideningSolutions:
                              hasConflict = !widget.perspective
                                  .hasCurrentUserVotedOnAllSolutions();
                              isDisabled = false;
                              isCompleted = (widget.perspective
                                      .hasCurrentUserVotedOnAllSolutions() &&
                                  widget.perspective.numberOfSolutions() > 1);
                              break;

                            case IssueProcessStage.narrowingToSolve:
                              hasConflict = widget.perspective
                                      .numberOfSolutionsInConflict() >
                                  0;
                              isDisabled = !widget.perspective
                                  .hasConsensusRoot(); // Example logic for disabling
                              isCompleted = widget.perspective
                                  .hasConsensusSolve(); // Example logic for completion
                              break;

                            case IssueProcessStage.scopingSolve:
                              hasConflict = false;
                              isDisabled = true;
                              isCompleted = false;
                              break;

                            case IssueProcessStage.solveSummaryReview:
                              hasConflict = false;
                              isDisabled = true;
                              isCompleted = false;
                              break;

                            default:
                              hasConflict = false;
                              isDisabled = false;
                              isCompleted = false;
                              break;
                          }

                          return Flexible(
                            fit: FlexFit.loose,
                            child: GestureDetector(
                              onTap: isDisabled
                                  ? null
                                  : () => widget._onSegmentTapped(
                                      context, _processStages[index]),
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
                                            ? theme.primaryColorDark
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
                                      processIcons[index], // Custom icons
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
                          icon: Icon(
                            _isInstructionalCardVisible
                                ? Icons.close
                                : Icons.question_mark,
                          ),
                          onPressed: () {
                            setState(
                              () {
                                _isInstructionalCardVisible =
                                    !_isInstructionalCardVisible;
                              },
                            );
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
                              currentStage: currentStage,
                              perspecitve: widget.perspective,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        } else {
          return Center(
            child: Text('No Process Navigation Available.'),
          );
        }
      },
    );
  }
}

class InstructionBody extends StatelessWidget {
  const InstructionBody({
    super.key,
    required this.currentStage,
    required this.perspecitve,
  });

  final IssueProcessStage currentStage;
  final IssuePerspective perspecitve;

  @override
  Widget build(BuildContext context) {
    switch (currentStage) {
      case IssueProcessStage.wideningHypotheses
          when perspecitve.hasCurrentUserVotedOnAllHypotheses():
        return Center(
          child: Text(
            '''You've already voted on all hypotheses. Your job here is to ensure all possible underlying causes have been explored.''',
          ),
        );
      case IssueProcessStage.wideningHypotheses
          when !perspecitve.hasCurrentUserVotedOnAllHypotheses():
        return Center(
          child: Text(
            '''Your job here is to capture all the possible underlying causes and addressable root issues that contribute to the noticed issue below.''',
          ),
        );
      case IssueProcessStage.narrowingToRootCause:
        return Center(
          child: Text(
            '''Your job here is to select a single root issue that, if solved, will have a large impact on the original issue, but is also within your power to solve.''',
          ),
        );
      case IssueProcessStage.wideningSolutions:
        return Center(
          child: Text(
            '''Your job here capture all the various ways you could address the agreed root to solve it. ''',
          ),
        );
      case IssueProcessStage.narrowingToSolve:
        return Center(
          child: Text(
            '''Your job here is to select the solution that has the best chance of resolving the agreet root issue, and is within your power to achieve.''',
          ),
        );
      case IssueProcessStage.establishingFacts:
        return Center(
          child: Text(
            '''establishingFacts''',
          ),
        );
      case IssueProcessStage.scopingSolve:
        return Center(
          child: Text(
            '''scopingSolve''',
          ),
        );
      case IssueProcessStage.solveSummaryReview:
        return Center(
          child: Text(
            '''solveSummaryReview''',
          ),
        );
      default:
        return Center(
          child: Text(
            '''No instructional content available for this stage.''',
          ),
        );
    }
  }
}
