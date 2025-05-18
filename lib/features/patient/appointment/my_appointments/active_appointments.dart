import 'package:CuraDocs/common/components/colors.dart';
import 'package:flutter/material.dart';

class ActiveAppointments extends StatefulWidget {
  const ActiveAppointments({super.key});

  @override
  State<ActiveAppointments> createState() => _ActiveAppointmentsState();
}

class _ActiveAppointmentsState extends State<ActiveAppointments> {
  Set<int> expandedIndices = {};

  void toggleExpanded(int index) {
    setState(() {
      if (expandedIndices.contains(index)) {
        expandedIndices.remove(index);
      } else {
        expandedIndices.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Example data - you can replace with actual data source
    final List<Map<String, dynamic>> appointments = [
      {
        'doctorName': 'Dr. Jean Grey',
        'specialty': 'Cardiologist',
        'time': 'Today, 3:00 PM',
        'meetingLink': 'https://meet.curadocs.com/dr-grey',
        'patientInstructions':
            'Please be prepared to discuss your recent test results',
      },
      {
        'doctorName': 'Dr. Stephen Strange',
        'specialty': 'Neurologist',
        'time': 'Today, 5:30 PM',
        'meetingLink': 'https://meet.curadocs.com/dr-strange',
        'patientInstructions': 'Have your recent MRI scans ready for review',
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: appointments.isEmpty
          ? _buildNoAppointmentsMessage('No active appointments found.')
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appointment = appointments[index];
                final isExpanded = expandedIndices.contains(index);

                return Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildActiveAppointment(
                      context,
                      appointment['doctorName'] ?? '',
                      appointment['specialty'] ?? '',
                      appointment['time'] ?? '',
                      isExpanded: isExpanded,
                      onTap: () => toggleExpanded(index),
                      meetingLink: appointment['meetingLink'] ?? '',
                      patientInstructions:
                          appointment['patientInstructions'] ?? '',
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildNoAppointmentsMessage(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          message,
          style: TextStyle(
            fontSize: 16,
            color: grey600,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveAppointment(
      BuildContext context, String doctorName, String specialty, String time,
      {required bool isExpanded,
      required VoidCallback onTap,
      required String meetingLink,
      required String patientInstructions}) {
    return Container(
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildAppointmentItem(
            doctorName,
            specialty,
            time,
            isExpanded: isExpanded,
            onTap: onTap,
          ),
          if (isExpanded)
            _buildActiveAppointmentDetails(
                context, meetingLink, patientInstructions),
        ],
      ),
    );
  }

  Widget _buildActiveAppointmentDetails(
      BuildContext context, String meetingLink, String patientInstructions) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Instructions:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: grey800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            patientInstructions,
            style: TextStyle(
              fontSize: 14,
              color: grey600,
            ),
          ),
          const SizedBox(height: 16),
          // ElevatedButton.icon(
          //   onPressed: () {
          //     // Navigate to video call
          //     print('Join video call: $meetingLink');
          //   },
          //   icon: const Icon(Icons.videocam),
          //   label: const Text('Join Video Call'),
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: Theme.of(context).primaryColor,
          //     foregroundColor: Colors.white,
          //     minimumSize: const Size(double.infinity, 40),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildAppointmentItem(String title, String subtitle, String time,
      {bool isFirst = false,
      required bool isExpanded,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: grey200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isFirst ? Icons.person : Icons.medical_services_outlined,
                color: grey800,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: grey600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: grey100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: grey800,
                ),
              ),
            ),
            // No arrow icon for active appointments
          ],
        ),
      ),
    );
  }
}
