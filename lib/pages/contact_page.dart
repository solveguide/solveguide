import 'package:flutter/material.dart';
import 'package:guide_solve/src/components/my_navigation_drawer.dart';
import 'package:guide_solve/models/appUser.dart';
import 'package:guide_solve/repositories/appUser_repository.dart';
import 'package:guide_solve/repositories/auth_repository.dart';
import 'package:provider/provider.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  late AppUser _currentUser;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final currentUserUid =
          await Provider.of<AuthRepository>(context, listen: false)
              .getUserUid();
      final appUserRepository =
          Provider.of<AppUserRepository>(context, listen: false);
      final currentAppUser =
          await appUserRepository.getUserById(currentUserUid!);
      if (currentAppUser != null) {
        setState(() {
          _currentUser = currentAppUser;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'User not found.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading user data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    final Map<String, String> contacts = Map.from(_currentUser.contacts)
      ..remove(_currentUser.userId);
    final invitedContacts = _currentUser.invitedContacts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Contacts'),
      ),
      drawer: const MyNavigationDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Contacts',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (contacts.isEmpty)
            const Text('You have no contacts yet.')
          else
            ...contacts.entries.map((entry) {
              //final userId = entry.key;
              final contactName = entry.value;
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(contactName),
                //subtitle: Text('User ID: $userId'), // Display user ID if needed
              );
            }).toList(),
          const Divider(),
          const Text(
            'Invited Contacts',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (invitedContacts.isEmpty)
            const Text('You have no invited contacts.')
          else
            ...invitedContacts.map((email) {
              return ListTile(
                leading: const Icon(Icons.email),
                title: Text(email),
                subtitle: const Text('Invitation pending'),
              );
            }).toList(),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // Open a dialog to invite a new contact
              showDialog<bool>(
                context: context,
                builder: (context) =>
                    InviteContactDialog(currentUserUid: _currentUser.userId),
              ).then((value) {
                if (value == true) {
                  // Refresh the UI if necessary
                  _loadCurrentUser();
                }
              });
            },
            icon: const Icon(Icons.person_add),
            label: const Text('Invite New Contact'),
          ),
        ],
      ),
    );
  }
}

// InviteContactDialog remains the same as before
class InviteContactDialog extends StatefulWidget {
  const InviteContactDialog({required this.currentUserUid, super.key});
  final String currentUserUid;

  @override
  _InviteContactDialogState createState() => _InviteContactDialogState();
}

class _InviteContactDialogState extends State<InviteContactDialog> {
  final TextEditingController _emailController = TextEditingController();
  bool _isInviting = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Invite Contact'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_errorMessage != null)
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'Enter email address',
            ),
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isInviting
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isInviting
              ? null
              : () async {
                  setState(() {
                    _isInviting = true;
                    _errorMessage = null;
                  });
                  try {
                    final email = _emailController.text.trim().toLowerCase();
                    if (email.isEmpty) {
                      throw Exception('Please enter an email address.');
                    }
                    final appUserRepository =
                        Provider.of<AppUserRepository>(context, listen: false);
                    await appUserRepository.inviteContact(
                        email, widget.currentUserUid);
                    Navigator.of(context).pop(true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$email added to contacts.')),
                    );
                  } catch (e) {
                    setState(() {
                      _errorMessage =
                          e.toString().replaceFirst('Exception: ', '');
                    });
                  } finally {
                    setState(() {
                      _isInviting = false;
                    });
                  }
                },
          child: _isInviting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Invite'),
        ),
      ],
    );
  }
}
