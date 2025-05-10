import 'package:CuraDocs/components/app_header.dart';
import 'package:CuraDocs/components/colors.dart';
import 'package:CuraDocs/features/patient/appointment/my_appointments/active_appointments.dart';
import 'package:CuraDocs/features/patient/appointment/my_appointments/completed_appointments.dart';
import 'package:CuraDocs/features/patient/appointment/my_appointments/upcoming_appointments.dart';
import 'package:flutter/material.dart';

class MyAppointments extends StatefulWidget {
  const MyAppointments({super.key});

  @override
  State<MyAppointments> createState() => _MyAppointmentsState();
}

class _MyAppointmentsState extends State<MyAppointments>
    with TickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
          ],
          indicator: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: grey400, width: 2),
            ),
          ),
          splashBorderRadius: BorderRadius.circular(38),
          unselectedLabelColor: grey600,
          indicatorColor: grey800,
          dividerColor: transparent,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ActiveAppointments(),
          UpcomingAppointments(),
          CompletedAppointments(),
        ],
      ),
    );
  }
}
