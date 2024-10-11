// ignore_for_file: always_put_required_named_parameters_first

class Hypothesis {
  // A map to store user votes (userId -> voteValue)

  Hypothesis({
    this.hypothesisId,
    required this.ownerId,
    required this.desc,
    this.isRoot = false,
    this.isSpinoffIssue = false,
    this.spinoffIssueId,
    this.rank = 0,
    required this.createdTimestamp,
    required this.lastUpdatedTimestamp,
    this.votes = const {}, // Initialize with an empty map
  });

  // Create a Hypothesis from a Map
  factory Hypothesis.fromJson(Map<String, dynamic> json) => Hypothesis(
        hypothesisId: json['hypothesisId'] as String?,
        ownerId: json['ownerId'] as String,
        desc: json['desc'] as String,
        isRoot: json['isRoot'] as bool? ?? false,
        isSpinoffIssue: json['isSpinoffIssue'] as bool? ?? false,
        spinoffIssueId: json['spinoffIssueId'] as String?,
        rank: json['rank'] as int? ?? 0,
        createdTimestamp: DateTime.parse(json['createdTimestamp'] as String),
        lastUpdatedTimestamp:
            DateTime.parse(json['lastUpdatedTimestamp'] as String),
        votes: Map<String, String>.from(
          json['votes'] as Map<String, dynamic>? ?? {},
        ),
      );

  String? hypothesisId;
  final String ownerId; // ID of the user who owns the hypothesis
  final String desc;
  bool isRoot;
  bool isSpinoffIssue;
  String? spinoffIssueId;
  int rank;
  final DateTime createdTimestamp;
  final DateTime lastUpdatedTimestamp;
  Map<String, String> votes;

  // Convert a Hypothesis to a Map
  Map<String, dynamic> toJson() => {
        'hypothesisId': hypothesisId,
        'ownerId': ownerId,
        'desc': desc,
        'isRoot': isRoot,
        'isSpinoffIssue': isSpinoffIssue,
        'spinoffIssueId': spinoffIssueId,
        'rank': rank,
        'createdTimestamp': createdTimestamp.toIso8601String(),
        'lastUpdatedTimestamp': lastUpdatedTimestamp.toIso8601String(),
        'votes': votes, // Store the votes map
      };

  // Add the copyWith method
  Hypothesis copyWith({
    String? hypothesisId,
    String? ownerId,
    String? desc,
    bool? isRoot,
    bool? isSpinoffIssue,
    String? spinoffIssueId,
    int? rank,
    DateTime? createdTimestamp,
    DateTime? lastUpdatedTimestamp,
    Map<String, String>? votes,
  }) {
    return Hypothesis(
      hypothesisId: hypothesisId ?? this.hypothesisId,
      ownerId: ownerId ?? this.ownerId,
      desc: desc ?? this.desc,
      isRoot: isRoot ?? this.isRoot,
      isSpinoffIssue: isSpinoffIssue ?? this.isSpinoffIssue,
      spinoffIssueId: spinoffIssueId ?? this.spinoffIssueId,
      rank: rank ?? this.rank,
      createdTimestamp: createdTimestamp ?? this.createdTimestamp,
      lastUpdatedTimestamp: lastUpdatedTimestamp ?? this.lastUpdatedTimestamp,
      votes: votes ?? this.votes,
    );
  }
}
