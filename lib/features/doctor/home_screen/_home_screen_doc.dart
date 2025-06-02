import 'package:CureBit/services/user/user_helper.dart';
import 'package:CureBit/common/components/app_header.dart';
import 'package:CureBit/common/components/colors.dart';
import 'package:CureBit/utils/routes/route_constants.dart';
import 'package:CureBit/features/doctor/home_screen/widgets/_side_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class DoctorHomeScreen extends ConsumerStatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  ConsumerState<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends ConsumerState<DoctorHomeScreen>
    with SingleTickerProviderStateMixin {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isCalendarExpanded = false;
  late TabController _tabController;

  // Selected filter for statistics
  String _selectedStatFilter = 'Weekly';

  // Quick action state
  bool _isRecordingEnabled = false;

  // Mock appointment data - in a real app, this would come from a database
  final Map<DateTime, List<AppointmentData>> _events = {
    DateTime(2025, 5, 19): [
      AppointmentData(
          'Dhruv Gupta', 'Pain', '1:30 pm', AppointmentStatus.confirmed),
      AppointmentData(
          'Dhruvi Singh', 'Thyroid', '2:15 pm', AppointmentStatus.confirmed),
    ],
    DateTime(2025, 5, 20): [
      AppointmentData(
          'Rahul Patel', 'Follow-up', '11:00 am', AppointmentStatus.confirmed),
      AppointmentData('Simran Khanna', 'Consultation', '3:00 pm',
          AppointmentStatus.pending),
    ],
    DateTime(2025, 5, 21): [
      AppointmentData(
          'Amit Kumar', 'Headache', '10:30 am', AppointmentStatus.pending),
    ],
    DateTime(2025, 5, 23): [
      AppointmentData('Priya Sharma', 'Regular Check-up', '4:15 pm',
          AppointmentStatus.confirmed),
      AppointmentData('Neha Verma', 'Blood Test Results', '5:00 pm',
          AppointmentStatus.confirmed),
      AppointmentData(
          'Karan Singh', 'Fever', '6:30 pm', AppointmentStatus.pending),
    ],
  };

  // Mock daily task data
  final List<TaskData> _tasks = [
    TaskData('Review lab results', true),
    TaskData('Update patient records', true),
    TaskData('Conference call with specialists', false),
    TaskData('Prepare for tomorrow\'s surgery', false),
  ];

  // Mock analytics data
  final Map<String, double> _patientsByCondition = {
    'Cardiology': 35,
    'Orthopedic': 25,
    'General': 20,
    'Neurology': 10,
    'Other': 10,
  };

  // Mock patient data for "patients to follow up"
  final List<PatientData> _followUpPatients = [
    PatientData('Amit Kumar', 'Post-surgery check-up', '3 days ago'),
    PatientData('Priya Sharma', 'Blood test results', '5 days ago'),
  ];

  // Mock notifications
  final List<NotificationData> _notifications = [
    NotificationData(
        'New lab results available',
        'Check results for patient Dhruv Gupta',
        DateTime.now().subtract(const Duration(hours: 2)),
        NotificationType.results),
    NotificationData(
        'Patient rescheduled',
        'Neha Verma rescheduled to tomorrow at 3:00 PM',
        DateTime.now().subtract(const Duration(hours: 5)),
        NotificationType.schedule),
    NotificationData(
        'Emergency consultation',
        'Dr. Patel needs your opinion on a cardiology case',
        DateTime.now().subtract(const Duration(days: 1)),
        NotificationType.urgent),
  ];

  List<AppointmentData> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  // Helper function to limit displayed events to max 3
  List<AppointmentData> _getDisplayEventsForDay(DateTime day) {
    final events = _getEventsForDay(day);
    return events.take(3).toList();
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = UserHelper.getUserAttribute<String>(ref, 'name') ?? '';
    // Get screen size for responsive adjustments
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Builder(
          builder: (context) => AppHeader(
            backgroundColor: grey200,
            onMenuPressed: () {
              Scaffold.of(context).openDrawer();
            },
            searchBar: _buildSearchBar(
              context,
            ),
            centerTitle: false,
            foregroundColor: black,
            elevation: 0,
            actions: [
              _buildIconButton(
                context,
                Icons.notifications_none_outlined,
                RouteConstants.doctorNotifications,
                hasNotification: true,
              ),
            ],
          ),
        ),
      ),
      drawer: const Drawer(
        child: DoctorSideMenu(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.goNamed(RouteConstants.chatBot);
        },
        backgroundColor: black,
        child: Image.asset(
          'assets/icons/robot.png',
          height: 32,
          width: 32,
          color: white,
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              grey200.withValues(alpha: .8),
              grey200.withValues(alpha: .6),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 16),
                _buildWelcomeSection(name),
                _buildQuickActionsBar(),
                Container(
                  margin: const EdgeInsets.only(top: 24),
                  decoration: const BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 16,
                        offset: Offset(0, -8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCalendarSection(),
                        const SizedBox(height: 32),
                        _buildStatisticsTabs(),
                        const SizedBox(height: 32),
                        _buildDailyTasks(),
                        const SizedBox(height: 32),
                        _buildFollowUpSection(),
                        const SizedBox(height: 32),
                        _buildNotificationsSection(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.goNamed(RouteConstants.doctorPatientSearch);
      },
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Search patients, conditions...',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(String name) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: black,
                          height: 1.2,
                          letterSpacing: -0.5,
                        ),
                        children: [
                          TextSpan(text: 'Hello, '),
                          TextSpan(
                            text: 'Dr. $name',
                            style: TextStyle(
                                fontWeight: FontWeight.normal, color: black),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Welcome to your personal assistant',
                      style: TextStyle(
                        fontSize: 16,
                        color: black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: .5),
                    width: 2,
                  ),
                  image: const DecorationImage(
                    image: NetworkImage('https://i.pravatar.cc/150?img=11'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDashboardSummary(),
        ],
      ),
    );
  }

  Widget _buildDashboardSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: .3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            context,
            '7',
            'Appointments',
            Icons.calendar_today_outlined,
          ),
          Container(height: 40, width: 1, color: grey400),
          _buildSummaryItem(
            context,
            '3',
            'Pending',
            Icons.watch_later_outlined,
          ),
          Container(height: 40, width: 1, color: grey400),
          _buildSummaryItem(
            context,
            '4',
            'Tasks',
            Icons.check_circle_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
      BuildContext context, String count, String label, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              count,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: grey600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsBar() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildQuickAction(
            context,
            'Schedule',
            Icons.calendar_month_outlined,
            Colors.orange.shade700,
            () => context.goNamed(RouteConstants.doctorSchedule),
          ),
          _buildQuickAction(
            context,
            'Voice Notes',
            _isRecordingEnabled ? Icons.mic : Icons.mic_none_outlined,
            _isRecordingEnabled ? Colors.red : Colors.green.shade700,
            () {
              setState(() {
                _isRecordingEnabled = !_isRecordingEnabled;
              });
              // Add voice recording functionality
            },
          ),
          _buildQuickAction(
            context,
            'Prescriptions',
            Icons.medication_outlined,
            Colors.purple.shade700,
            () => context.goNamed(RouteConstants.doctorPrescription),
          ),
          _buildQuickAction(
            context,
            'Lab Results',
            Icons.science_outlined,
            Colors.blue.shade700,
            () => context.goNamed(RouteConstants.doctorLabResults),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: color.withValues(alpha: .3),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarSection() {
    final selectedDayAppointments = _getDisplayEventsForDay(_selectedDay!);
    final totalAppointmentsCount = _getEventsForDay(_selectedDay!).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.event_outlined,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Your Schedule',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: black,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () {
                    context.goNamed(RouteConstants.doctorDailySchedule);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: const Size(0, 36),
                    side: BorderSide(
                        color: Theme.of(context).colorScheme.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    _isCalendarExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: black,
                  ),
                  onPressed: () {
                    setState(() {
                      _isCalendarExpanded = !_isCalendarExpanded;
                      _calendarFormat = _isCalendarExpanded
                          ? CalendarFormat.month
                          : CalendarFormat.week;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: grey100,
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
              TableCalendar(
                firstDay: DateTime.utc(2025, 1, 1),
                lastDay: DateTime.utc(2025, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Month',
                  CalendarFormat.week: 'Week',
                },
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                    _isCalendarExpanded = format == CalendarFormat.month;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                eventLoader: _getEventsForDay,
                daysOfWeekHeight: 40,
                rowHeight: 60,
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, date, _) {
                    final eventCount = _getEventsForDay(date).length;
                    return Container(
                      margin: const EdgeInsets.all(4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${date.day}',
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          if (eventCount > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  eventCount > 3 ? 3 : eventCount,
                                  (index) => Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 1),
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                  selectedBuilder: (context, date, _) {
                    final eventCount = _getEventsForDay(date).length;
                    return Container(
                      margin: const EdgeInsets.all(4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${date.day}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (eventCount > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  eventCount > 3 ? 3 : eventCount,
                                  (index) => Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 1),
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                  todayBuilder: (context, date, _) {
                    final eventCount = _getEventsForDay(date).length;
                    return Container(
                      margin: const EdgeInsets.all(4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: .3),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (eventCount > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  eventCount > 3 ? 3 : eventCount,
                                  (index) => Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 1),
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                  dowBuilder: (context, day) {
                    return Center(
                      child: Text(
                        DateFormat.E().format(day).substring(0, 3),
                        style: TextStyle(
                          color: grey600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: black,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: black,
                  ),
                ),
              ),
              if (totalAppointmentsCount > 0) ...[
                Divider(
                  height: 1,
                  thickness: 1,
                  color: grey200,
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('EEEE, MMMM d').format(_selectedDay!),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: grey600,
                            ),
                          ),
                          if (totalAppointmentsCount > 3)
                            InkWell(
                              onTap: () {
                                // View all appointments for this day
                                context.goNamed(
                                  RouteConstants.doctorDailySchedule,
                                  queryParameters: {
                                    'date': DateFormat('yyyy-MM-dd')
                                        .format(_selectedDay!),
                                  },
                                );
                              },
                              child: Text(
                                '+${totalAppointmentsCount - 3} more',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...selectedDayAppointments.map((appointment) =>
                          _buildEnhancedCalendarAppointmentItem(appointment)),
                    ],
                  ),
                ),
              ],
              if (totalAppointmentsCount == 0) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('EEEE, MMMM d').format(_selectedDay!),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: grey600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_available,
                              color: grey600,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "No appointments scheduled for today",
                              style: TextStyle(
                                color: grey600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedCalendarAppointmentItem(AppointmentData appointment) {
    Color statusColor;
    switch (appointment.status) {
      case AppointmentStatus.confirmed:
        statusColor = Colors.green.shade700;
        break;
      case AppointmentStatus.pending:
        statusColor = Colors.orange.shade700;
        break;
      case AppointmentStatus.cancelled:
        statusColor = Colors.red.shade700;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: .1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        appointment.reason,
                        style: TextStyle(
                          color: grey600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: grey400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      appointment.time,
                      style: TextStyle(
                        color: grey600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              appointment.status.name,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsTabs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Statistics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: black,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: grey100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedStatFilter,
                  icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                  elevation: 2,
                  isDense: true,
                  items: ['Daily', 'Weekly', 'Monthly', 'Yearly']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          value,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedStatFilter = newValue!;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: grey100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: grey600,
                indicatorColor: Theme.of(context).colorScheme.primary,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(text: 'Patients'),
                  Tab(text: 'Revenue'),
                  Tab(text: 'Conditions'),
                ],
              ),
              Container(
                height: 240,
                padding: const EdgeInsets.all(16),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPatientStatisticsView(),
                    _buildRevenueStatisticsView(),
                    _buildConditionsStatisticsView(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPatientStatisticsView() {
    // This would use a charting library like fl_chart in a real app
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatCard('Total', '124', Icons.people_outline, Colors.blue),
            _buildStatCard(
                'New', '14', Icons.person_add_alt_1_outlined, Colors.green),
            _buildStatCard(
                'Returning', '110', Icons.repeat_outlined, Colors.orange),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          height: 120,
          child: Center(
            child: CustomPaint(
              size: const Size(double.infinity, 120),
              painter: LineChartPainter(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueStatisticsView() {
    // Mock revenue data visualization
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatCard('Earned', '₹124,500',
                Icons.account_balance_wallet_outlined, Colors.green),
            _buildStatCard('Pending', '₹14,200', Icons.watch_later_outlined,
                Colors.orange),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          height: 120,
          child: Center(
            child: CustomPaint(
              size: const Size(double.infinity, 120),
              painter: BarChartPainter(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConditionsStatisticsView() {
    // Mock conditions distribution with a pie chart
    return Column(
      children: [
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: Row(
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CustomPaint(
                  painter: PieChartPainter(
                    data: _patientsByCondition,
                    colors: [
                      Colors.red.shade400,
                      Colors.green.shade400,
                      Colors.blue.shade400,
                      Colors.purple.shade400,
                      Colors.orange.shade400,
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _patientsByCondition.entries
                      .map((entry) => _buildLegendItem(
                            entry.key,
                            '${entry.value.toInt()}%',
                            _patientsByCondition.keys
                                .toList()
                                .indexOf(entry.key),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, String value, int index) {
    final colors = [
      Colors.red.shade400,
      Colors.green.shade400,
      Colors.blue.shade400,
      Colors.purple.shade400,
      Colors.orange.shade400,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: colors[index % colors.length],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      width: 90,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: grey600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTasks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.task_alt,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Daily Tasks',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: black,
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: () {
                context.goNamed(RouteConstants.doctorTasks);
              },
              icon: const Icon(Icons.more_horiz, color: black),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._tasks.map((task) => _buildTaskItem(task)),
      ],
    );
  }

  Widget _buildTaskItem(TaskData task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: task.isCompleted
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: task.isCompleted
                    ? Theme.of(context).colorScheme.primary
                    : grey400,
                width: 2,
              ),
            ),
            child: task.isCompleted
                ? const Icon(
                    Icons.check,
                    size: 16,
                    color: white,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              task.task,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                decoration:
                    task.isCompleted ? TextDecoration.lineThrough : null,
                color: task.isCompleted ? grey400 : black,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              // Task edit action
            },
            icon: Icon(
              Icons.edit_outlined,
              size: 20,
              color: grey400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowUpSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notification_important_outlined,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Patients to Follow Up',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: black,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                context.goNamed(RouteConstants.doctorFollowUps);
              },
              child: Text(
                'View All',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: grey100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: _followUpPatients
                .map((patient) => _buildFollowUpItem(patient))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFollowUpItem(PatientData patient) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: .1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  patient.reason,
                  style: TextStyle(
                    color: grey600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Last Visit',
                style: TextStyle(
                  color: grey600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                patient.lastVisit,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notifications_none_outlined,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Recent Notifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: black,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                context.goNamed(RouteConstants.doctorNotifications);
              },
              child: Text(
                'See All',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._notifications
            .map((notification) => _buildNotificationItem(notification)),
      ],
    );
  }

  Widget _buildNotificationItem(NotificationData notification) {
    IconData notificationIcon;
    Color iconBackgroundColor;
    Color iconColor;

    switch (notification.type) {
      case NotificationType.results:
        notificationIcon = Icons.science_outlined;
        iconBackgroundColor = Colors.blue.shade50;
        iconColor = Colors.blue.shade700;
        break;
      case NotificationType.schedule:
        notificationIcon = Icons.event_note_outlined;
        iconBackgroundColor = Colors.purple.shade50;
        iconColor = Colors.purple.shade700;
        break;
      case NotificationType.urgent:
        notificationIcon = Icons.priority_high_outlined;
        iconBackgroundColor = Colors.red.shade50;
        iconColor = Colors.red.shade700;
        break;
      default:
        notificationIcon = Icons.notifications_none_outlined;
        iconBackgroundColor = Colors.orange.shade50;
        iconColor = Colors.orange.shade700;
    }

    final timeAgo = _getTimeAgo(notification.time);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              notificationIcon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: TextStyle(
                    color: grey600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  timeAgo,
                  style: TextStyle(
                    color: grey400,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildIconButton(
    BuildContext context,
    IconData icon,
    String routeName, {
    bool hasNotification = false,
  }) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: () {
            context.goNamed(routeName);
          },
        ),
        if (hasNotification)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: white, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}

// Custom painters for the charts
class LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.shade400
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = Colors.blue.shade700
      ..style = PaintingStyle.fill;

    final path = Path();

    // Mock data points
    final points = [
      Offset(0, size.height * 0.6),
      Offset(size.width * 0.2, size.height * 0.4),
      Offset(size.width * 0.4, size.height * 0.7),
      Offset(size.width * 0.6, size.height * 0.3),
      Offset(size.width * 0.8, size.height * 0.5),
      Offset(size.width, size.height * 0.2),
    ];

    // Draw line
    path.moveTo(points[0].dx, points[0].dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);

    // Draw dots at data points
    for (var point in points) {
      canvas.drawCircle(point, 4, dotPaint);
      canvas.drawCircle(
          point,
          6,
          Paint()
            ..color = Colors.blue.shade200
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = size.width / 8;
    final spacing = barWidth / 2;

    // Mock data for bar heights (percentage of max height)
    final data = [0.7, 0.5, 0.9, 0.6, 0.8];

    for (var i = 0; i < data.length; i++) {
      final height = size.height * data[i];
      final left = spacing + i * (barWidth + spacing);

      // Gradient for bars
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.green.shade300,
          Colors.green.shade700,
        ],
      );

      final paint = Paint()
        ..shader = gradient.createShader(
          Rect.fromLTWH(left, size.height - height, barWidth, height),
        );

      // Draw rounded bar
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, size.height - height, barWidth, height),
        const Radius.circular(4),
      );

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PieChartPainter extends CustomPainter {
  final Map<String, double> data;
  final List<Color> colors;

  PieChartPainter({required this.data, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    var startAngle = 0.0;

    final total = data.values.reduce((a, b) => a + b);

    data.entries.toList().asMap().forEach((index, entry) {
      final sweepAngle = (entry.value / total) * 2 * math.pi;

      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = colors[index % colors.length];

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    });

    // Draw white circle in middle for donut effect
    canvas.drawCircle(
      center,
      radius * 0.6,
      Paint()..color = white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Data models
enum AppointmentStatus { confirmed, pending, cancelled }

class AppointmentData {
  final String name;
  final String reason;
  final String time;
  final AppointmentStatus status;

  AppointmentData(this.name, this.reason, this.time, this.status);
}

class TaskData {
  final String task;
  final bool isCompleted;

  TaskData(this.task, this.isCompleted);
}

class PatientData {
  final String name;
  final String reason;
  final String lastVisit;

  PatientData(this.name, this.reason, this.lastVisit);
}

enum NotificationType { results, schedule, urgent }

class NotificationData {
  final String title;
  final String message;
  final DateTime time;
  final NotificationType type;

  NotificationData(this.title, this.message, this.time, this.type);
}
