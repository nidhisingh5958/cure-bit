import 'package:CuraDocs/common/components/colors.dart';
import 'package:CuraDocs/features/features_api_repository/appointment/patient_repository.dart';
import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UpcomingAppointments extends StatefulWidget {
  const UpcomingAppointments({super.key});

  @override
  State<UpcomingAppointments> createState() => _UpcomingAppointmentsState();
}

class _UpcomingAppointmentsState extends State<UpcomingAppointments> {
  Set<int> expandedIndices = {};
  final PatientAppointmentRepository _PatientAppointmentRepository =
      PatientAppointmentRepository();
  bool _isLoading = false;

  void toggleExpanded(int index) {
    setState(() {
      if (expandedIndices.contains(index)) {
        expandedIndices.remove(index);
      } else {
        expandedIndices.add(index);
      }
    });
  }

  // Method to handle appointment cancellation
  Future<void> _cancelAppointment(
      String appointmentId, String doctorName) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // You might need to get the user role from a user service or provider
      String userRole =
          'Patient'; // Default role, replace with actual user role

      bool success = await _PatientAppointmentRepository.cancelAppointment(
        context,
        appointmentId,
        userRole,
      );

      if (success) {
        // Refresh appointments list - you might want to call a method to reload data
        // refreshAppointments();

        // For now, let's just close the dialog and show a snackbar
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Appointment with $doctorName cancelled successfully'),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Example data - you can replace with actual data source
    final List<Map<String, dynamic>> appointments = [
      {
        'doctorName': 'Dr. Bruce Banner',
        'specialty': 'General Physician',
        'time': 'Tomorrow, 10:00 AM',
        'problem': 'Recurring migraines and dizziness',
        'doctorId': 'dr_banner_123',
        'appointmentId': '504542', // Add appointment ID
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: appointments.isEmpty
          ? _buildNoAppointmentsMessage('No upcoming appointments found.')
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
                    _buildUpcomingAppointment(
                      context,
                      appointment['doctorName'] ?? '',
                      appointment['specialty'] ?? '',
                      appointment['time'] ?? '',
                      isExpanded: isExpanded,
                      onTap: () => toggleExpanded(index),
                      problem: appointment['problem'] ?? '',
                      doctorId: appointment['doctorId'] ?? '',
                      appointmentId: appointment['appointmentId'] ??
                          '', // Pass appointment ID
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

  Widget _buildUpcomingAppointment(
      BuildContext context, String doctorName, String specialty, String time,
      {required bool isExpanded,
      required VoidCallback onTap,
      required String problem,
      required String doctorId,
      required String appointmentId}) {
    // Add appointmentId parameter
    return Container(
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
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
            _buildUpcomingAppointmentDetails(context, problem, doctorId,
                doctorName, appointmentId), // Pass appointmentId
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointmentDetails(BuildContext context, String problem,
      String doctorId, String doctorName, String appointmentId) {
    // Add appointmentId parameter
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
            'Problem :',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: grey800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            problem,
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
                    // Navigate to doctor profile
                    debugPrint('Navigate to doctor profile: $doctorId');
                  },
                  icon: const Icon(Icons.person_outline),
                  label: const Text('Doctor Profile'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).primaryColor),
                    foregroundColor: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Cancel appointment
                    debugPrint('Cancel appointment: $appointmentId');
                    // Show confirmation dialog
                    _showCancelConfirmationDialog(
                        context, doctorName, appointmentId);
                  },
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancel'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red.shade300),
                    foregroundColor: Colors.red.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                context.goNamed(RouteConstants.rescheduleAppointment);
                // Reschedule appointment
                debugPrint('Reschedule appointment');
              },
              icon: const Icon(Icons.calendar_today),
              label: const Text('Reschedule'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dialog to confirm appointment cancellation
  void _showCancelConfirmationDialog(
      BuildContext context, String doctorName, String appointmentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Appointment'),
          content: Text(
              'Are you sure you want to cancel your appointment with $doctorName? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('No, Keep It'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      // Call the cancel method
                      _cancelAppointment(appointmentId, doctorName);
                    },
              child: _isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.red.shade700,
                      ),
                    )
                  : Text(
                      'Yes, Cancel',
                      style: TextStyle(color: Colors.red.shade700),
                    ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
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
