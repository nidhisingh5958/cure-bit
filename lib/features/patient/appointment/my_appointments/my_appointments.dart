import 'package:CuraDocs/common/components/app_header.dart';
import 'package:CuraDocs/common/components/colors.dart';
import 'package:CuraDocs/app/features_api_repository/appointment/patient/my_appointments/active_provider.dart';
import 'package:CuraDocs/features/patient/appointment/components/animated_fab.dart';
import 'package:CuraDocs/features/patient/appointment/my_appointments/active_appointments.dart';
import 'package:CuraDocs/features/patient/appointment/my_appointments/completed_appointments.dart';
import 'package:CuraDocs/features/patient/appointment/my_appointments/upcoming_appointments.dart';
import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:CuraDocs/app/user/user_singleton.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyAppointments extends ConsumerStatefulWidget {
  const MyAppointments({super.key});

  @override
  ConsumerState<MyAppointments> createState() => _MyAppointmentsState();
}

class _MyAppointmentsState extends ConsumerState<MyAppointments>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isViewingPreviousAppointments = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize patient email and load appointments data when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePatientData();
    });

    // Listen to tab changes to update FAB visibility
    _tabController.addListener(_handleTabChange);
  }

  void _initializePatientData() {
    // Set the current patient email from UserSingleton
    final patientEmail = UserSingleton().user.email;
    ref.read(currentPatientEmailProvider.notifier).state = patientEmail;

    // Initial fetch of appointments
    _fetchAppointmentsData();
  }

  Future<void> _fetchAppointmentsData() async {
    // Get patient email from provider (already set in _initializePatientData)
    final patientEmail = ref.read(currentPatientEmailProvider);
    if (patientEmail != null && patientEmail.isNotEmpty) {
      // Fetch active appointments
      await ref
          .read(appointmentStateProvider.notifier)
          .fetchPatientAppointments(
            context,
            patientEmail,
          );
    }
  }

  void _handleTabChange() {
    setState(() {
      // Update FAB visibility based on the selected tab
      _isViewingPreviousAppointments =
          _tabController.index == 2; // Hide FAB on Completed tab
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
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
          // Add refresh button to refresh appointments
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              final patientEmail = ref.read(currentPatientEmailProvider);
              if (patientEmail != null) {
                // Show refresh indicator in the active tab
                if (_tabController.index == 0) {
                  await ref
                      .read(appointmentStateProvider.notifier)
                      .refreshPatientAppointments(
                        context,
                        patientEmail,
                      );
                }
                // Additional tab-specific refresh logic can be added here
              }
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
        children: [
          // Create instances of each widget type
          const ActiveAppointments(), // This widget will be updated to use the provider
          const UpcomingAppointments(),
          CompletedAppointments(patientEmail: UserSingleton().user.email),
        ],
      ),
      floatingActionButton: !_isViewingPreviousAppointments
          ? AnimatedFloatingActionButton(
              onNewAppointment: () {
                // Handle new appointment action
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Creating new appointment...')),
                );
              },
              onReschedule: () {
                // Handle reschedule action
                context.goNamed(RouteConstants.doctorRescheduleAppointment);
              },
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
