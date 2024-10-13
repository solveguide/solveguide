import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:guide_solve/models/hypothesis.dart';

class WidenHypothesesPopoverPage extends StatefulWidget {
  const WidenHypothesesPopoverPage({
    required this.hypothesis,
    required this.currentUserId,
    required this.invitedUserIds,
    super.key,
  });

  final Hypothesis hypothesis;
  final String currentUserId;
  final List<String> invitedUserIds;

  @override
  State<WidenHypothesesPopoverPage> createState() =>
      _WidenHypothesesPopoverPageState();
}

class _WidenHypothesesPopoverPageState
    extends State<WidenHypothesesPopoverPage> {
  final popoverController = ShadPopoverController();
  Set<String> selected = {};
  bool value = false;

  @override
  void dispose() {
    popoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUservote =
        widget.hypothesis.votes[widget.currentUserId] ?? 'No Vote';

    return Center(
      child: ShadPopover(
        controller: popoverController,
        popover: (context) => SizedBox(
          width: 288,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Display the hypothesis description
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  widget.hypothesis.desc,
                  style: UITextStyle.subtitle1,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Existing dimension settings UI
              Text(
                'Your Vote',
                style: UITextStyle.headline7,
              ),
              const SizedBox(height: AppSpacing.md),
              ShadSwitch(
                value: value,
                onChanged: (v) => setState(() => value = v),
                label: const Text('Agree'),
              ),
            ],
          ),
        ),
        child: ShadButton.outline(
          onPressed: popoverController.toggle,
          child: Text(currentUservote),
        ),
      ),
    );
  }
}
