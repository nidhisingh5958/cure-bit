import 'package:flutter/material.dart';

class CompletedAppointments extends StatelessWidget {
  const CompletedAppointments({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(child: Text('No completed appointments found.')),
    );
  }
}
