import 'package:flutter/material.dart';
import 'package:guide_solve/components/issue_solving_widgets/input_widget.dart';
import 'package:guide_solve/components/plain_button.dart';
import 'package:guide_solve/models/issue.dart';
import 'package:guide_solve/models/solution.dart';

class SolutionScopingWidget extends StatefulWidget {
  final String issueId;
  final String solutionId;
  final FocusNode? focusNode;
  final void Function(Solution updatedSolution) onSubmitted;

  const SolutionScopingWidget({
    super.key,
    required this.issueId,
    required this.solutionId,
    this.focusNode,
    required this.onSubmitted,
  });

  @override
  SolutionScopingWidgetState createState() => SolutionScopingWidgetState();
}

class SolutionScopingWidgetState extends State<SolutionScopingWidget> {
  late String? selectedStakeholderId;
  late DateTime? selectedDueDate;
  late List<ActionItem> actionItems;
  final TextEditingController actionItemController = TextEditingController();
  late FocusNode _internalFocusNode;

  @override
  void initState() {
    super.initState();
    Solution solution = widget.issue.solutions[0];
    selectedStakeholderId = solution.assignedStakeholderUserId;
    selectedDueDate = solution.dueDate;
    actionItems = List.from(solution.actionItems ?? []);
    _internalFocusNode = widget.focusNode ??
        FocusNode(); // Use provided focus node or create a new one
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _internalFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _internalFocusNode.dispose(); // Dispose only if we created it
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Container(
          decoration: _containerDecoration(
              Theme.of(context).colorScheme.tertiaryContainer),
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.issue.solutions[0].desc,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 10),

              // Assigned Stakeholder Dropdown
              DropdownButton<String>(
                value: selectedStakeholderId,
                hint: const Text("Select Stakeholder"),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedStakeholderId = newValue;
                  });
                },
                items: widget.issue.invitedUserIds!
                    .map<DropdownMenuItem<String>>((String id) {
                  return DropdownMenuItem<String>(
                    value: id,
                    child: Text(id),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),

              // Due Date Picker
              Row(
                children: [
                  Text(
                    selectedDueDate == null
                        ? 'Select Due Date'
                        : 'Due Date: ${selectedDueDate!.toLocal().toString().split(' ')[0]}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDueDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          selectedDueDate = pickedDate;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Action Items List
              if (actionItems.isNotEmpty)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: actionItems.length,
                    itemBuilder: (context, index) {
                      ActionItem actionItem = actionItems[index];
                      return ListTile(
                        title: Text(actionItem.description),
                        leading: const Icon(Icons.check_box_outline_blank),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                // Edit action item
                                actionItemController.text =
                                    actionItem.description;
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Edit Action Item'),
                                    content: InputWidget(
                                      controller: actionItemController,
                                      onSubmitted: () {
                                        setState(() {
                                          actionItems[index] =
                                              actionItem.copyWith(
                                                  description:
                                                      actionItemController
                                                          .text);
                                        });
                                        Navigator.pop(context);
                                      },
                                      focusNode: _internalFocusNode,
                                      hintText: "Edit action item",
                                      labelText: "Edit",
                                    ),
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            actionItems[index] =
                                                actionItem.copyWith(
                                                    description:
                                                        actionItemController
                                                            .text);
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Save'),
                                      ),
                                    ],
                                  ),
                                );
                                WidgetsBinding.instance.addPostFrameCallback(
                                    (_) => _internalFocusNode.requestFocus());
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  actionItems.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              else
                //const Text("No action items added yet."),
                const SizedBox(height: 10),

              // Add New Action Item
              InputWidget(
                controller: actionItemController,
                onSubmitted: () {
                  setState(() {
                    actionItems.add(
                      ActionItem(description: actionItemController.text),
                    );
                    actionItemController.clear();
                    _internalFocusNode.requestFocus();
                  });
                },
                focusNode: _internalFocusNode,
                hintText: "New action item",
                labelText: "Add a Task List",
              ),

              const SizedBox(height: 20),

              // Confirm Solve Scope Button
              PlainButton(
                onPressed: () {
                  final updatedSolution = widget.issue.solutions[0].copyWith(
                    assignedStakeholderUserId: selectedStakeholderId,
                    dueDate: selectedDueDate,
                    actionItems: actionItems,
                  );
                  widget.onSubmitted(
                      updatedSolution); // Pass the updated solution
                },
                text: "Confirm Solve Scope",
                color: Theme.of(context).colorScheme.primaryContainer,
              )
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _containerDecoration(Color color) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        width: 2,
        color: Colors.black,
      ),
    );
  }
}
