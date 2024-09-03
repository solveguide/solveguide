import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/auth/auth_bloc.dart';
import 'package:guide_solve/bloc/issue/issue_bloc.dart';
import 'package:guide_solve/components/issue_solving_widgets/confirmation_widget.dart';
import 'package:guide_solve/components/issue_solving_widgets/edit_hypothesis_dialog.dart';
import 'package:guide_solve/components/issue_solving_widgets/help_text_widget.dart';
import 'package:guide_solve/components/issue_solving_widgets/input_widget.dart';
import 'package:guide_solve/components/issue_solving_widgets/resortable_list_widget.dart';
import 'package:guide_solve/components/issue_solving_widgets/solution_scoping_widget.dart';
import 'package:guide_solve/components/issue_solving_widgets/solve_summary.dart';
import 'package:guide_solve/components/my_navigation_drawer.dart';
import 'package:guide_solve/models/hypothesis.dart';
import 'package:guide_solve/models/issue.dart';
import 'package:guide_solve/models/solution.dart';
import 'package:guide_solve/pages/home_page.dart';

class IssuePage extends StatelessWidget {
  final Issue issue;

  IssuePage({super.key, required this.issue});

  final TextEditingController textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  void _showHypothesisEditDialog(
      BuildContext context, Hypothesis hypothesis, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return EditItemDialog(
          item: hypothesis,
          onSave: (updatedHypothesis) {
            BlocProvider.of<IssueBloc>(context, listen: false).add(
              HypothesisUpdated(
                index: index,
                updatedHypothesis: updatedHypothesis,
              ),
            );
          },
          onCreateSeparateIssue: (hypothesis) {
            final authState =
                BlocProvider.of<AuthBloc>(context, listen: false).state;
            if (authState is AuthSuccess) {
              BlocProvider.of<IssueBloc>(context, listen: false).add(
                CreateSeparateIssueFromHypothesis(
                  index: index,
                  hypothesis: hypothesis,
                  newIssuePrioritized: false,
                  ownerId: authState.uid,
                ),
              );
            } else {
              BlocProvider.of<AuthBloc>(context, listen: false)
                  .add(const AnnonymousUserBlocked());
            }
          },
        );
      },
    );
  }

  void _showSolutionEditDialog(
      BuildContext context, Solution solution, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return EditItemDialog(
          item: solution,
          onSave: (updatedSolution) {
            BlocProvider.of<IssueBloc>(context, listen: false).add(
              SolutionUpdated(
                index: index,
                updatedSolution: updatedSolution,
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = BlocProvider.of<AuthBloc>(context, listen: false).state;

    if (authState is! AuthSuccess) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false);
    }

    // if (authState is AuthInitial) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content:
    //             const Text("Register your email to save this issue and more."),
    //         action: SnackBarAction(
    //           label: "Register here!",
    //           onPressed: () => Navigator.push(
    //             context,
    //             MaterialPageRoute(
    //               builder: (context) => LoginPage(),
    //             ),
    //           ),
    //         ),
    //       ),
    //     );
    //   });
    // }

    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        backgroundColor: Colors.orange[50],
        title: const Text("Issue in Focus"),
        actions: const [
          HelpTextWidget(helpText: "This is where you solve the issue."),
        ],
      ),
      drawer: const MyNavigationDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ConfirmationWidget with BlocBuilder
            BlocBuilder<IssueBloc, IssueState>(
              builder: (context, state) {
                if (state is IssuesListFailure) {
                  return Center(child: Text('Error: ${state.error}'));
                } else if (state is IssueInFocusSolved) {
                  return SolveSummaryWidget(issue: state.focusedIssue);
                } else if (state is IssueInFocusSolutionIdentified) {
                  return SolutionScopingWidget(
                    issue: state.focusedIssue,
                    onSubmitted: (updatedSolution) {
                      BlocProvider.of<IssueBloc>(context, listen: false).add(
                          FocusSolveScopeSubmitted(
                              confirmedSolve: updatedSolution));
                    },
                    focusNode: _focusNode,
                  );
                } else if (state is IssueInFocusInitial) {
                  return ConfirmationWidget(
                    issue: state.focusedIssue,
                    testSubject: TestSubject.hypothesis,
                    onConfirm: () {
                      BlocProvider.of<IssueBloc>(context, listen: false).add(
                          FocusRootConfirmed(
                              confirmedRoot:
                                  state.focusedIssue.hypotheses[0].desc));
                    },
                  );
                } else if (state is IssueInFocusRootIdentified) {
                  return ConfirmationWidget(
                    issue: state.focusedIssue,
                    testSubject: TestSubject.solution,
                    onConfirm: () {
                      BlocProvider.of<IssueBloc>(context, listen: false).add(
                          FocusSolveConfirmed(
                              confirmedSolve:
                                  state.focusedIssue.solutions[0].desc));
                    },
                  );
                } else {
                  return const Center(
                      child: Text(
                          "Unexpected state: IssueBloc")); // or handle other states as needed
                }
              },
            ),
            const SizedBox(height: 20),
            // InputWidget with BlocBuilder
            BlocBuilder<IssueBloc, IssueState>(builder: (context, state) {
              if (state is IssueInFocusInitial) {
                _focusNode.requestFocus();
                return InputWidget(
                  controller: textController,
                  focusNode: _focusNode,
                  onSubmitted: () {
                    BlocProvider.of<IssueBloc>(context, listen: false).add(
                        NewHypothesisCreated(
                            newHypothesis: textController.text));
                    textController.clear();
                  },
                  labelText: 'New Root Theories',
                  hintText: 'Enter root theories here.',
                );
              } else if (state is IssueInFocusRootIdentified) {
                _focusNode.requestFocus();
                return InputWidget(
                  controller: textController,
                  focusNode: _focusNode,
                  onSubmitted: () {
                    BlocProvider.of<IssueBloc>(context, listen: false).add(
                        NewSolutionCreated(newSolution: textController.text));
                    textController.clear();
                  },
                  labelText: 'Possible Solutions',
                  hintText: 'Enter possible solutions here.',
                );
              } else {
                return Container(); // or handle other states as needed
              }
            }),
            const SizedBox(height: 20),
            // ResortableListWidget with BlocBuilder
            BlocBuilder<IssueBloc, IssueState>(
              builder: (context, state) {
                if (state is IssueInFocusInitial) {
                  return ResortableListWidget<Hypothesis>(
                    items: state.focusedIssue.hypotheses,
                    getItemDescription: (hypothesis) => hypothesis.desc,
                    onReorder: (oldIndex, newIndex) {
                      BlocProvider.of<IssueBloc>(context, listen: false).add(
                        HypothesisListResorted(
                          items: state.focusedIssue.hypotheses,
                          oldIndex: oldIndex,
                          newIndex: newIndex,
                        ),
                      );
                    },
                    onEdit: (index, hypothesis) {
                      _showHypothesisEditDialog(context, hypothesis, index);
                    },
                    onDelete: (index, hypothesis) {
                      // Add delete logic here
                    },
                  );
                } else if (state is IssueInFocusRootIdentified) {
                  return ResortableListWidget<Solution>(
                    items: state.focusedIssue.solutions,
                    getItemDescription: (solution) => solution.desc,
                    onReorder: (oldIndex, newIndex) {
                      BlocProvider.of<IssueBloc>(context, listen: false).add(
                        SolutionListResorted(
                          items: state.focusedIssue.solutions,
                          oldIndex: oldIndex,
                          newIndex: newIndex,
                        ),
                      );
                    },
                    onEdit: (index, solution) {
                      _showSolutionEditDialog(context, solution, index);
                    },
                    onDelete: (index, solution) {
                      // Add delete logic here
                    },
                  );
                } else {
                  return Container(); // or handle other states as needed
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
