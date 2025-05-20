import 'package:CuraDocs/common/components/colors.dart';
import 'package:CuraDocs/features/features_api_repository/appointment/patient/my_appointments/completed_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CompletedAppointments extends ConsumerStatefulWidget {
  final String patientEmail;

  const CompletedAppointments({
    super.key,
    required this.patientEmail,
  });

  @override
  ConsumerState<CompletedAppointments> createState() =>
      _CompletedAppointmentsState();
}

class _CompletedAppointmentsState extends ConsumerState<CompletedAppointments> {
  Set<int> expandedIndices = {};

  @override
  void initState() {
    super.initState();
    // Fetch completed appointments when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(completedAppointmentsProvider.notifier)
          .fetchCompletedAppointments(context, widget.patientEmail);
    });
  }

  void toggleExpanded(int index) {
    setState(() {
      if (expandedIndices.contains(index)) {
        expandedIndices.remove(index);
      } else {
        expandedIndices.add(index);
      }
    });
  }

  // Format appointment date
  String _formatAppointmentDate(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('MMM d, h:mm a').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(completedAppointmentsProvider);

    // If loading, show progress indicator
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // If error, show error message
    if (state.hasError) {
      return _buildNoAppointmentsMessage('Error: ${state.errorMessage}');
    }

    // If appointments list is empty
    if (state.appointments.isEmpty) {
      return _buildNoAppointmentsMessage('No completed appointments found.');
    }

    return Column(
      children: [
        // Add refresh button at the top
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  ref
                      .read(completedAppointmentsProvider.notifier)
                      .refreshCompletedAppointments(
                          context, widget.patientEmail);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ),
        // Appointments list
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.appointments.length,
            itemBuilder: (context, index) {
              final appointment = state.appointments[index];
              final isExpanded = expandedIndices.contains(index);

              // Extract values from appointment data
              final doctorName = appointment['doctor_name'] ?? 'Unknown Doctor';
              final specialty = appointment['doctor_specialty'] ?? 'Specialist';
              final appointmentTime =
                  _formatAppointmentDate(appointment['appointment_date'] ?? '');
              final diagnosis =
                  appointment['diagnosis'] ?? 'No diagnosis available';
              final prescriptionId = appointment['prescription_id'] ?? '';
              final summaryId =
                  appointment['summary_id'] ?? appointment['id'] ?? '';

              return Column(
                children: [
                  const SizedBox(height: 16),
                  _buildCompletedAppointment(
                    context,
                    doctorName,
                    specialty,
                    appointmentTime,
                    isExpanded: isExpanded,
                    onTap: () => toggleExpanded(index),
                    diagnosis: diagnosis,
                    prescriptionId: prescriptionId,
                    summaryId: summaryId,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNoAppointmentsMessage(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: grey600,
              ),
            ),
            const SizedBox(height: 16),
            if (message.startsWith(
                'No')) // Only show refresh button if there are no appointments
              ElevatedButton.icon(
                onPressed: () {
                  ref
                      .read(completedAppointmentsProvider.notifier)
                      .refreshCompletedAppointments(
                          context, widget.patientEmail);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
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
                  onPressed: prescriptionId.isEmpty
                      ? null // Disable button if no prescription
                      : () {
                          // Navigate to prescription
                          debugPrint(
                              'Navigate to prescription: $prescriptionId');
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
                  onPressed: summaryId.isEmpty
                      ? null // Disable button if no summary
                      : () {
                          // View appointment summary
                          debugPrint('View summary: $summaryId');
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
                debugPrint('Book follow-up appointment');
                // Here you would navigate to appointment booking screen
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
