class Hypothesis {
  final String desc;
  bool isRoot;
  bool isSpinoffIssue;
  int rank;

  Hypothesis({
    required this.desc,
    this.isRoot = false,
    this.isSpinoffIssue = false,
    this.rank = 0,
  });

  // Convert a Hypothesis to a Map
  Map<String, dynamic> toJson() => {
        'desc': desc,
        'isRoot': isRoot,
        'isSpinoffIssue': isSpinoffIssue,
        'rank': rank,
      };

  // Create a Hypothesis from a Map
  factory Hypothesis.fromJson(Map<String, dynamic> json) => Hypothesis(
        desc: json['desc'],
        isRoot: json['isRoot'] ?? false,
        isSpinoffIssue: json['isSpinoffIssue'] ?? false,
        rank: json['rank'] ?? 0,
      );
}
