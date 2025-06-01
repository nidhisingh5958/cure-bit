import 'package:CureBit/services/features_api_repository/appointment/patient/get/get_patient_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:CureBit/services/features_api_repository/appointment/patient/get/available_slot_provider.dart';
import 'package:CureBit/utils/snackbar.dart';

// Import the busy dates provider
final busyDatesProvider =
    StateNotifierProvider<BusyDatesNotifier, BusyDatesState>((ref) {
  return BusyDatesNotifier(GetPatientRepository());
});

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

class BookAppointmentScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> doctorData;

  BookAppointmentScreen({
    super.key,
    required this.doctorData,
  }) {
    debugPrint('BookAppointmentScreen received doctorData: $doctorData');
    debugPrint('doctorData type: ${doctorData.runtimeType}');
    debugPrint('doctorData keys: ${doctorData.keys.toList()}');
  }

  @override
  ConsumerState<BookAppointmentScreen> createState() =>
      _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends ConsumerState<BookAppointmentScreen> {
  // Calendar and date selection
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  // Selected time slot
  String _selectedTimeSlot = '';

  // Selected address
  String _selectedAddress = '';

  // Loading state
  bool _isSubmitting = false;

  // Appointment note
  final TextEditingController _appointmentNoteController =
      TextEditingController();

  // Helper method to safely get string values from doctorData
  String? _getDoctorDataString(String key) {
    final value = widget.doctorData[key];
    return value?.toString();
  }

  // Helper method to get doctor CIN with null safety
  String? get _doctorCIN => _getDoctorDataString('cin');

  // Helper method to get doctor name with fallback
  String get _doctorName => _getDoctorDataString('name') ?? 'string';

  // Helper method to get doctor specialty with fallback
  String get _doctorSpecialty =>
      _getDoctorDataString('specialty') ??
      _getDoctorDataString('specialization') ??
      'Specialty not specified';

  @override
  void initState() {
    super.initState();

    // Initialize by fetching available slots and busy dates for today
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAvailableSlots(_selectedDay);
      _fetchBusyDates();
    });
  }

  @override
  void dispose() {
    _appointmentNoteController.dispose();
    super.dispose();
  }

  // Fetch available slots for the selected date
  void _fetchAvailableSlots(DateTime date) {
    final doctorCIN = _doctorCIN;
    if (doctorCIN != null && doctorCIN.isNotEmpty) {
      ref.read(availableSlotsProvider.notifier).fetchAvailableSlots(
            context,
            doctorCIN,
            date,
          );
    } else {
      showSnackBar(
        context: context,
        message: 'Doctor information is incomplete',
      );
    }
  }

  // Fetch busy dates for the doctor
  void _fetchBusyDates() {
    final doctorCIN = _doctorCIN;
    if (doctorCIN != null && doctorCIN.isNotEmpty) {
      ref.read(busyDatesProvider.notifier).fetchBusyDates(
            context,
            doctorCIN,
          );
    }
  }

  // Refresh available slots for the selected date
  void _refreshAvailableSlots() {
    final doctorCIN = _doctorCIN;
    if (doctorCIN != null && doctorCIN.isNotEmpty) {
      ref.read(availableSlotsProvider.notifier).refreshAvailableSlots(
            context,
            doctorCIN,
            _selectedDay,
          );
      // Also refresh busy dates
      _fetchBusyDates();
    }
  }

  // Handle calendar day selection
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedTimeSlot = ''; // Reset selected time slot
        _selectedAddress = ''; // Reset selected address
      });

      // Fetch available slots for the newly selected day
      _fetchAvailableSlots(selectedDay);
    }
  }

  // Submit appointment booking
  Future<void> _submitAppointment() async {
    // Validate input fields
    if (_selectedTimeSlot.isEmpty) {
      showSnackBar(
        context: context,
        message: 'Please select a time slot',
      );
      return;
    }

    if (_selectedAddress.isEmpty) {
      showSnackBar(
        context: context,
        message: 'Please select an address',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Here you would integrate your existing POST request for booking
      // This is a placeholder for your existing booking logic
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      // Show success message and navigate back
      if (mounted) {
        showSnackBar(
          context: context,
          message: 'Appointment booked successfully',
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint("Error booking appointment: ${e.toString()}");
      showSnackBar(
        context: context,
        message: 'Failed to book appointment. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // Check if a day should be disabled in the calendar
  bool _isDayDisabled(DateTime day) {
    // Disable past days
    if (day.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return true;
    }

    // Check if it's a busy date
    final busyDatesState = ref.watch(busyDatesProvider);
    if (ref.read(busyDatesProvider.notifier).isBusyDate(day)) {
      return true;
    }

    // Check if it's a non-working day using the existing provider
    return ref.read(availableSlotsProvider.notifier).isNonWorkingDay(day);
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the available slots state
    final availableSlotsState = ref.watch(availableSlotsProvider);
    final busyDatesState = ref.watch(busyDatesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed:
                (availableSlotsState.isLoading || busyDatesState.isLoading)
                    ? null
                    : _refreshAvailableSlots,
          ),
        ],
      ),
      body: (availableSlotsState.isLoading &&
                  availableSlotsState.availableSlots.isEmpty) ||
              (busyDatesState.isLoading && busyDatesState.busyDates.isEmpty)
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doctor information card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dr. $_doctorName',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _doctorSpecialty,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Calendar Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'Select Date',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TableCalendar(
                            firstDay: DateTime.now(),
                            lastDay:
                                DateTime.now().add(const Duration(days: 90)),
                            focusedDay: _focusedDay,
                            selectedDayPredicate: (day) =>
                                isSameDay(_selectedDay, day),
                            onDaySelected: _onDaySelected,
                            enabledDayPredicate: (day) => !_isDayDisabled(day),
                            calendarFormat: CalendarFormat.month,
                            headerStyle: const HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: true,
                            ),
                            calendarStyle: CalendarStyle(
                              // Style for busy dates that are disabled
                              disabledDecoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              disabledTextStyle: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Legend for busy dates
                          if (busyDatesState.busyDates.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.3),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Busy dates (unavailable)',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Time slots section
                  if (availableSlotsState.errorMessage != null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          availableSlotsState.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    )
                  else if (busyDatesState.errorMessage != null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          busyDatesState.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    )
                  else
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Available Time Slots',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            availableSlotsState.isLoading
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : availableSlotsState.availableSlots.isEmpty ||
                                        ref
                                            .read(busyDatesProvider.notifier)
                                            .isBusyDate(_selectedDay)
                                    ? Center(
                                        child: Text(ref
                                                .read(
                                                    busyDatesProvider.notifier)
                                                .isBusyDate(_selectedDay)
                                            ? 'Selected date is not available'
                                            : 'No available slots for selected date'))
                                    : Wrap(
                                        spacing: 8.0,
                                        runSpacing: 8.0,
                                        children: availableSlotsState
                                            .availableSlots
                                            .map((slot) {
                                          final time =
                                              slot['time']?.toString() ?? '';
                                          final address =
                                              slot['address']?.toString() ?? '';
                                          final isSelected =
                                              _selectedTimeSlot == time &&
                                                  _selectedAddress == address;

                                          return ChoiceChip(
                                            label: Text(time),
                                            selected: isSelected,
                                            onSelected: (selected) {
                                              setState(() {
                                                if (selected) {
                                                  _selectedTimeSlot = time;
                                                  _selectedAddress = address;
                                                } else {
                                                  _selectedTimeSlot = '';
                                                  _selectedAddress = '';
                                                }
                                              });
                                            },
                                          );
                                        }).toList(),
                                      ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Selected address display
                  if (_selectedAddress.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Location',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(_selectedAddress),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Appointment note
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Appointment Note (Optional)',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _appointmentNoteController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: 'Add any notes for the doctor...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Book appointment button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitAppointment,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Book Appointment'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
