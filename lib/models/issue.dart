import 'package:guide_solve/models/hypothesis.dart';

class Issue {
  final String label;
  final String root = "I can't accept that it must be this way.";
  final List<Hypothesis> hypotheses;

  Issue({required this.label, required this.hypotheses});
}