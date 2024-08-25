import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/issue/issue_bloc.dart';
import 'package:guide_solve/components/issue_solving_widgets/confirmation_widget.dart';
import 'package:guide_solve/components/issue_solving_widgets/help_text_widget.dart';
import 'package:guide_solve/components/issue_solving_widgets/input_widget.dart';
import 'package:guide_solve/components/issue_solving_widgets/resortable_list_widget.dart';
import 'package:guide_solve/models/hypothesis.dart';
import 'package:guide_solve/models/issue.dart';

class IssuePage extends StatefulWidget {
  final Issue issue;

  const IssuePage({super.key, required this.issue});

  @override
  State<IssuePage> createState() => _IssuePageState();
}

class _IssuePageState extends State<IssuePage> {
  final TextEditingController textController = TextEditingController();

  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        backgroundColor: Colors.orange[50],
        title: Text(widget.issue.label),
        actions: const [
          HelpTextWidget(helpText: "This is where you solve the issue."),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ConfirmationWidget(
              issue: widget.issue,
              testSubject: TestSubject.hypothesis,
            ),
            const SizedBox(height: 20),
            InputWidget(
              controller: textController,
              focusNode: _focusNode,
              onSubmitted: () {
                context.read<IssueBloc>().add(
                    NewHypothesisCreated(newHypothesis: textController.text));
                textController.clear();
                // Handle updating the issue state
              },
              labelText: 'New Root Theories',
              hintText: 'Enter root theories here.',
            ),
            const SizedBox(height: 20),
            ResortableListWidget<Hypothesis>(
                items: widget.issue.hypotheses,
                getItemDescription: (hypothesis) => hypothesis.desc,
                //onEdit: _editHypothesis,
                //onDelete: _deleteHypothesis,
              ),
          ],
        ),
      ),
    );
  }
}
