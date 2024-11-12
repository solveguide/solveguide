import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  AppUser({
    required this.userId,
    required this.email,
    required this.username,
    required this.createdTimestamp,
    required this.lastLoginTimestamp,
    Map<String, String>? contacts,
    List<String>? invitedContacts,
    List<IssueArea>? issueAreas,
  })  : contacts = contacts ?? {},
        invitedContacts = invitedContacts ?? [],
        issueAreas = issueAreas ?? [];

  final String userId;
  final String email;
  final String username;
  final DateTime createdTimestamp;
  final DateTime lastLoginTimestamp;
  Map<String, String>
      contacts; // <userId, contactName> Map of users that are contacts
  List<String>
      invitedContacts; // List of emails for users invited but not registered
  List<IssueArea> issueAreas; // List of issue areas this user belongs to

  // Simple Getters for the mandatory fields
  String get getUserId => userId;
  String get getEmail => email;
  String get getUsername => username;
  DateTime get getCreatedTimestamp => createdTimestamp;
  DateTime get getLastLoginTimestamp => lastLoginTimestamp;
  Map<String, String> get getContacts => contacts;
  List<String> get getInvitedContacts => invitedContacts;
  List<IssueArea> get getIssueAreas => issueAreas;

  // Getters for convenient access

  // Get the total number of contacts
  int get totalContacts => contacts.length - 1;

  // Get the total number of invited contacts
  int get totalInvitedContacts => invitedContacts.length;

  // Get the total number of issue areas
  int get totalIssueAreas => issueAreas.length;

  // Check if a user is in the contact list by their userId
  bool isContact(String contactUserId) => contacts.containsKey(contactUserId);

  // Check if an email is in the invited contacts list
  bool isInvited(String email) => invitedContacts.contains(email);

  // Get the list of issue area labels
  List<String> get issueAreaLabels =>
      issueAreas.map((area) => area.label).toList();

  // Get the list of contactNames
  List<String> get contactNames => contacts.values.toList();

  //given userId return the contact name
  String? getContactName(String userId) =>
      contacts[userId]; // Return null if not found

  // Check if a user belongs to an issue area
  bool isUserInIssueArea(String issueAreaId, String userId) {
    final issueArea = issueAreas.firstWhere(
      (area) => area.issueAreaId == issueAreaId,
      orElse: () =>
          IssueArea(issueAreaId: issueAreaId, label: 'Unknown', userIds: []),
    );
    return issueArea.userIds.contains(userId);
  }

  // Add a new contact by userId
  void addContact(String contactUserId, {String? contactName}) {
    if (!contacts.containsKey(contactUserId)) {
      contacts[contactUserId] = contactName ?? '';
    }
  }

  // Invite a new contact by email
  void inviteContact(String email) {
    if (!invitedContacts.contains(email)) {
      invitedContacts.add(email);
    }
  }

  // Add a user to an issue area by userId
  void addUserToIssueArea(String issueAreaId, String userId) {
    final issueArea = issueAreas.firstWhere(
      (area) => area.issueAreaId == issueAreaId,
      orElse: () =>
          IssueArea(issueAreaId: issueAreaId, label: 'Unknown', userIds: []),
    );
    if (!issueArea.userIds.contains(userId)) {
      issueArea.userIds.add(userId);
    }
  }

  // Convert a User to a Map for Firebase
  Map<String, dynamic> toJson() => {
        'userId': userId,
        'email': email,
        'username': username,
        'createdTimestamp': createdTimestamp.toIso8601String(),
        'lastLoginTimestamp': lastLoginTimestamp.toIso8601String(),
        'contacts': contacts,
        'invitedContacts': invitedContacts,
        'issueAreas': issueAreas.map((e) => e.toJson()).toList(),
      };

  // Create a User from a Map
  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        userId: json['userId'] as String,
        email: json['email'] as String,
        username: json['username'] as String,
        createdTimestamp: (json['createdTimestamp'] as Timestamp).toDate(),
        lastLoginTimestamp: (json['lastLoginTimestamp'] as Timestamp).toDate(),
        contacts: Map<String, String>.from(json['contacts'] as Map),
        invitedContacts:
            (json['invitedContacts'] as List<dynamic>).cast<String>(),
        issueAreas: (json['issueAreas'] as List<dynamic>)
            .map((e) => IssueArea.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

//toString method to provide a readable string representation of the User
  @override
  String toString() {
    return 'AppUser($username)';
  }

  //copyWith method to create a new instance with updated values
  AppUser copyWith({
    String? userId,
    String? email,
    String? username,
    DateTime? createdTimestamp,
    DateTime? lastLoginTimestamp,
    Map<String, String>? contacts,
    List<String>? invitedContacts,
    List<IssueArea>? issueAreas,
  }) {
    return AppUser(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      username: username ?? this.username,
      createdTimestamp: createdTimestamp ?? this.createdTimestamp,
      lastLoginTimestamp: lastLoginTimestamp ?? this.lastLoginTimestamp,
      contacts: contacts ?? Map<String, String>.from(this.contacts),
      invitedContacts:
          invitedContacts ?? List<String>.from(this.invitedContacts),
      issueAreas:
          issueAreas ?? this.issueAreas.map((e) => e.copyWith()).toList(),
    );
  }
}

class IssueArea {
  IssueArea({
    required this.issueAreaId,
    required this.label,
    List<String>? userIds,
  }) : userIds = userIds ?? [];

  final String issueAreaId;
  final String label;
  List<String> userIds;

  // Simple Getters for the mandatory fields
  String get getIssueAreaId => issueAreaId;
  String get getLabel => label;
  List<String> get getUserIds => userIds;

  // Convert an IssueArea to a Map for Firebase
  Map<String, dynamic> toJson() => {
        'issueAreaId': issueAreaId,
        'label': label,
        'userIds': userIds,
      };

  // Create an IssueArea from a Map
  factory IssueArea.fromJson(Map<String, dynamic> json) => IssueArea(
        issueAreaId: json['issueAreaId'] as String,
        label: json['label'] as String,
        userIds: (json['userIds'] as List<dynamic>).cast<String>(),
      );

  // copyWith method to create a new instance with updated values
  IssueArea copyWith({List<String>? userIds}) {
    // Add this method
    return IssueArea(
      issueAreaId: issueAreaId,
      label: label,
      userIds: userIds ?? this.userIds,
    );
  }
}
