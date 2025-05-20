import 'dart:math';

import 'package:CuraDocs/common/components/app_header.dart';
import 'package:CuraDocs/common/components/colors.dart';
import 'package:CuraDocs/features/features_api_repository/appointment/doctor/post_doctor_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DoctorCalendarSchedule extends StatefulWidget {
  const DoctorCalendarSchedule({super.key});

  @override
  State<DoctorCalendarSchedule> createState() => _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState extends State<DoctorCalendarSchedule> {
  DateTime selectedDate = DateTime.now(); // Use current date by default
  bool isCalendarExpanded = false;

  // Repository instance for API calls
  final DoctorPostAppointmentRepository _appointmentRepository =
      DoctorPostAppointmentRepository();

  // Currently editing appointment
  Map<String, dynamic>? editingAppointment;

  // Loading state for appointments being updated
  Map<String, bool> loadingAppointments = {};

  List<Map<String, dynamic>> appointments = [
    {
      'id': '1',
      'title': 'Team meeting',
      'location': 'Meeting room level 9',
      'date': 'January 3, 2022',
      'startTime': '08:00 AM',
      'endTime': '09:00 AM',
      'color': Colors.amber,
      'isDone': true,
    },
    {
      'id': '2',
      'title': 'Present a plan',
      'location': 'Meeting room level 9',
      'date': 'January 3, 2022',
      'startTime': '09:00 AM',
      'endTime': '10:00 AM',
      'color': Colors.indigo.shade400,
      'isDone': false,
    },
    {
      'id': '3',
      'title': 'Meeting summary',
      'location': 'Meeting room level 9',
      'date': 'January 3, 2022',
      'startTime': '10:00 AM',
      'endTime': '11:00 AM',
      'color': Colors.green,
      'isDone': false,
    },
    {
      'id': '4',
      'title': 'Design first draft',
      'location': 'Meeting room level 9',
      'date': 'January 3, 2022',
      'startTime': '11:00 AM',
      'endTime': '12:00 PM',
      'color': Colors.pink,
      'isDone': false,
    },
  ];

  // For controlling date pickers
  final TextEditingController yearController = TextEditingController();
  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  @override
  void initState() {
    super.initState();
    yearController.text = selectedDate.year.toString();

    // Generate appointments for the selected date
    updateAppointmentsForSelectedDate();
  }

  @override
  void dispose() {
    yearController.dispose();
    super.dispose();
  }

  void updateAppointmentsForSelectedDate() {
    final formattedDate = DateFormat('MMMM d, yyyy').format(selectedDate);

    // In a real app, this would fetch from a database
    // Here we're just updating the date string on the appointments
    setState(() {
      for (var appointment in appointments) {
        appointment['date'] = formattedDate;
      }
    });
  }

  // Updated to use the repository and prevent undoing completed appointments
  Future<void> toggleAppointmentStatus(String appointmentId) async {
    // Find the appointment
    final index = appointments.indexWhere((a) => a['id'] == appointmentId);
    if (index == -1) return;

    // If the appointment is already marked as done, don't allow undoing
    if (appointments[index]['isDone']) {
      debugPrint('Appointment already marked as done, cannot undo');
      return;
    }

    // Set loading state
    setState(() {
      loadingAppointments[appointmentId] = true;
    });

    try {
      // Call the API to update the appointment status
      final success = await _appointmentRepository.updateAppointmentStatus(
          context,
          appointmentId,
          true // Always set to true because we're marking as done and not allowing undo
          );

      if (success) {
        // Update the local state only if the API call was successful
        setState(() {
          appointments[index]['isDone'] = true;
        });
      }
    } catch (e) {
      debugPrint("Error toggling appointment status: ${e.toString()}");
    } finally {
      // Clear loading state
      setState(() {
        loadingAppointments[appointmentId] = false;
      });
    }
  }

  void changeSelectedDate(DateTime date) {
    setState(() {
      selectedDate = date;
      updateAppointmentsForSelectedDate();
      // Keep calendar expanded if user is actively selecting dates
    });
  }

  String get selectedMonthName => DateFormat('MMMM').format(selectedDate);
  int get selectedDay => selectedDate.day;
  int get selectedYear => selectedDate.year;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: white,
        appBar: AppHeader(
          title: 'Schedule',
          onBackPressed: () => context.goNamed('doctorSchedule'),
          actions: [
            IconButton(
              icon: const Icon(LucideIcons.search),
              onPressed: () {
                context.goNamed('scheduleSearch');
              },
            ),
          ],
        ),
        body: Column(
          children: [
            _buildDateSelector(),
            if (isCalendarExpanded)
              _buildExpandedCalendar()
            else
              _buildWeekCalendar(),
            Expanded(
              child: _buildAppointmentTimeline(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: grey800,
          child: const Icon(LucideIcons.plus, color: Colors.white),
          onPressed: () {
            _showAddAppointmentDialog(context);
          },
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Year selector
          GestureDetector(
            onTap: () => _showYearPicker(context),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(
                    selectedYear.toString(),
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey.shade800,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),

          // Month selector
          GestureDetector(
            onTap: () => _showMonthPicker(context),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: black.withValues(alpha: .8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(
                    selectedMonthName,
                    style: TextStyle(
                      color: white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekCalendar() {
    // Get the start of the week (Sunday)
    final startOfWeek =
        selectedDate.subtract(Duration(days: selectedDate.weekday % 7));
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return GestureDetector(
      onTap: () {
        setState(() {
          isCalendarExpanded = !isCalendarExpanded;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                return Text(
                  days[index],
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final day = startOfWeek.add(Duration(days: index));
                final isSelected = day.day == selectedDate.day &&
                    day.month == selectedDate.month &&
                    day.year == selectedDate.year;

                return GestureDetector(
                  onTap: () {
                    changeSelectedDate(day);
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.pink : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            // Calendar expand toggle
            GestureDetector(
              onTap: () {
                setState(() {
                  isCalendarExpanded = !isCalendarExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isCalendarExpanded ? 'Show Less' : 'Show More',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    Icon(
                      isCalendarExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.grey,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedCalendar() {
    // Calculate first day of month
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    // Calculate which day of week the 1st falls on (0 = Sunday, 1 = Monday, etc.)
    final firstWeekdayOfMonth = firstDayOfMonth.weekday % 7;
    // Calculate days in month
    final daysInMonth =
        DateTime(selectedDate.year, selectedDate.month + 1, 0).day;

    // Calculate number of weeks to show (including partial weeks)
    final weeksToShow = ((daysInMonth + firstWeekdayOfMonth) / 7).ceil();

    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Days of week header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((day) => SizedBox(
                      width: 30,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),

          // Calendar grid
          ...List.generate(weeksToShow, (weekIndex) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (dayIndex) {
                  final dayNumber =
                      weekIndex * 7 + dayIndex + 1 - firstWeekdayOfMonth;

                  // Check if this position has a day number in this month
                  final isValidDay = dayNumber > 0 && dayNumber <= daysInMonth;

                  // Create date for this position if valid
                  final currentDate = isValidDay
                      ? DateTime(
                          selectedDate.year, selectedDate.month, dayNumber)
                      : null;

                  // Check if this date is selected
                  final isSelected = currentDate != null &&
                      currentDate.day == selectedDate.day &&
                      currentDate.month == selectedDate.month &&
                      currentDate.year == selectedDate.year;

                  return SizedBox(
                    width: 30,
                    height: 30,
                    child: isValidDay
                        ? GestureDetector(
                            onTap: () {
                              if (currentDate != null) {
                                changeSelectedDate(currentDate);
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.pink
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '$dayNumber',
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : null,
                  );
                }),
              ),
            );
          }),

          // Calendar expand/collapse toggle
          GestureDetector(
            onTap: () {
              setState(() {
                isCalendarExpanded = !isCalendarExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isCalendarExpanded ? 'Show Less' : 'Show More',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  Icon(
                    isCalendarExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentTimeline() {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No appointments for this day',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Appointment'),
              onPressed: () => _showAddAppointmentDialog(context),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        final isFirstItem = index == 0;
        final isLastItem = index == appointments.length - 1;
        final isLoading = loadingAppointments[appointment['id']] ?? false;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time column
            SizedBox(
              width: 80,
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  appointment['startTime'],
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            // Timeline and appointment details
            Expanded(
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    // Timeline - New design
                    SizedBox(
                      width: 30,
                      child: Column(
                        children: [
                          // Line before the dot
                          if (!isFirstItem)
                            Container(
                              width: 2,
                              height: 20,
                              // Change line color to a gradient
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.grey.shade300,
                                    black.withValues(alpha: .8),
                                    appointment['color'].withOpacity(0.6),
                                  ],
                                ),
                              ),
                            ),
                          // Dot - Make it tappable to toggle status with new design
                          // - only if not already marked as done
                          GestureDetector(
                            onTap: appointment['isDone']
                                ? null
                                : () =>
                                    toggleAppointmentStatus(appointment['id']),
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: appointment['isDone']
                                    ? Colors.white
                                    : grey200,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: grey800,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: grey200.withOpacity(0.3),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: isLoading
                                  ? SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          grey800,
                                        ),
                                      ),
                                    )
                                  : appointment['isDone']
                                      ? Icon(Icons.check,
                                          size: 16,
                                          color: black.withValues(alpha: .8))
                                      : Container(
                                          margin: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            color: appointment['color'],
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                            ),
                          ),
                          // Line after the dot
                          if (!isLastItem)
                            Expanded(
                              child: Container(
                                width: 2,
                                // Change line color to a gradient
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      appointment['color'].withOpacity(0.6),
                                      isLastItem
                                          ? Colors.grey.shade300
                                          : black.withValues(alpha: .8),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Appointment details with new design
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.pushNamed('appointmentDetails',
                            extra: appointment),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            // White background if inactive, black if active
                            color: appointment['isDone']
                                ? black.withValues(alpha: .8)
                                : white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: white,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      appointment['title'],
                                      style: TextStyle(
                                        // Text color based on background - white for black background, dark for white background
                                        color: appointment['isDone']
                                            ? white
                                            : grey800,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color:
                                          appointment['isDone'] ? white : black,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: appointment['color']
                                            .withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      appointment['isDone']
                                          ? 'Completed'
                                          : 'Pending',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: appointment['isDone']
                                            ? black.withValues(alpha: .8)
                                            : white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                LucideIcons.mapPin,
                                appointment['location'],
                                appointment['isDone'],
                              ),
                              const SizedBox(height: 6),
                              _buildInfoRow(
                                LucideIcons.calendar,
                                appointment['date'],
                                appointment['isDone'],
                              ),
                              const SizedBox(height: 6),
                              _buildInfoRow(
                                LucideIcons.clock,
                                '${appointment['startTime']} - ${appointment['endTime']}',
                                appointment['isDone'],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

// Updated info row with improved styling
  Widget _buildInfoRow(IconData icon, String text, bool isDone) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: isDone ? white : grey800,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isDone ? white : grey800,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Dialog functions
  void _showYearPicker(BuildContext context) {
    final currentYear = DateTime.now().year;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Year'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: 10, // Show 10 years
              itemBuilder: (context, index) {
                final year =
                    currentYear - 5 + index; // 5 years back, 4 years forward
                final isSelected = year == selectedDate.year;

                return ListTile(
                  title: Text(
                    year.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.indigo : null,
                    ),
                  ),
                  onTap: () {
                    // Create a new date with the selected year but keep month and day
                    final newDate = DateTime(
                        year,
                        selectedDate.month,
                        // Adjust day if needed (e.g., if Feb 29 in leap year changes to non-leap year)
                        min(selectedDate.day,
                            DateTime(year, selectedDate.month + 1, 0).day));

                    setState(() {
                      selectedDate = newDate;
                      updateAppointmentsForSelectedDate();
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showMonthPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Month'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: months.length,
              itemBuilder: (context, index) {
                final isSelected = index + 1 == selectedDate.month;
                return ListTile(
                  title: Text(
                    months[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.indigo : null,
                    ),
                  ),
                  onTap: () {
                    // Adjust for months with fewer days (e.g., February)
                    int day = selectedDate.day;
                    final daysInSelectedMonth =
                        DateTime(selectedDate.year, index + 2, 0).day;
                    if (day > daysInSelectedMonth) {
                      day = daysInSelectedMonth;
                    }

                    setState(() {
                      selectedDate =
                          DateTime(selectedDate.year, index + 1, day);
                      updateAppointmentsForSelectedDate();
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showAddAppointmentDialog(BuildContext context) {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    final startTimeController = TextEditingController(text: '09:00 AM');
    final endTimeController = TextEditingController(text: '10:00 AM');
    Color selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Add Appointment',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        labelStyle: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      style: const TextStyle(fontSize: 16),
                      onChanged: (value) {
                        setState(() {
                          // Update the title in the editing appointment
                          if (editingAppointment != null) {
                            editingAppointment!['title'] = value;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        labelStyle: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      style: const TextStyle(fontSize: 16),
                      onChanged: (value) {
                        setState(() {
                          if (editingAppointment != null) {
                            editingAppointment!['location'] = value;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _showTimePicker(
                              context,
                              startTimeController,
                              (newTime) {
                                setState(() {
                                  startTimeController.text = newTime;
                                  if (editingAppointment != null) {
                                    editingAppointment!['startTime'] = newTime;
                                  }
                                });
                              },
                            ),
                            child: AbsorbPointer(
                              child: TextField(
                                controller: startTimeController,
                                decoration: const InputDecoration(
                                  labelText: 'Start Time',
                                  labelStyle: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                  suffixIcon: Icon(Icons.access_time),
                                ),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _showTimePicker(
                              context,
                              endTimeController,
                              (newTime) {
                                setState(() {
                                  endTimeController.text = newTime;
                                  if (editingAppointment != null) {
                                    editingAppointment!['endTime'] = newTime;
                                  }
                                });
                              },
                            ),
                            child: AbsorbPointer(
                              child: TextField(
                                controller: endTimeController,
                                decoration: const InputDecoration(
                                  labelText: 'End Time',
                                  labelStyle: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                  suffixIcon: Icon(Icons.access_time),
                                ),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Choose Color',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        Colors.blue,
                        Colors.red,
                        Colors.green,
                        Colors.amber,
                        Colors.indigo,
                        Colors.pink,
                        Colors.orange,
                        Colors.purple,
                      ].map((color) {
                        final isSelected = selectedColor == color;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColor = color;
                              if (editingAppointment != null) {
                                editingAppointment!['color'] = color;
                              }
                            });
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(color: Colors.black, width: 2)
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: grey800,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // Validate inputs
                    if (titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a title'),
                        ),
                      );
                      return;
                    }

                    if (locationController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a location'),
                        ),
                      );
                      return;
                    }

                    // Format date
                    final formattedDate =
                        DateFormat('MMMM d, yyyy').format(selectedDate);

                    if (editingAppointment != null) {
                      // Update existing appointment
                      final index = appointments.indexWhere(
                          (a) => a['id'] == editingAppointment!['id']);
                      if (index != -1) {
                        setState(() {
                          appointments[index] = editingAppointment!;
                        });
                      }
                    } else {
                      // Create new appointment
                      setState(() {
                        appointments.add({
                          'id':
                              DateTime.now().millisecondsSinceEpoch.toString(),
                          'title': titleController.text,
                          'location': locationController.text,
                          'date': formattedDate,
                          'startTime': startTimeController.text,
                          'endTime': endTimeController.text,
                          'color': selectedColor,
                          'isDone': false,
                        });
                      });
                    }

                    Navigator.pop(context);
                  },
                  child: Text(
                    editingAppointment != null ? 'Update' : 'Add',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      // Reset editing appointment
      editingAppointment = null;
    });
  }

  void _showTimePicker(
    BuildContext context,
    TextEditingController controller,
    Function(String) onTimeSelected,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: grey800,
            ),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
      final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
      final formattedTime =
          '${hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')} $period';

      onTimeSelected(formattedTime);
    }
  }
}
