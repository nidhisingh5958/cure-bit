import 'package:flutter/material.dart';

class ActiveAppointments extends StatelessWidget {
  const ActiveAppointments({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text('No active appointments found.'),
      ),
    );
  }
}
