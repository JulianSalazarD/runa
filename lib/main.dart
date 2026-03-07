import 'package:flutter/material.dart';

void main() {
  runApp(const RunaApp());
}

class RunaApp extends StatelessWidget {
  const RunaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Runa',
      home: Scaffold(
        body: Center(
          child: Text('Runa v0.1'),
        ),
      ),
    );
  }
}
