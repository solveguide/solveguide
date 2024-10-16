import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:guide_solve/components/narrow_wide.dart';

class ProcessStatusBar extends StatelessWidget {
  const ProcessStatusBar({
    required this.currentStage,
    required this.onSegmentTapped,
    required this.completedStages,
    required this.conflictStages,
    required this.disabledStages,
    super.key,
  });

  // currentStage is an integer from 0 to 3 representing the progress
  final int currentStage;

  // Callback for when a segment is tapped
  final void Function(int index) onSegmentTapped;

  // List of stages that have conflicts, will be highlighted with conflict color
  final List<int> conflictStages;

  // List of stages that are disabled
  final List<int> disabledStages;

  // List of stages that are completed
  final List<int> completedStages;

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

    return Column(
      children: [
        // Segments for process stages
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            final isActive = currentStage == index;
            final hasConflict = conflictStages.contains(index);
            final isDisabled = disabledStages.contains(index);
            final isCompleted = completedStages.contains(index);

            return Expanded(
              child: GestureDetector(
                onTap: isDisabled ? null : () => onSegmentTapped(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
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
                      left:
                          index == 0 ? const Radius.circular(100) : Radius.zero,
                      right:
                          index == 3 ? const Radius.circular(100) : Radius.zero,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      processIcons[index], // Custom icons
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
