import 'package:CuraDocs/common/components/colors.dart';
import 'package:flutter/material.dart';

class CompletedAppointments extends StatefulWidget {
  const CompletedAppointments({super.key});

  @override
  State<CompletedAppointments> createState() => _CompletedAppointmentsState();
}

class _CompletedAppointmentsState extends State<CompletedAppointments> {
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
      // Uncomment to add sample appointments
      {
        'doctorName': 'Dr. Hank McCoy',
        'specialty': 'Dermatologist',
        'time': 'May 15, 2:30 PM',
        'diagnosis': 'Eczema on right arm',
        'prescriptionId': 'RX2023051501',
        'summaryId': 'SUMM2023051501',
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: appointments.isEmpty
          ? _buildNoAppointmentsMessage('No completed appointments found.')
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
                    _buildCompletedAppointment(
                      context,
                      appointment['doctorName'] ?? '',
                      appointment['specialty'] ?? '',
                      appointment['time'] ?? '',
                      isExpanded: isExpanded,
                      onTap: () => toggleExpanded(index),
                      diagnosis: appointment['diagnosis'] ?? '',
                      prescriptionId: appointment['prescriptionId'] ?? '',
                      summaryId: appointment['summaryId'] ?? '',
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

  Widget _buildCompletedAppointment(
      BuildContext context, String doctorName, String specialty, String time,
      {required bool isExpanded,
      required VoidCallback onTap,
      required String diagnosis,
      required String prescriptionId,
      required String summaryId}) {
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
            _buildCompletedAppointmentDetails(
                context, diagnosis, prescriptionId, summaryId),
        ],
      ),
    );
  }

  Widget _buildCompletedAppointmentDetails(BuildContext context,
      String diagnosis, String prescriptionId, String summaryId) {
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
            'Diagnosis:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: grey800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            diagnosis,
            style: TextStyle(
              fontSize: 14,
              color: grey600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Navigate to prescription
                    print('Navigate to prescription: $prescriptionId');
                  },
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('Prescription'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).primaryColor),
                    foregroundColor: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // View appointment summary
                    print('View summary: $summaryId');
                  },
                  icon: const Icon(Icons.summarize),
                  label: const Text('Summary'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // Book follow-up
                print('Book follow-up appointment');
              },
              icon: const Icon(Icons.calendar_today),
              label: const Text('Book Follow-up'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Theme.of(context).primaryColor),
                foregroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
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
            const SizedBox(width: 16),
            Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: grey600,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
