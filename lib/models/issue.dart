class Issue {
  Issue({
    required this.label,
    required this.seedStatement,
    required this.ownerId,
    required this.createdTimestamp,
    required this.lastUpdatedTimestamp,
    this.issueId,
    this.spinoffSourceIssueId,
    this.root = '',
    this.rootHypothesisId = '',
    this.solve = '',
    this.solveSolutionId = '',
    this.proven = false,
    List<String>? invitedUserIds,
  }) : invitedUserIds = invitedUserIds ?? [];

  // Create an Issue from a Map
  factory Issue.fromJson(Map<String, dynamic> json) => Issue(
        issueId: json['issueId'] as String?,
        spinoffSourceIssueId: json['spinoffSourceIssueId'] as String?,
        label: json['label'] as String,
        seedStatement: json['seedStatement'] as String,
        root: json['root'] as String? ?? 'No root selected.',
        rootHypothesisId: json['rootHypothesisId'] as String? ?? '',
        solve: json['solve'] as String? ?? 'No solve selected.',
        solveSolutionId: json['solveSolutionId'] as String? ?? '',
        proven: json['proven'] as bool? ?? false,
        ownerId: json['ownerId'] as String,
        invitedUserIds: (json['invitedUserIds'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        createdTimestamp: DateTime.parse(json['createdTimestamp'] as String),
        lastUpdatedTimestamp:
            DateTime.parse(json['lastUpdatedTimestamp'] as String),
      );

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
