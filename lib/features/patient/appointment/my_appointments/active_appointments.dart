import 'package:CureBit/common/components/colors.dart';
import 'package:CureBit/services/features_api_repository/appointment/patient/my_appointments/active_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ActiveAppointments extends ConsumerStatefulWidget {
  const ActiveAppointments({super.key});

  @override
  ConsumerState<ActiveAppointments> createState() => _ActiveAppointmentsState();
}

class _ActiveAppointmentsState extends ConsumerState<ActiveAppointments> {
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
  void initState() {
    super.initState();
    // Fetch appointments when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAppointments();
    });
  }

  Future<void> _loadAppointments() async {
    // Use ref directly from ConsumerState
    final patientEmail = ref.read(currentPatientEmailProvider);
    if (patientEmail != null) {
      await ref
          .read(appointmentStateProvider.notifier)
          .fetchPatientAppointments(
            context,
            patientEmail,
          );
    }
  }

  Future<void> _refreshAppointments() async {
    // Use ref directly from ConsumerState
    final patientEmail = ref.read(currentPatientEmailProvider);
    if (patientEmail != null) {
      await ref
          .read(appointmentStateProvider.notifier)
          .refreshPatientAppointments(
            context,
            patientEmail,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get appointment state from provider
    final appointmentState = ref.watch(appointmentStateProvider);
    final appointments = appointmentState.appointments;
    final isLoading = appointmentState.isLoading;

    return RefreshIndicator(
      onRefresh: _refreshAppointments,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: isLoading
            ? _buildLoadingIndicator()
            : appointments.isEmpty
                ? _buildNoAppointmentsMessage('No active appointments found.')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      final appointment = appointments[index];
                      final isExpanded = expandedIndices.contains(index);

                      // Format appointment time for display
                      final appointmentDateTime = DateTime.parse(
                          appointment['appointmentDate'] ??
                              DateTime.now().toIso8601String());

                      final formattedDate =
                          _formatAppointmentDate(appointmentDateTime);
                      final formattedTime =
                          DateFormat('h:mm a').format(appointmentDateTime);
                      final displayTime = '$formattedDate, $formattedTime';

                      return Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildActiveAppointment(
                            context,
                            appointment['doctorName'] ?? 'Unknown Doctor',
                            appointment['specialty'] ?? 'Medical Professional',
                            displayTime,
                            isExpanded: isExpanded,
                            onTap: () => toggleExpanded(index),
                            meetingLink: appointment['meetingLink'] ?? '',
                            patientInstructions:
                                appointment['patientInstructions'] ??
                                    'No specific instructions provided.',
                          ),
                        ],
                      );
                    },
                  ),
      ),
    );
  }

  String _formatAppointmentDate(DateTime date) {
    final now = DateTime.now();

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day + 1) {
      return 'Tomorrow';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: CircularProgressIndicator(),
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
          if (meetingLink.isNotEmpty)
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to video call
                debugPrint('Join video call: $meetingLink');
                // Implementation for launching the meeting would go here
              },
              icon: const Icon(Icons.videocam),
              label: const Text('Join Video Call'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 40),
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
            // Arrow icon to indicate expandable content
            Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: grey600,
            ),
          ],
        ),
      ),
    );
  }
}
