import 'package:CuraDocs/common/components/app_header.dart';
import 'package:CuraDocs/common/components/colors.dart';
import 'package:CuraDocs/common/components/pop_up.dart';
import 'package:CuraDocs/features/doctor/appointment/components/animated_fab.dart';
import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class Patient {
  final String name;
  final String imagePath;
  final String consultationType;
  final String time;
  final bool isNext;

  Patient({
    required this.name,
    required this.imagePath,
    required this.consultationType,
    required this.time,
    this.isNext = false,
  });
}

class DoctorScheduleScreen extends StatelessWidget {
  const DoctorScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data
    final List<Patient> patients = [
      Patient(
        name: 'Sierra Fritsch',
        imagePath: 'assets/images/patient1.jpg',
        consultationType: 'Video Consultation',
        time: '10:00 AM - 11:00 AM',
        isNext: true,
      ),
      Patient(
        name: 'Foster Nolan',
        imagePath: 'assets/images/patient2.jpg',
        consultationType: 'Video Consultation',
        time: '10:00 AM',
      ),
      Patient(
        name: 'Foster Nolan',
        imagePath: 'assets/images/patient2.jpg',
        consultationType: 'In-Clinic Consultation',
        time: '10:00 AM',
      ),
      Patient(
        name: 'Sierra Fritsch',
        imagePath: 'assets/images/patient1.jpg',
        consultationType: 'Video Consultation',
        time: '10:00 AM',
      ),
      Patient(
        name: 'Sierra Fritsch',
        imagePath: 'assets/images/patient1.jpg',
        consultationType: 'Video Consultation',
        time: '10:00 AM',
      ),
    ];

    return Scaffold(
      appBar: AppHeader(
        title: 'Appointments',
        onDetailPressed: () => context.goNamed(
          RouteConstants.doctorSchedulingAppointmentDetails,
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.circleEllipsis),
            onPressed: () {
              PopUp.buildPopupMenu(
                context,
                // icon: Icon(Icons.attach_file),
                onSelected: (value) {
                  if (value == 'assign') {
                    // Handle book appointment action
                    context.goNamed(
                        RouteConstants.doctorSchedulingAppointmentDetails);
                  } else if (value == 'info') {
                    // Handle help action
                    // context.goNamed(RouteConstants.help);
                  }
                },
                optionsList: [
                  {'assign': 'Scheduling Details'},
                  {'info': 'Help'},
                ],
              );
            },
          ),
        ],
      ),
      floatingActionButton: AnimatedFloatingActionButton(
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Today, Wed 10 Oct',
                        style: TextStyle(
                          color: black,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.only(right: 2),
                    decoration: BoxDecoration(
                      color: transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: transparent, width: 1),
                    ),
                    child: IconButton(
                      icon: Icon(LucideIcons.calendar, color: black),
                      onPressed: () {
                        context.goNamed('doctorScheduleCalendar');
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Text(
                'Appointments',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Patients list
              Expanded(
                child: ListView.builder(
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    final patient = patients[index];

                    // Next appointment card
                    if (patient.isNext) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: .1),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Next Appointment',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    patient.time,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundImage:
                                        AssetImage(patient.imagePath),
                                    backgroundColor: Colors.grey[300],
                                    child: patient.imagePath.isEmpty
                                        ? Text(
                                            patient.name[0],
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          patient.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.videocam,
                                              size: 20,
                                              color: black,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              patient.consultationType,
                                              style: TextStyle(
                                                color: grey600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        LucideIcons.messageCircle,
                                        color: black,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        context.goNamed(
                                          RouteConstants.doctorChat,
                                          extra: patient,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: grey600,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          side: BorderSide(color: grey600),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                      ),
                                      child: const Text('Cancel'),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: grey800,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                      ),
                                      child: const Text('Start Call'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      );
                    }

                    // Regular appointment item
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: .1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Row(
                          children: [
                            Container(
                              width: 70,
                              alignment: Alignment.center,
                              child: Text(
                                patient.time.split(' - ')[0],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: patient.isNext ? black : grey600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 16),
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: AssetImage(patient.imagePath),
                              backgroundColor: Colors.grey[300],
                              child: patient.imagePath.isEmpty
                                  ? Text(
                                      patient.name[0],
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    patient.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        patient.consultationType
                                                .contains('Video')
                                            ? Icons.videocam
                                            : Icons.home_work,
                                        size: 18,
                                        color: patient.consultationType
                                                .contains('Video')
                                            ? grey600
                                            : grey400,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        patient.consultationType,
                                        style: TextStyle(
                                          color: grey600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
