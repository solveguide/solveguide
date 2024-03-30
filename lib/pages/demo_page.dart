import 'package:flutter/material.dart';

class DemoPage extends StatefulWidget {
  final String demoIssue;
  const DemoPage({super.key, required this.demoIssue});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find the Root'),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) => ListTile(
          title: Text(widget.demoIssue),
        ),
      ),
    );
  }
}
