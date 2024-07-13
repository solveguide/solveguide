import 'package:guide_solve/models/hypothesis.dart';
import 'package:guide_solve/models/solution.dart';

class Issue {
  final String label;
  String root = "I can't accept that it must be this way.";
  String solve = "I accept that it must be this way.";
  final List<Hypothesis> hypotheses;
  final List<Solution> solutions = [];

  Issue({required this.label, required this.hypotheses});
}
