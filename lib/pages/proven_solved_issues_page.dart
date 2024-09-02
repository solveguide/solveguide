import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/auth/auth_bloc.dart';
import 'package:guide_solve/bloc/issue/issue_bloc.dart';
import 'package:guide_solve/components/issue_tile.dart';
import 'package:guide_solve/components/my_navigation_drawer.dart';
import 'package:guide_solve/pages/home_page.dart';
import 'package:guide_solve/repositories/issue_repository.dart';
import 'package:guide_solve/models/issue.dart';

class ProvenSolvesPage extends StatefulWidget {
  const ProvenSolvesPage({super.key});

  @override
  State<ProvenSolvesPage> createState() => _ProvenSolvesPageState();
}

class _ProvenSolvesPageState extends State<ProvenSolvesPage> {
  final IssueRepository issueRepository = IssueRepository();
  final TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchIssuesIfAuthenticated();
  }

  void _fetchIssuesIfAuthenticated() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      BlocProvider.of<IssueBloc>(context, listen: false)
          .add(IssuesFetched(userId: authState.uid));
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        title: const Text("Proven Solved Issues"),
        actions: [
          IconButton(
            onPressed: () {
              BlocProvider.of<AuthBloc>(context, listen: false)
                  .add(const AuthLogoutRequested());
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
              if (issueState is IssuesListFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(issueState.error)),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<IssueBloc, IssueState>(
                builder: (context, issueState) {
                  if (issueState is IssuesListLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (issueState is IssuesListSuccess) {
                    List<Issue> issuesList = issueState.issueList.where((issue) => issue.proven = true).toList();
                    return Column(
                      children: [
                        Expanded(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 1000.0,
                            ),
                            child: ListView.builder(
                              itemCount: issuesList.length,
                              itemBuilder: (context, index) {
                                Issue issue = issuesList[index];
                                return IssueTile(
                                  issue: issue,
                                  firstButton: () {},
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const Center(
                        child: Text("Problem with IssueInitial State"));
                  }
                },
              ),
      ),
    );
  }
}
