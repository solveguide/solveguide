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
  TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    popoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUservote =
        widget.hypothesis.votes[widget.currentUserId] ?? 'Vote!';
        _textController = TextEditingController(text: widget.hypothesis.desc);

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
                  'This COULD (at least in part) be causing the initial issue.',
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
                              hypothesisId: widget.hypothesis.hypothesisId!,
                            ),
                          );
                    }
                    //popoverController.hide();
                  },
                ),
              ),
              if (currentUservote == 'disagree') ...[
                const SizedBox(height: AppSpacing.md),
                const Divider(),
                const SizedBox(height: AppSpacing.md),
                Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'What is the smallest change you can make that would change your vote to agree?',
                style: UITextStyle.bodyText2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: ShadInput(
                          controller: _textController,
                          keyboardType: TextInputType.text,
                          //expands: true,
                          autofocus: true,
                          maxLines: 3,
                          onSubmitted: (value) => {
                            if (value.isNotEmpty)
                              {
                                context.read<IssueBloc>().add(
                                      NewHypothesisCreated(
                                        newHypothesis: value,
                                      ),
                                    ),
                                    popoverController.hide(),
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
                                popoverController.hide();
                              }
                            },
                          ),
                        ),
                      ),
            ),
            const SizedBox(height: AppSpacing.md),
              ],
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
