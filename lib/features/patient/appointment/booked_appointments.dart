import 'package:CuraDocs/components/app_header.dart';
import 'package:flutter/material.dart';

class BookedAppointments extends StatefulWidget {
  const BookedAppointments({super.key});

  @override
  State<BookedAppointments> createState() => _BookedAppointmentsState();
}

class _BookedAppointmentsState extends State<BookedAppointments> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: 'My Appointments',
        onBackPressed: () {
          Navigator.pop(context);
        },
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Handle search action
            },
          ),
        ],
      ),
    );
  }
}
