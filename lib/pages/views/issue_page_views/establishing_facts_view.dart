import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/issue/issue_bloc.dart';
import 'package:guide_solve/models/fact.dart'; // Assuming you have a Fact model
import 'package:guide_solve/repositories/auth_repository.dart';
import 'package:guide_solve/repositories/issue_repository.dart';

class EstablishingFactsView extends StatelessWidget {
  EstablishingFactsView({
    required this.issueId,
    super.key,
  });

  final String issueId;
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Start listening to facts stream
    final issueRepository = context.read<IssueRepository>();
    final authRepository = context.read<AuthRepository>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Input field for adding new facts
          TextField(
            controller: _textController,
            decoration: const InputDecoration(
              labelText: 'New Fact',
              hintText: 'Enter a fact that supports or refutes a hypothesis.',
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                final factContext = '${authRepository.getUserUid()} believes:';
                context.read<IssueBloc>().add(
                      NewFactCreated(
                        newFact: _textController.toString(),
                        newFactContext: factContext,
                        referenceObjectId: issueId,
                        referenceObjectType: ReferenceObjectType.issue,
                      ),
                    );
                _textController.clear();
              }
            },
          ),
          const SizedBox(height: 20),
          // List of facts
          Expanded(
            child: StreamBuilder<List<Fact>>(
              stream: issueRepository.getFacts(issueId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading facts'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final facts = snapshot.data!;
                if (facts.isEmpty) {
                  return const Center(child: Text('No facts added yet.'));
                }
                return ListView.builder(
                  itemCount: facts.length,
                  itemBuilder: (context, index) {
                    final fact = facts[index];
                    const dropdownValue = 'Agree';
                    return ListTile(
                      title: Text(fact.desc),
                      trailing: DropdownButton(
                        items: const [
                          DropdownMenuItem(
                            value: 'Agree',
                            child: Text('Agree'),
                          ),
                          DropdownMenuItem(
                            value: 'Disagree',
                            child: Text('Disagree'),
                          ),
                        ],
                        value: dropdownValue,
                        onChanged: null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
