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
}