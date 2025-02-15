import 'package:flutter/material.dart';

class AddDocument extends StatelessWidget {
  const AddDocument({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Document'),
      ),
      body: Text('Add Document'),
    );
  }
}
