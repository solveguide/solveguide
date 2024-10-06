class Issue {
  String? issueId; // Firebase ID once the issue is saved
  String? spinoffSourceIssueId; // ID of the original issue if it's a spinoff
  String label;
  final String seedStatement; // The original thought input by the user
  String root;
  String rootHypothesisId;
  String solve;
  String solveSolutionId;
  bool proven;
  final String ownerId; // ID of the user who owns the issue
  List<String>? invitedUserIds; // List of user IDs with limited permissions
  final DateTime createdTimestamp;
  final DateTime lastUpdatedTimestamp;

  Issue({
    this.issueId,
    this.spinoffSourceIssueId,
    required this.label,
    required this.seedStatement,
    this.root = "",
    this.rootHypothesisId = "",
    this.solve = "",
    this.solveSolutionId = "",
    this.proven = false,
    required this.ownerId,
    List<String>? invitedUserIds,
    required this.createdTimestamp,
    required this.lastUpdatedTimestamp,
  }) : invitedUserIds = invitedUserIds ?? [];

  // Convert an Issue to a Map
Map<String, dynamic> toJson() => {
  'issueId': issueId,
  'spinoffSourceIssueId': spinoffSourceIssueId,
  'label': label,
  'seedStatement': seedStatement,
  'root': root,
  'rootHypothesisId': rootHypothesisId,
  'solve': solve,
  'solveSolutionId': solveSolutionId,
  'proven': proven,
  'ownerId': ownerId,
  'invitedUserIds': invitedUserIds,
  'createdTimestamp': createdTimestamp.toIso8601String(),
  'lastUpdatedTimestamp': lastUpdatedTimestamp.toIso8601String(),
};

  // Create an Issue from a Map
factory Issue.fromJson(Map<String, dynamic> json) => Issue(
  issueId: json['issueId'],
  spinoffSourceIssueId: json['spinoffSourceIssueId'],
  label: json['label'],
  seedStatement: json['seedStatement'],
  root: json['root'] ?? "No root selected.",
  rootHypothesisId: json['rootHypothesisId'] ?? "",
  solve: json['solve'] ?? "No solve selected.",
  solveSolutionId: json['solveSolutionId'] ?? "",
  proven: json['proven'] ?? false,
  ownerId: json['ownerId'],
  invitedUserIds: List<String>.from(json['invitedUserIds'] ?? []),
  createdTimestamp: DateTime.parse(json['createdTimestamp']),
  lastUpdatedTimestamp: DateTime.parse(json['lastUpdatedTimestamp']),
);

// Provide a new copy of this issue with modified data.
Issue copyWith({
  String? issueId,
  String? spinoffSourceIssueId,
  String? label,
  String? seedStatement,
  String? root,
  String? rootHypothesisId,
  String? solve,
  String? solveSolutionId,
  bool? proven,
  String? ownerId,
  List<String>? invitedUserIds,
  DateTime? createdTimestamp,
  DateTime? lastUpdatedTimestamp,
}) {
  return Issue(
    issueId: issueId ?? this.issueId,
    spinoffSourceIssueId: spinoffSourceIssueId ?? this.spinoffSourceIssueId,
    label: label ?? this.label,
    seedStatement: seedStatement ?? this.seedStatement,
    root: root ?? this.root,
    rootHypothesisId: rootHypothesisId ?? this.rootHypothesisId,
    solve: solve ?? this.solve,
    solveSolutionId: solveSolutionId ?? this.solveSolutionId,
    proven: proven ?? this.proven,
    ownerId: ownerId ?? this.ownerId,
    invitedUserIds: invitedUserIds ?? this.invitedUserIds,
    createdTimestamp: createdTimestamp ?? this.createdTimestamp,
    lastUpdatedTimestamp: lastUpdatedTimestamp ?? this.lastUpdatedTimestamp,
  );
}
}
