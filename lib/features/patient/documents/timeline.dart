import 'package:flutter/material.dart';

class Timeline {
  final String name;
  final String patientId;
  final String nextAppointment;

  Timeline({
    required this.name,
    required this.patientId,
    required this.nextAppointment,
  });
}

class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  _TimelinePageState createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  final List<Timeline> _patients = [
    Timeline(
        name: 'John Doe', patientId: '12345', nextAppointment: '2023-10-01'),
    Timeline(
        name: 'Jane Smith', patientId: '67890', nextAppointment: '2023-10-05'),
    // Add more patients as needed
  ];

  List<Timeline> _filteredPatients = [];

  @override
  void initState() {
    super.initState();
    _filteredPatients = _patients;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Expanded(
        child: SingleChildScrollView(
          child: Expanded(
            child: _buildManualTimeline(),
          ),
        ),
      ),
    );
  }

  Widget _buildManualTimeline() {
    return ListView.builder(
      itemCount: _filteredPatients.length,
      itemBuilder: (context, index) {
        final patient = _filteredPatients[index];
        final isLast = index == _filteredPatients.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline Dot and Line
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: Column(
                children: [
                  // Dot
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  // Line
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 60,
                      color: Colors.blueAccent,
                    ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    patient.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Patient ID: ${patient.patientId}'),
                      Text('Next Appointment: ${patient.nextAppointment}'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
