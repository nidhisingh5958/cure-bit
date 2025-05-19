import 'package:CuraDocs/common/components/colors.dart';
import 'package:CuraDocs/features/features_api_repository/appointment/doctor_repository.dart';
import 'package:CuraDocs/utils/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class DoctorRescheduleAppointment extends ConsumerStatefulWidget {
  final Map<String, dynamic>? appointment;

  const DoctorRescheduleAppointment({
    super.key,
    this.appointment,
  });

  @override
  ConsumerState<DoctorRescheduleAppointment> createState() =>
      _DoctorRescheduleAppointmentState();
}

class _DoctorRescheduleAppointmentState
    extends ConsumerState<DoctorRescheduleAppointment> {
  late TextEditingController titleController;

  late TextEditingController startTimeController;

  late TextEditingController dateController;

  // API required controllers
  late TextEditingController reasonController;
  // String appointmentId = '';
  String appointmentId = 'ghsdjhgs24';
  Color selectedColor = Colors.blue;
  DateTime selectedDate = DateTime.now();

  // Theme colors
  final Color primaryColor = Colors.black;
  final Color accentColor = Colors.black87;
  final Color surfaceColor = Colors.white;
  final Color textColor = Colors.black;
  final Color secondaryTextColor = Colors.black54;

  List<Map<String, dynamic>> appointments = [];
  bool isLoading = false;
  bool isSubmitting = false; // Track submission state
  final _formKey = GlobalKey<FormState>();

  // Instance of DoctorAppointmentRepository
  final DoctorAppointmentRepository _DoctorAppointmentRepository =
      DoctorAppointmentRepository();

  @override
  void initState() {
    super.initState();

    // Initialize all controllers first
    titleController = TextEditingController();

    startTimeController = TextEditingController();

    reasonController = TextEditingController(); // Initialize reason controller
    dateController = TextEditingController(
        text: DateFormat('MMMM d, yyyy').format(selectedDate));

    // Then populate with appointment data if available
    if (widget.appointment != null) {
      final appointment = widget.appointment!;

      // appointmentId = appointment['id'] ?? '';
      appointmentId = 'ghsdjhgs24';

      titleController.text = appointment['title'] ?? '';

      startTimeController.text = appointment['startTime'] ?? '';

      if (appointment['date'] != null) {
        try {
          selectedDate = DateFormat('MMMM d, yyyy').parse(appointment['date']);
          dateController.text = DateFormat('MMMM d, yyyy').format(selectedDate);
        } catch (e) {
          // Keep default date if parsing fails
        }
      }

      if (appointment['color'] != null) {
        selectedColor = appointment['color'];
      }
    }

    // Load appointments (would typically come from a service or provider)
    _loadAppointments();
  }

  void _loadAppointments() {
    // Simulate loading appointments from a data source
    setState(() {
      isLoading = true;
    });

    // Here you would typically fetch from API or local storage
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        // Mock data - in a real app this would come from a data source
        if (appointments.isEmpty) {
          appointments = [];
        }
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    startTimeController.dispose();
    dateController.dispose();
    reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: surfaceColor,
              onSurface: textColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateController.text = DateFormat('MMMM d, yyyy').format(selectedDate);
      });
    }
  }

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    TimeOfDay initialTime = TimeOfDay.now();

    if (controller.text.isNotEmpty) {
      try {
        final parts = controller.text.split(':');
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1].split(' ')[0]);
        String period = parts[1].split(' ')[1].toUpperCase();

        if (period == 'PM' && hour < 12) {
          hour += 12;
        } else if (period == 'AM' && hour == 12) {
          hour = 0;
        }

        initialTime = TimeOfDay(hour: hour, minute: minute);
      } catch (e) {
        // Use default if parsing fails
      }
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: surfaceColor,
              onSurface: textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
        final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
        controller.text =
            '${hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')} $period';
      });
    }
  }

  void _saveAppointment() async {
    if (_formKey.currentState!.validate()) {
      // Provide haptic feedback
      HapticFeedback.lightImpact();

      // Set loading state
      setState(() {
        isSubmitting = true;
      });

      // Format date for API (YYYY-MM-DD)
      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

      // Format time for API (HH:MM) - 24-hour format
      String apiTimeFormat = '';
      if (startTimeController.text.isNotEmpty) {
        try {
          final timeParts = startTimeController.text.split(':');
          int hour = int.parse(timeParts[0]);
          int minute = int.parse(timeParts[1].split(' ')[0]);
          String period = timeParts[1].split(' ')[1].toUpperCase();

          // Convert to 24-hour format
          if (period == 'PM' && hour < 12) hour += 12;
          if (period == 'AM' && hour == 12) hour = 0;

          apiTimeFormat =
              '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        } catch (e) {
          // Fallback to original format if parsing fails
          debugPrint('Error parsing time: ${e.toString()}');
          apiTimeFormat = startTimeController.text;
        }
      }
      // Check if appointment ID is available
      if (appointmentId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Cannot reschedule: Missing appointment ID'),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ));
        setState(() {
          isSubmitting = false;
        });
        return;
      }

      final success =
          await _DoctorAppointmentRepository.docRescheduleAppointment(
        context,
        appointmentId = '13456fAS',
        formattedDate,
        apiTimeFormat,
        reasonController.text.trim(),
        ref.read(userProvider)?.role ?? '',
      );

      setState(() {
        isSubmitting = false;
      });

      if (success) {
        final appointmentData = {
          'id': appointmentId,
          'title': titleController.text,
          'startTime': startTimeController.text,
          'date': dateController.text,
          'color': selectedColor,
        };

        // Update local state if needed
        if (widget.appointment != null) {
          final index =
              appointments.indexWhere((a) => a['id'] == appointmentData['id']);
          if (index != -1) {
            setState(() {
              appointments[index] = appointmentData;
            });
          }
        }

        // Navigate back with success result
        Future.delayed(const Duration(milliseconds: 300), () {
          Navigator.of(context).pop(true);
        });
      }
    }
  }

  void _deleteAppointment() {
    if (widget.appointment == null) return;

    // Provide haptic feedback
    HapticFeedback.mediumImpact();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Colors.red[700], size: 28),
              const SizedBox(width: 8),
              const Text('Delete Appointment'),
            ],
          ),
          content: const Text(
            'Are you sure you want to delete this appointment? This action cannot be undone.',
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: secondaryTextColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Cancel', style: TextStyle(fontSize: 15)),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Delete', style: TextStyle(fontSize: 15)),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onPressed: () {
                setState(() {
                  appointments
                      .removeWhere((a) => a['id'] == widget.appointment!['id']);
                });

                Navigator.of(context).pop(); // Close dialog

                // Show deletion confirmation
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Appointment deleted'),
                  backgroundColor: Colors.red[700],
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  duration: const Duration(seconds: 2),
                ));

                Future.delayed(const Duration(milliseconds: 300), () {
                  Navigator.of(context).pop(true); // Return to previous screen
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Reschedule Appointment',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red[700], size: 24),
            onPressed: _deleteAppointment,
          ),
        ],
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            )
          : SafeArea(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header image or icon
                      Center(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.edit_calendar_rounded,
                            size: 48,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Title field
                      _buildFormLabel('Appointment Title'),
                      const SizedBox(height: 8),
                      _buildTextFormField(
                        controller: titleController,
                        hintText: 'Enter appointment title',
                        prefixIcon: Icons.event_note,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Date field with calendar
                      _buildFormLabel('Date'),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectDate(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              // Calendar Preview
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      DateFormat('MMM')
                                          .format(selectedDate)
                                          .toUpperCase(),
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('dd').format(selectedDate),
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  dateController.text,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              Icon(Icons.calendar_today,
                                  color: black.withOpacity(0.5)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Start Time field
                      _buildFormLabel('Start Time'),
                      const SizedBox(height: 8),
                      _buildTextFormField(
                        controller: startTimeController,
                        hintText: 'Select start time',
                        prefixIcon: Icons.access_time,
                        readOnly: true,
                        onTap: () => _selectTime(context, startTimeController),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please select a start time';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Reason for rescheduling
                      _buildFormLabel('Reason for Rescheduling '),
                      const SizedBox(height: 8),
                      _buildTextFormField(
                        controller: reasonController,
                        hintText: 'Why are you rescheduling this appointment?',
                        prefixIcon: Icons.question_answer_outlined,
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please provide a reason for rescheduling';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Save button
                      ElevatedButton(
                        onPressed: isSubmitting ? null : _saveAppointment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: Colors.grey,
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Reschedule Appointment',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildFormLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool readOnly = false,
    Function()? onTap,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(prefixIcon, color: primaryColor),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red[400]!),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: TextStyle(
        color: textColor,
        fontSize: 14,
      ),
    );
  }
}
