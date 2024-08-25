class Hypothesis {
  final String desc;
  bool isRoot;
  bool isSpinoffIssue;
  String? spinoffIssueId;
  int rank;

  Hypothesis({
    required this.desc,
    this.isRoot = false,
    this.isSpinoffIssue = false,
    String? spinoffIssueId,
    this.rank = 0,
  });

  // Convert a Hypothesis to a Map
  Map<String, dynamic> toJson() => {
        'desc': desc,
        'isRoot': isRoot,
        'isSpinoffIssue': isSpinoffIssue,
        'spinoffIssueId': spinoffIssueId,
        'rank': rank,
      };

  // Create a Hypothesis from a Map
  factory Hypothesis.fromJson(Map<String, dynamic> json) => Hypothesis(
        desc: json['desc'],
        isRoot: json['isRoot'] ?? false,
        isSpinoffIssue: json['isSpinoffIssue'] ?? false,
        spinoffIssueId: json['spinoffIssueId'],
        rank: json['rank'] ?? 0,
      );
}
