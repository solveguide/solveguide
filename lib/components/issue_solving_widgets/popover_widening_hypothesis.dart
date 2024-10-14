import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/issue/issue_bloc.dart';
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
        widget.hypothesis.votes[widget.currentUserId] ?? 'Vote!';

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
              Text(
                'Hypothesis:',
                style: UITextStyle.headline7,
              ),
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  widget.hypothesis.desc,
                  style: UITextStyle.subtitle1,
                  textAlign: TextAlign.start,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(),
              const SizedBox(height: AppSpacing.md),

              // Existing dimension settings UI
              ShadRadioGroupFormField<String>(
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
                onSaved: (value) {
                  if (value != null){
                  context.read<IssueBloc>().add(
                        HypothesisVoteSubmitted(
                          voteValue: value,
                          hypothesisId: widget.hypothesis.hypothesisId!,
                        ),
                      );
                  }
                },
                validator: (v) {
                  if (v == null) {
                    return 'You need to select an option.';
                  }
                  return null;
                },
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
