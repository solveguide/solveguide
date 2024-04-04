import 'package:flutter/material.dart';

Widget buildBlueContainer(String header, String text) {
  return Center(
    child: Container(
      width: 500,
      decoration: _containerDecoration(Colors.lightBlue[200] ?? Colors.orange),
      padding: const EdgeInsets.all(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildHeaderText(header),
          const SizedBox(height: 10),
          _buildNormalText(text),
        ],
      ),
    ),
  );
}

Widget _buildHeaderText(String text) => Text(
      text,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );

Widget _buildNormalText(String text) => Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
    );

BoxDecoration _containerDecoration(Color color) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(width: 5, color: Colors.black),
  );
}
