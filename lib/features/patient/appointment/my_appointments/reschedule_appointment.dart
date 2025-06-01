import 'package:CureBit/common/components/colors.dart';
import 'package:CureBit/app/features_api_repository/appointment/patient/post_patient_repository.dart';
import 'package:CureBit/app/features_api_repository/appointment/patient/get/get_patient_repository.dart';
import 'package:CureBit/utils/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class BusyDatesState {
  final bool isLoading;
  final List<DateTime> busyDates;
  final String? errorMessage;

  const BusyDatesState({
    this.isLoading = false,
    this.busyDates = const [],
    this.errorMessage,
  });

  BusyDatesState copyWith({
    bool? isLoading,
    List<DateTime>? busyDates,
    String? errorMessage,
  }) {
    return BusyDatesState(
      isLoading: isLoading ?? this.isLoading,
      busyDates: busyDates ?? this.busyDates,
      errorMessage: errorMessage,
    );
  }
}

class BusyDatesNotifier extends StateNotifier<BusyDatesState> {
  final GetPatientRepository _repository;

  BusyDatesNotifier(this._repository) : super(const BusyDatesState());

  Future<void> fetchBusyDates(
    BuildContext context,
    String doctorCIN,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final busyDatesStrings = await _repository.getBusyDates(
        context,
        doctorCIN,
      );
      if (busyDatesStrings.isNotEmpty) {
        final List<DateTime> parsedBusyDates = [];
        for (String dateStr in busyDatesStrings) {
          try {
            final DateTime parsedDate = DateTime.parse(dateStr);
            parsedBusyDates.add(parsedDate);
          } catch (e) {
            debugPrint("Error parsing date '$dateStr': ${e.toString()}");
          }
        }
        state = state.copyWith(
          isLoading: false,
          busyDates: parsedBusyDates,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          busyDates: [],
        );
      }
    } catch (e) {
      debugPrint("Error in fetchBusyDates: ${e.toString()}");
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to fetch busy dates',
      );
    }
  }

  Future<void> refreshBusyDates(
    BuildContext context,
    String doctorCIN,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final success = await _repository.refreshBusyDates(
        context,
        doctorCIN,
      );
      if (success) {
        await fetchBusyDates(context, doctorCIN);
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to refresh busy dates',
        );
      }
    } catch (e) {
      debugPrint("Error in refreshBusyDates: ${e.toString()}");
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error refreshing busy dates',
      );
    }
  }

  bool isBusyDate(DateTime date) {
    return state.busyDates.any((busyDate) =>
        busyDate.year == date.year &&
        busyDate.month == date.month &&
        busyDate.day == date.day);
  }

  void clearBusyDates() {
    state = const BusyDatesState();
  }
}

// Create the provider
final busyDatesProvider =
    StateNotifierProvider<BusyDatesNotifier, BusyDatesState>((ref) {
  return BusyDatesNotifier(GetPatientRepository());
});

class PatientRescheduleAppointment extends ConsumerStatefulWidget {
  final Map<String, dynamic>? appointment;

  const PatientRescheduleAppointment({
    super.key,
    this.appointment,
  });

  @override
  ConsumerState<PatientRescheduleAppointment> createState() =>
      _PatientRescheduleAppointmentState();
}

class _PatientRescheduleAppointmentState
    extends ConsumerState<PatientRescheduleAppointment> {
  late TextEditingController titleController;
  late TextEditingController startTimeController;
  late TextEditingController dateController;
  late TextEditingController reasonController;

  String appointmentId = 'ghsdjhgs24';
  String? doctorCIN; // To store doctor's CIN for busy dates
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
  bool isSubmitting = false;
  final _formKey = GlobalKey<FormState>();

  // Instance of PatientAppointmentRepository
  final PatientAppointmentRepository _PatientappointmentRepository =
      PatientAppointmentRepository();

  @override
  void initState() {
    super.initState();
    // Initialize all controllers first
    titleController = TextEditingController();
    startTimeController = TextEditingController();
    reasonController = TextEditingController();
    dateController = TextEditingController(
        text: DateFormat('MMMM d, yyyy').format(selectedDate));

    // Then populate with appointment data if available
    if (widget.appointment != null) {
      final appointment = widget.appointment!;
      appointmentId = 'ghsdjhgs24';
      doctorCIN = appointment['doctorCIN'] ??
          appointment['doctor_cin']; // Get doctor CIN
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

    // Load appointments and busy dates
    _loadAppointments();

    // Fetch busy dates if doctor CIN is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (doctorCIN != null && doctorCIN!.isNotEmpty) {
        _fetchBusyDates();
      }
    });
  }

  void _fetchBusyDates() {
    if (doctorCIN != null && doctorCIN!.isNotEmpty) {
      ref.read(busyDatesProvider.notifier).fetchBusyDates(
            context,
            doctorCIN!,
          );
    }
  }

  void _loadAppointments() {
    setState(() {
      isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
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

  // Check if a date should be disabled (past dates or busy dates)
  bool _isDateDisabled(DateTime date) {
    // Disable past dates (except today)
    if (date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return true;
    }
    // Check if it's a busy date
    final busyDatesState = ref.watch(busyDatesProvider);
    return ref.read(busyDatesProvider.notifier).isBusyDate(date);
  }

  Future<void> _selectDate(BuildContext context) async {
    final busyDatesState = ref.watch(busyDatesProvider);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      selectableDayPredicate: (DateTime day) {
        return !_isDateDisabled(day);
      },
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
      // Double-check if the selected date is not busy
      if (!ref.read(busyDatesProvider.notifier).isBusyDate(picked)) {
        setState(() {
          selectedDate = picked;
          dateController.text = DateFormat('MMMM d, yyyy').format(selectedDate);
        });
      } else {
        // Show message if somehow a busy date was selected
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Selected date is not available. Please choose another date.'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
      // Check if selected date is busy before saving
      if (ref.read(busyDatesProvider.notifier).isBusyDate(selectedDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Selected date is not available. Please choose another date.'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // Provide haptic feedback
      HapticFeedback.lightImpact();

      // Set loading state
      setState(() {
        isSubmitting = true;
      });

      // Format date for API (YYYY-MM-DD)
      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

      try {
        // Get user info from provider
        final userInfo = ref.read(userProvider);
        final patientCIN = userInfo?.cin ?? '';

        // Prepare appointment data
        final appointmentData = {
          'appointmentId': appointmentId,
          'title': titleController.text.trim(),
          'date': formattedDate,
          'startTime': startTimeController.text.trim(),
          'reason': reasonController.text.trim(),
          'doctorCIN': doctorCIN ?? '',
          'patientCIN': patientCIN,
        };

        // Call the API to reschedule appointment
        final success =
            await _PatientappointmentRepository.rescheduleAppointment(
          context,
          appointmentData['appointmentId'] ?? '',
          appointmentData['title'] ?? '',
          appointmentData['date'] ?? '',
          appointmentData['startTime'] ?? '',
          appointmentData['reason'] ?? '',
        );

        if (success) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Appointment rescheduled successfully!'),
              backgroundColor: Colors.green[700],
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Refresh busy dates to reflect the change
          if (doctorCIN != null && doctorCIN!.isNotEmpty) {
            await ref.read(busyDatesProvider.notifier).refreshBusyDates(
                  context,
                  doctorCIN!,
                );
          }

          // Navigate back with success result
          Navigator.of(context).pop(true);
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Failed to reschedule appointment. Please try again.'),
              backgroundColor: Colors.red[700],
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error rescheduling appointment: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('An error occurred. Please try again.'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final busyDatesState = ref.watch(busyDatesProvider);

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: textColor,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Reschedule Appointment',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (busyDatesState.isLoading)
            Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              ),
            ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Original Appointment Info Card
                    if (widget.appointment != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Appointment',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${widget.appointment!['title'] ?? 'N/A'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: secondaryTextColor,
                              ),
                            ),
                            Text(
                              '${widget.appointment!['date'] ?? 'N/A'} at ${widget.appointment!['startTime'] ?? 'N/A'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Title Field
                    Text(
                      'Appointment Title',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: titleController,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Enter appointment title',
                        hintStyle: TextStyle(color: secondaryTextColor),
                        filled: true,
                        fillColor: surfaceColor,
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
                          borderSide: BorderSide(color: primaryColor, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter appointment title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Date Field
                    Text(
                      'Date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: dateController,
                      readOnly: true,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Select date',
                        hintStyle: TextStyle(color: secondaryTextColor),
                        filled: true,
                        fillColor: surfaceColor,
                        suffixIcon: Icon(
                          Icons.calendar_today,
                          color: primaryColor,
                          size: 20,
                        ),
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
                          borderSide: BorderSide(color: primaryColor, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      onTap: () => _selectDate(context),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please select a date';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Time Field
                    Text(
                      'Time',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: startTimeController,
                      readOnly: true,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Select time',
                        hintStyle: TextStyle(color: secondaryTextColor),
                        filled: true,
                        fillColor: surfaceColor,
                        suffixIcon: Icon(
                          Icons.access_time,
                          color: primaryColor,
                          size: 20,
                        ),
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
                          borderSide: BorderSide(color: primaryColor, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      onTap: () => _selectTime(context, startTimeController),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please select a time';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Reason Field
                    Text(
                      'Reason for Rescheduling',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: reasonController,
                      maxLines: 3,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Enter reason for rescheduling (optional)',
                        hintStyle: TextStyle(color: secondaryTextColor),
                        filled: true,
                        fillColor: surfaceColor,
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
                          borderSide: BorderSide(color: primaryColor, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : _saveAppointment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: isSubmitting
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(
                                'Reschedule Appointment',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Busy dates info
                    if (busyDatesState.busyDates.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.orange[700],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Doctor\'s Busy Dates',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'The following dates are not available for booking:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: busyDatesState.busyDates
                                  .take(5) // Show only first 5 dates
                                  .map((date) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orange[100],
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          DateFormat('MMM d').format(date),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.orange[700],
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                            if (busyDatesState.busyDates.length > 5)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '+ ${busyDatesState.busyDates.length - 5} more dates',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.orange[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],

                    // Error message for busy dates
                    if (busyDatesState.errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red[700],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                busyDatesState.errorMessage!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
