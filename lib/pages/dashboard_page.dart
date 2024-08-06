import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/auth_bloc.dart';
import 'package:guide_solve/pages/home_page.dart';
import 'package:guide_solve/repositories/firestore_repository.dart';
import 'package:guide_solve/models/issue.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController textController = TextEditingController();
  late Stream<List<Issue>> issuesStream;

  @override
  void initState() {
    super.initState();
    // Initialize the stream only once in initState
    issuesStream = firestoreService.getIssuesStream();
  }

  void _addIssue() {
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
                ownerId: FirebaseAuth.instance.currentUser!.uid,
                createdTimestamp: DateTime.now(),
                lastUpdatedTimestamp: DateTime.now(),
                issueId: 'dashboard_${DateTime.now().millisecondsSinceEpoch}',
              );
              firestoreService.addIssue(newIssue);
              textController.clear();
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
              onPressed: () {
                context.read<AuthBloc>().add(AuthLogoutRequested());
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addIssue,
        child: const Icon(Icons.add),
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
          return StreamBuilder<List<Issue>>(
            stream: issuesStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.connectionState == ConnectionState.active ||
                  snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  if (snapshot.data!.isNotEmpty) {
                    List<Issue> issuesList = snapshot.data!;
                    return ListView.builder(
                      itemCount: issuesList.length,
                      itemBuilder: (context, index) {
                        Issue issue = issuesList[index];
                        return ListTile(
                          title: Text(issue.label),
                          subtitle: Text(issue.createdTimestamp.toString()),
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: Text("Congratulations, you have no issues"),
                    );
                  }
                } else {
                  return const Center(child: Text("No data available"));
                }
              } else {
                return const Center(child: Text("Unexpected state"));
              }
            },
          );
        },
      ),
    );
  }
}
