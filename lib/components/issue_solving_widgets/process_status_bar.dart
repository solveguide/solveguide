import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:guide_solve/components/narrow_wide.dart';

class ProcessStatusBar extends StatelessWidget {
  const ProcessStatusBar({
    required this.currentStage,
    super.key,
  });

  // currentStage is an integer from 0 to 3 representing the progress
  final int currentStage;

  @override
  Widget build(BuildContext context) {
    // Custom theme color (update with your AppColors)
    final theme = Theme.of(context);

    // List of icons representing the process
    final processIcons = [
      widenIcon(), // Widening Hypotheses
      narrowIcon(), // Narrowing to Root Cause
      widenIcon(), // Widening Solutions
      narrowIcon(), // Narrowing to Solve
    ];

    return Column(
      children: [
        // Segments for process stages
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            final isActive = currentStage == index;

            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                //spacing between segments
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs), 
                padding: 
                  EdgeInsets.all(isActive ? AppSpacing.xs : AppSpacing.xxs),
                decoration: BoxDecoration(
                  color: isActive
                      ? theme.primaryColor
                      : theme.primaryColorLight,
                  borderRadius: BorderRadius.horizontal(
                    left: index == 0 ? const Radius.circular(100) : Radius.zero,
                    right: 
                      index == 3 ? const Radius.circular(100) : Radius.zero,
                  ),
                ),
                child: Column(
                  children: [
                    processIcons[index], // Custom icons
                  ],
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 10),

        // Root/Solve labels below the segments
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              'Root',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 60), // Space between Root and Solve
            Text(
              'Solve',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}
