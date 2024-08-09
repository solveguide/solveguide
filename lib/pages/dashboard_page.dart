import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/auth/auth_bloc.dart';
import 'package:guide_solve/bloc/issue/issue_bloc.dart';
import 'package:guide_solve/components/issue_tile.dart';
import 'package:guide_solve/components/plain_button.dart';
import 'package:guide_solve/pages/home_page.dart';
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
    context.read<IssueBloc>().add(IssuesFetched());
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
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              // Ensure the Issue is created properly with necessary fields
              final newIssue = Issue(
                label: textController.text,
                seedStatement: textController.text,
                ownerId: authState.uid,  // Use ownerId from AuthState
                createdTimestamp: DateTime.now(),
                lastUpdatedTimestamp: DateTime.now(),
                issueId: 'dashboard_${DateTime.now().millisecondsSinceEpoch}',
              );
              // Dispatch the new issue creation event
              context.read<IssueBloc>().add(NewIssueCreated(newIssue: newIssue));
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
      const SnackBar(content: Text('You need to be logged in to add an issue')),
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
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthInitial) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
                (route) => false);
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return Column(
            children: [
              Center(child: PlainButton(onPressed: _addIssue, text: 'Create New Issue')),
              const SizedBox(height: 20),
              BlocBuilder<IssueBloc, IssueState>(
                builder: (context, issueState) {
                  if (issueState is IssuesListLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (issueState is IssuesListFailure) {
                    return Center(child: Text('Error: ${issueState.error}'));
                  } else if (issueState is IssuesListSuccess) {
                    List<Issue> issuesList = issueState.issueList;
                    return Expanded(
                      child: ListView.builder(
                        itemCount: issuesList.length,
                        itemBuilder: (context, index) {
                          Issue issue = issuesList[index];
                          return IssueTile(issue: issue);
                        },
                      ),
                    );
                  } else {
                    return const Center(child: Text("Unexpected state"));
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
