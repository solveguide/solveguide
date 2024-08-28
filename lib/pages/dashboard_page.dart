import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/auth/auth_bloc.dart';
import 'package:guide_solve/bloc/issue/issue_bloc.dart';
import 'package:guide_solve/components/issue_tile.dart';
import 'package:guide_solve/components/my_navigation_drawer.dart';
import 'package:guide_solve/components/plain_button.dart';
import 'package:guide_solve/pages/home_page.dart';
import 'package:guide_solve/pages/issue_page.dart';
import 'package:guide_solve/repositories/issue_repository.dart';
import 'package:guide_solve/models/issue.dart';

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
    // Initialize the stream only once in initState
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      context.read<IssueBloc>().add(IssuesFetched(userId: authState.uid));
    } else {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false);
    }
  }

  void _addIssue() {
    // Get the AuthBloc state before showing the dialog
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthSuccess) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              hintText: 'Enter issue description',
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Dispatch the new issue creation event
                context.read<IssueBloc>().add(NewIssueCreated(
                    seedStatement: textController.text,
                    ownerId: authState.uid));
                textController.clear();
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      );
    } else {
      // Handle the case where the user is not authenticated
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You need to be logged in to add an issue')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            onPressed: () {
              BlocProvider.of<AuthBloc>(context, listen: false)
                  .add(AuthLogoutRequested());
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      drawer: const MyNavigationDrawer(),
      body: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, authState) {
              if (authState is AuthInitial) {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                    (route) => false);
              }
            },
          ),
          BlocListener<IssueBloc, IssueState>(
            listener: (context, issueState) {
              if (issueState is IssueInFocus) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          IssuePage(issue: issueState.focusedIssue)),
                  (route) => false,
                );
              } else if (issueState is IssuesListFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(issueState.error)),
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
                  } else if (issueState is IssuesListFailure) {
                    return Center(child: Text('Error: ${issueState.error}'));
                  } else if (issueState is IssuesListSuccess) {
                    List<Issue> issuesList = issueState.issueList;
                    return Column(
                      children: [
                        Center(
                            child: PlainButton(
                                onPressed: _addIssue,
                                text: 'Create New Issue')),
                        const SizedBox(height: 20),
                        Expanded(
                          child: ListView.builder(
                            itemCount: issuesList.length,
                            itemBuilder: (context, index) {
                              Issue issue = issuesList[index];
                              return IssueTile(
                                issue: issue,
                                firstButton: () {
                                  context.read<IssueBloc>().add(
                                      FocusIssueSelected(
                                          issueID: issue.issueId!));
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const Center(
                        child: Text("Unexpected state: IssueBloc"));
                  }
                },
              );
            } else {
              return const Center(child: Text("Unexpected state: AuthBloc"));
            }
          },
        ),
      ),
    );
  }
}
