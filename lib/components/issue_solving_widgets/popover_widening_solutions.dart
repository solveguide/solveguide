import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/issue/issue_bloc.dart';
import 'package:guide_solve/models/solution.dart';

class WidenSolutionPopoverPage extends StatefulWidget {
  const WidenSolutionPopoverPage({
    required this.solution,
    required this.currentUserId,
    required this.invitedUserIds,
    super.key,
  });

  final Solution solution;
  final String currentUserId;
  final List<String> invitedUserIds;

  @override
  State<WidenSolutionPopoverPage> createState() =>
      _WidenSolutionPopoverPageState();
}

class _WidenSolutionPopoverPageState
    extends State<WidenSolutionPopoverPage> {
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
        widget.solution.votes[widget.currentUserId] ?? 'Vote!';

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
              // Text(
              //   'Hypothesis:',
              //   style: UITextStyle.headline7,
              // ),
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'This solution COULD affect the agreed root issue.',
                  style: UITextStyle.caption,
                  textAlign: TextAlign.start,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(),
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: ShadRadioGroupFormField<String>(
                  label: Text(
                    'Your Vote',
                    style: UITextStyle.headline7,
                  ),
                  initialValue: currentUservote,
                  items: const [
                    ShadRadio(
                      label: Text('Agree'),
                      value: 'agree',
                    ),
                    ShadRadio(
                      label: Text('Disagree'),
                      value: 'disagree',
                    ),
                    // ShadRadio(
                    //   label: Text('Modify'),
                    //   value: 'modify',
                    // ),
                    // ShadRadio(
                    //   label: Text('Spin Off'),
                    //   value: 'spinOff',
                    // ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      context.read<IssueBloc>().add(
                            HypothesisVoteSubmitted(
                              voteValue: value,
                              hypothesisId: widget.solution.solutionId!,
                            ),
                          );
                    }
                    popoverController.hide();
                  },
                ),
              ),
            ],
          ),
        ),
        child: ShadButton.outline(
          onPressed: popoverController.toggle,
          backgroundColor: currentUservote == 'agree'
              ? AppColors.consensus
              : currentUservote == 'disagree'
                  ? AppColors.conflictLight
                  : AppColors.white,
          child: Text(
            currentUservote,
            style: UITextStyle.subtitle1.copyWith(color: AppColors.black),
          ),
        ),
      ),
    );
  }
}
