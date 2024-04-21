import 'package:flutter/material.dart';
import 'package:guide_solve/data/issue_data.dart';
import 'package:guide_solve/models/hypothesis.dart';
import 'package:guide_solve/models/solution.dart';
import 'package:guide_solve/pages/signup_page.dart';
import 'package:provider/provider.dart';

class SolvePage extends StatefulWidget {
  final String demoIssue;
  final String root;
  final String solve;
  const SolvePage(
      {super.key,
      required this.demoIssue,
      required this.root,
      required this.solve});

  @override
  State<SolvePage> createState() => _SolvePageState();
}

class _SolvePageState extends State<SolvePage> {
// start the demo
  void goToSignupPage() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SignupPage(),
        )
      );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<IssueData>(
      builder: (context, issueData, child) => Scaffold(
        backgroundColor: Colors.orange[50],
        appBar: AppBar(
          backgroundColor: Colors.orange[50],
          title: const Text('Take Action!'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: ListView(
            children: [
              buildSummaryContainer(context),
              const SizedBox(height: 20),
              //buildDualListContainer(issueData),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text("Root Theories Considered:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        ]
                      
                    )
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text("Solutions Considered:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: issueData.numberOfSolutionsInIssue(widget.demoIssue),
                            itemBuilder: (context, index) => ListTile(
                              title: Text(issueData.getSolutionList(widget.demoIssue)[index].desc),
                            ),
                          ),
                        )
                        ]
                    )
                  )
                ],
                ),
              const SizedBox(height: 20),
              Text("Do you like what you see? Create an Account to save this solve and more.", textAlign: TextAlign.center),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MaterialButton(
                  onPressed: goToSignupPage,
                  color: Colors.red,
                  child: const Text("Create an Account"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSummaryContainer(BuildContext context) {
    return Center(
      child: Container(
        width: 500,
        decoration: BoxDecoration(
          color: Colors.lightBlue[200] ?? Colors.orange,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(width: 5, color: Colors.black),
        ),
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Your Solve:',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  TextSpan(
                      text: 'You will: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text: '${widget.solve}.',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  TextSpan(
                      text: '\n\nTo address this root: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text: '${widget.root}.',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  TextSpan(
                      text: '\n\nTo solve this issue: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text: widget.demoIssue,
                      style: TextStyle(fontWeight: FontWeight.normal)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

// Widget buildDualListContainer(IssueData issueData) {
//   return Row(
//     children: [
//       Expanded(
//         child: buildHypothesisList<Hypothesis>("Root Theories", issueData.getHypothesisList(widget.demoIssue)),
//       ),
//       Expanded(
//         child: buildSolutionList<Solution>("Solutions", issueData.getSolutionList(widget.demoIssue)), 
//       ),
//     ],
//   );
// }

// Widget buildHypothesisList<Hypothesis>(String title, List<Hypothesis> items) {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0),
//         child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//       ),
//       Expanded(
//         child: ListView.builder(
//           itemCount: items.length,
//           itemBuilder: (BuildContext context, int index) {
//             var item = items[index];
//             return ListTile(
//               title: Text(items[index].desc),  // Cast to dynamic to access 'desc'. Alternatively, define a common interface.
//             );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget buildSolutionList<Solution>(String title, List<Solution> items) {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0),
//         child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//       ),
//       Expanded(
//         child: ListView.builder(
//           itemCount: items.length,
//           itemBuilder: (BuildContext context, int index) {
//             var item = items[index];
//             return ListTile(
//               title: Text((item as dynamic).desc),  // Cast to dynamic to access 'desc'. Alternatively, define a common interface.
//             );
//             },
//           ),
//         ),
//       ],
//     );
//   }
}
