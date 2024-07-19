import 'package:guide_solve/models/hypothesis.dart';
import 'package:guide_solve/models/solution.dart';

class Issue {
  String? issueId; // Firebase ID once the issue is saved
  String? spinoffSourceIssueId; // ID of the original issue if it's a spinoff
  final String label;
  final String seedStatement; // The original thought input by the user
  String root;
  String solve;
  List<Hypothesis> hypotheses;
  List<Solution> solutions;
  String? ownerId; // ID of the user who owns the issue
  List<String>? invitedUserIds; // List of user IDs with limited permissions
  final DateTime createdTimestamp;
  final DateTime lastUpdatedTimestamp;

  Issue({
    this.issueId,
    this.spinoffSourceIssueId,
    required this.label,
    required this.seedStatement,
    this.root = "I cannot accept this.",
    this.solve = "Accept this.",
    List<Hypothesis>? hypotheses,
    List<Solution>? solutions,
    this.ownerId,
    List <String>? invitedUserIds,
    required this.createdTimestamp,
    required this.lastUpdatedTimestamp,
  })  : hypotheses = hypotheses ?? [],
        solutions = solutions ?? [],
        invitedUserIds = invitedUserIds ?? [];

  // Convert an Issue to a Map
  Map<String, dynamic> toJson() => {
        'issueId': issueId,
        'spinoffSourceIssueId': spinoffSourceIssueId,
        'label': label,
        'seedStatement': seedStatement,
        'root': root,
        'solve': solve,
        'hypotheses': hypotheses.map((h) => h.toJson()).toList(),
        'solutions': solutions.map((s) => s.toJson()).toList(),
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
        root: json['root'] ?? "I cannot accept this.",
        solve: json['solve'] ?? "Accept this.",
        hypotheses: (json['hypotheses'] as List)
            .map((h) => Hypothesis.fromJson(h))
            .toList(),
        solutions: (json['solutions'] as List)
            .map((s) => Solution.fromJson(s))
            .toList(),
        ownerId: json['ownerId'],
        invitedUserIds: List<String>.from(json['invitedUserIds'] ?? []),
        createdTimestamp: DateTime.parse(json['createdTimestamp']),
        lastUpdatedTimestamp: DateTime.parse(json['lastUpdatedTimestamp']),
      );
}
