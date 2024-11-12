import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/auth/auth_bloc.dart';
import 'package:guide_solve/bloc/issue/issue_bloc.dart';
import 'package:guide_solve/components/issue_tile.dart';
import 'package:guide_solve/components/my_navigation_drawer.dart';
import 'package:guide_solve/components/plain_button.dart';
import 'package:guide_solve/components/plain_textfield.dart';
import 'package:guide_solve/pages/home_page.dart';
import 'package:guide_solve/pages/issue_page.dart';
import 'package:guide_solve/repositories/issue_repository.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final IssueRepository issueRepository = IssueRepository();
  final TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    BlocProvider.of<IssueBloc>(context).add(const IssuesFetched());
  }

  void _deleteIssue(String issueId, String label) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to delete this issue?'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(), // Border
                borderRadius: BorderRadius.circular(4),
                color: Colors.white,
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Text color
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              // Dispatch the new issue creation event
              BlocProvider.of<IssueBloc>(context)
                  .add(IssueDeletionRequested(issueId: issueId));
              textController.clear();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .secondaryContainer, // Background color
              foregroundColor:
                  Theme.of(context).colorScheme.error, // Text color
            ),
            child: const Text('D E L E T E'),
          ),
        ],
      ),
    );
  }

  void _addIssue() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        content: PlainTextField(
          hintText: 'I feel . .  when . .',
          controller: textController,
          obscureText: false,
          onSubmit: () {
            BlocProvider.of<IssueBloc>(context)
                .add(NewIssueCreated(seedStatement: textController.text));
            textController.clear();
            Navigator.pop(context);
          },
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              // Dispatch the new issue creation event
              BlocProvider.of<IssueBloc>(context)
                  .add(NewIssueCreated(seedStatement: textController.text));
              textController.clear();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .tertiaryContainer, // Background color
              foregroundColor:
                  Theme.of(context).colorScheme.onSurface, // Text color
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      releaseFocus: true,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      drawer: const MyNavigationDrawer(),
      body: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, authState) {
              if (authState is AuthInitial) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute<Widget>(
                    builder: (context) => const HomePage(),
                  ),
                  (route) => false,
                );
              }
            },
          ),
          BlocListener<IssueBloc, IssueState>(
            listener: (context, issueState) {
              if (issueState is IssuesListFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(issueState.error)),
                );
              }
              if (issueState is IssueProcessState) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute<Widget>(
                    builder: (context) => IssuePage(
                      issueId: issueState.issue.issueId!,
                    ),
                  ),
                  (route) => false,
                );
              }
            },
          ),
        ],
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is AuthLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (authState is AuthSuccess) {
              return BlocBuilder<IssueBloc, IssueState>(
                builder: (context, issueState) {
                  if (issueState is IssuesListLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (issueState is IssuesListSuccess) {
                    final issuesList = issueState.issueList
                        .where((issue) => issue.proven != true)
                        .toList();
                    return Column(
                      children: [
                        Center(
                          child: PlainButton(
                            onPressed: _addIssue,
                            text: 'Create New Issue',
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 1000,
                            ),
                            child: ListView.builder(
                              itemCount: issuesList.length,
                              itemBuilder: (context, index) {
                                final issue = issuesList[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: AppSpacing.xs,
                                      horizontal: AppSpacing.md),
                                  child: IssueTile(
                                    issue: issue,
                                    firstButton: () {
                                      BlocProvider.of<IssueBloc>(context).add(
                                        FocusIssueSelected(
                                          issue: issue,
                                        ),
                                      );
                                    },
                                    secondButton: () {
                                      _deleteIssue(issue.issueId!, issue.label);
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const Center(
                      child: Text('Problem with IssueInitial State'),
                    );
                  }
                },
              );
            } else {
              return Center(
                  child: Text('Unexpected state: AuthBloc $authState'));
            }
          },
        ),
      ),
    );
  }
}
