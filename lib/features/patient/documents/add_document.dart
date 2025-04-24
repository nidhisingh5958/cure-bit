import 'package:CuraDocs/components/app_header.dart';
import 'package:flutter/material.dart';

class AddDocument extends StatelessWidget {
  const AddDocument({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: 'Add Document',
      ),
      body: Text('Add Document'),
    );
  }
}
