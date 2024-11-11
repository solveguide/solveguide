import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/auth/auth_bloc.dart';
import 'package:guide_solve/bloc/issue/issue_bloc.dart';
import 'package:guide_solve/components/my_navigation_drawer.dart';
import 'package:guide_solve/models/appUser.dart';
import 'package:guide_solve/pages/views/issue_page_views/issue_page_views.dart';
import 'package:guide_solve/repositories/appUser_repository.dart';

class IssuePage extends StatelessWidget {
  const IssuePage({required this.issueId, super.key});

  final String issueId;

  void _showInviteDialog(BuildContext context, String issueId) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return InviteUserDialog(issueId: issueId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Start listening to the focused issue when the page is built
    //context.read<IssueBloc>().add(FocusIssueSelected(issue: issueId));
    return AppScaffold(
      releaseFocus: true,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Issue in Focus'),
        actions: [
          // Add the icon button here
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              _showInviteDialog(context, issueId);
            },
          ),
        ],
      ),
      drawer: const MyNavigationDrawer(),
      body: BlocBuilder<IssueBloc, IssueState>(
        buildWhen: (previous, current) {
          // Only rebuild if the stage changes, for example
          return current is! IssueProcessState ||
              (previous is IssueProcessState &&
                  previous.stage != current.stage);
        },
        builder: (context, state) {
          if (state is IssueProcessState) {
            final focusedIssue = state.issue;
            switch (state.stage) {
              case IssueProcessStage.wideningHypotheses:
                return WideningHypothesesView(issueId: issueId);
              case IssueProcessStage.establishingFacts:
                return EstablishingFactsView(issueId: issueId);
              case IssueProcessStage.narrowingToRootCause:
                return NarrowingToRootCauseView(issueId: issueId);
              case IssueProcessStage.wideningSolutions:
                return WideningSolutionsView(issueId: issueId);
              case IssueProcessStage.narrowingToSolve:
                return NarrowingToSolveView(issueId: issueId);
              case IssueProcessStage.scopingSolve:
                return ScopingSolveView(
                  issueId: issueId,
                  solutionId: focusedIssue.solveSolutionId,
                );
              case IssueProcessStage.solveSummaryReview:
                return SolveSummaryReviewView(issueId: issueId);
            }
          } else if (state is IssuesListFailure) {
            return Center(child: Text('Error: ${state.error}'));
          } else {
            return Center(child: Text('$state'));
          }
        },
      ),
    );
  }
}

class InviteUserDialog extends StatefulWidget {
  final String issueId;

  const InviteUserDialog({required this.issueId, Key? key}) : super(key: key);

  @override
  _InviteUserDialogState createState() => _InviteUserDialogState();
}

class _InviteUserDialogState extends State<InviteUserDialog> {
  bool _isLoading = true;
  String? _errorMessage;
  List<AppUser> _availableContacts = [];

  @override
  void initState() {
    super.initState();
    _fetchAvailableContacts();
  }

  Future<void> _fetchAvailableContacts() async {
    try {
      final authBloc = context.read<AuthBloc>();
      final currentUserId = authBloc.currentUserId;
      final currentAppUser =
          await context.read<AppUserRepository>().getUserById(currentUserId!);
      final contacts = currentAppUser?.getContacts ?? {};

      // Fetch the focused issue
      if (context.read<IssueBloc>().state is! IssueProcessState) {
        setState(() {
          _errorMessage = 'No focused issue available.';
          _isLoading = false;
        });
        return;
      }
      final currentState = context.read<IssueBloc>().state as IssueProcessState;
      final focusedIssue = currentState.issue;

      // Filter contacts not already invited
      final availableContactIds = contacts.keys.where((contactUserId) {
        return !focusedIssue.invitedUserIds!.contains(contactUserId);
      }).toList();

      // Fetch AppUser data for each contact
      final appUserRepository = context.read<AppUserRepository>();
      List<AppUser> contactUsers = [];
      for (var userId in availableContactIds) {
        final user = await appUserRepository.getUserById(userId);
        if (user != null) {
          contactUsers.add(user);
        }
      }

      setState(() {
        _availableContacts = contactUsers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load contacts.';
        _isLoading = false;
      });
    }
  }

  void _inviteUser(AppUser selectedUser) {
    final issueBloc = context.read<IssueBloc>();

    issueBloc.add(AddUserToIssueEvent(
      issueId: widget.issueId,
      userId: selectedUser.userId,
    ));

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text('${selectedUser.username} has been added to the issue.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AlertDialog(
        content: SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_errorMessage != null) {
      return AlertDialog(
        title: const Text('Error'),
        content: Text(_errorMessage!),
      );
    }

    if (_availableContacts.isEmpty) {
      return const AlertDialog(
        title: Text('No Contacts'),
        content: Text('You have no contacts to invite.'),
      );
    }

    return AlertDialog(
      title: const Text('Invite a Contact'),
      content: SizedBox(
        width: 300,
        child: ShadSelect<AppUser>(
          placeholder: const Text('Select a contact'),
          options: _availableContacts.map((contact) {
            return ShadOption<AppUser>(
              value: contact,
              child: Text(contact.username),
            );
          }).toList(),
          selectedOptionBuilder: (context, selectedUser) {
            return Text(selectedUser.username);
          },
          onChanged: (AppUser selectedUser) {
            _inviteUser(selectedUser);
          },
        ),
      ),
    );
  }
}
