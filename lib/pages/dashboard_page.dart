import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:guide_solve/services/firestore.dart';
import 'package:provider/provider.dart';
import 'package:guide_solve/data/issue_data.dart';
import 'package:guide_solve/models/issue.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Save the demo issue if there is one
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final issueData = Provider.of<IssueData>(context, listen: false);
      await issueData.saveDemoIssue();
    });
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
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<ProfileScreen>(
                  builder: (context) => ProfileScreen(
                    appBar: AppBar(
                      title: const Text('User Profile'),
                    ),
                    actions: [
                      SignedOutAction((context) {
                        Navigator.of(context).pop();
                        Navigator.pushReplacementNamed(context, '/');
                      })
                    ],
                  ),
                ),
              );
            },
          )
        ],
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addIssue,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Issue>>(
        stream: firestoreService.getIssuesStream(),
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
      ),
    );
  }
}
