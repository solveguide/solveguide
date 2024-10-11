import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:guide_solve/bloc/issue/issue_bloc.dart';
// import 'package:guide_solve/repositories/issue_repository.dart';

class ScopingSolveView extends StatelessWidget {
  //final TextEditingController _scopeController = TextEditingController();

  const ScopingSolveView({
    required this.issueId,
    required this.solutionId,
    super.key,
  });

  final String issueId;
  final String solutionId;

  @override
  Widget build(BuildContext context) {
    //final issueBloc = context.read<IssueBloc>(); // Get the Bloc instance
    //final issueRepository = context.read<IssueRepository>();

    // Access the current focused issue directly from the bloc
    //final focusedIssue = issueBloc.focusedIssue;

    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          //Solution.desc
          Text('Solution Description'),
          SizedBox(height: 10),
          //Assigned Stakeholder selection
          Text('Assigned Stakeholder'),
          SizedBox(height: 10),
          //Due Date for Solution -- date picker
          Text('Due Date Picker'),
          SizedBox(height: 10),
          //Action Item List
          Text('Action Item List'),
        ],
      ),
    );
  }
}
