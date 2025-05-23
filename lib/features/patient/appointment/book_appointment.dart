import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:CuraDocs/app/features_api_repository/appointment/patient/get_available_slot_provider.dart';
import 'package:CuraDocs/utils/snackbar.dart';

class BookAppointmentScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> doctorData;

  const BookAppointmentScreen({
    super.key,
    required this.doctorData,
  });

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

  @override
  void initState() {
    super.initState();

    // Initialize by fetching available slots for today
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAvailableSlots(_selectedDay);
    });
  }

  @override
  void dispose() {
    _appointmentNoteController.dispose();
    super.dispose();
  }

  // Fetch available slots for the selected date
  void _fetchAvailableSlots(DateTime date) {
    if (widget.doctorData['cin'] != null) {
      ref.read(availableSlotsProvider.notifier).fetchAvailableSlots(
            context,
            widget.doctorData['cin'],
            date,
          );
    } else {
      showSnackBar(
        context: context,
        message: 'Doctor information is incomplete',
      );
    }
  }

  // Refresh available slots for the selected date
  void _refreshAvailableSlots() {
    if (widget.doctorData['cin'] != null) {
      ref.read(availableSlotsProvider.notifier).refreshAvailableSlots(
            context,
            widget.doctorData['cin'],
            _selectedDay,
          );
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

    // Check if it's a non-working day using the provider
    return ref.read(availableSlotsProvider.notifier).isNonWorkingDay(day);
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the available slots state
    final availableSlotsState = ref.watch(availableSlotsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed:
                availableSlotsState.isLoading ? null : _refreshAvailableSlots,
          ),
        ],
      ),
      body: availableSlotsState.isLoading &&
              availableSlotsState.availableSlots.isEmpty
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
                            'Dr. ${widget.doctorData['name'] ?? 'Unknown Doctor'}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.doctorData['specialty'] ??
                                'Specialty not specified',
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
                                : availableSlotsState.availableSlots.isEmpty
                                    ? const Center(
                                        child: Text(
                                            'No available slots for selected date'))
                                    : Wrap(
                                        spacing: 8.0,
                                        runSpacing: 8.0,
                                        children: availableSlotsState
                                            .availableSlots
                                            .map((slot) {
                                          final time = slot['time'] as String;
                                          final address =
                                              slot['address'] as String;
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
