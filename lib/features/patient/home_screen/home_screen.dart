import 'package:CuraDocs/app/user/user_helper.dart';
import 'package:CuraDocs/common/components/app_header.dart';
import 'package:CuraDocs/common/components/colors.dart';
import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:CuraDocs/features/patient/home_screen/widgets/side_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late String name;

  @override
  void initState() {
    name = UserHelper.getUserAttribute<String>(ref, 'cin') ?? '';
    super.initState();
    // Initialize any necessary data or state here
  }

  @override
  Widget build(BuildContext context) {
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
            centerTitle: true,
            foregroundColor: black,
            searchBar: _buildSearchBar(context),
            elevation: 0,
            actions: [
              _buildNotificationButton(
                  context,
                  Icons.notifications_none_outlined,
                  RouteConstants.notifications,
                  hasNotification: true),
            ],
          ),
        ),
      ),
      drawer: const Drawer(
        child: SideMenu(),
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
                _buildWelcomeSection(),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Quick access',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildFeaturesGrid(context, isSmallScreen),
                            // const SizedBox(height: 32),
                            const SizedBox(height: 20),
                            _buildBentoGrid(context, isSmallScreen),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBentoGrid(BuildContext context, bool isSmallScreen) {
    final horizontalSpacing = isSmallScreen ? 8.0 : 12.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Health Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // First row - health stats and medication card
        // For small screens, stack vertically instead of horizontally
        isSmallScreen
            ? Column(
                children: [
                  // _buildHealthStatsCard(isSmallScreen),
                  // SizedBox(height: horizontalSpacing),
                  _buildMedicationCard(isSmallScreen),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Health stats card (1/3 width)
                  // Expanded(
                  //   flex: 2, // Reduced width compared to medication card
                  //   child: _buildHealthStatsCard(isSmallScreen),
                  // ),
                  // SizedBox(width: horizontalSpacing),
                  // Medication card (2/3 width)
                  Expanded(
                    flex: 3, // Increased width compared to health stats card
                    child: _buildMedicationCard(isSmallScreen),
                  ),
                ],
              ),

        SizedBox(height: horizontalSpacing),

        // Second row - latest medical record card (full width)
        _buildLatestRecordCard(isSmallScreen),

        SizedBox(height: horizontalSpacing),

        // Third row - upcoming appointments from the overview grid (full width)
        _buildUpcomingAppointmentsList(isSmallScreen),

        SizedBox(height: horizontalSpacing),

        // Fourth row - medical records grid
        _buildMedicalRecordsGrid(isSmallScreen),
      ],
    );
  }

  Widget _buildHealthStatsCard(bool isSmallScreen) {
    // Adjust height for small screens
    final cardHeight = isSmallScreen ? 180.0 : 200.0;
    final iconSize = isSmallScreen ? 14.0 : 16.0;
    final padding = isSmallScreen ? 12.0 : 16.0;

    return Container(
      height: cardHeight,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: grey100,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Stats',
            style: TextStyle(
              color: grey800,
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(flex: 1),
          _buildStatItem(Icons.favorite, 'Heart Rate', '78 bpm',
              Colors.red.shade400, iconSize, isSmallScreen),
          const Spacer(flex: 1),
          _buildStatItem(Icons.local_fire_department, 'Blood Pressure',
              '120/80', Colors.orange, iconSize, isSmallScreen),
          const Spacer(flex: 1),
          _buildStatItem(Icons.bedtime, 'Sleep', '7.5 hrs', Colors.indigo,
              iconSize, isSmallScreen),
          const Spacer(flex: 1),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color,
      double iconSize, bool isSmallScreen) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: iconSize,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: grey600,
                  fontSize: isSmallScreen ? 10 : 12,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: grey800,
                  fontSize: isSmallScreen ? 12 : 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationCard(bool isSmallScreen) {
    // Adjust height for small screens
    final cardHeight = isSmallScreen ? 180.0 : 200.0;
    final iconSize = isSmallScreen ? 14.0 : 16.0;
    final padding = isSmallScreen ? 12.0 : 16.0;
    final fontSize = isSmallScreen ? 12.0 : 14.0;

    return Container(
      height: cardHeight,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Medication',
                style: TextStyle(
                  color: grey800,
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 4 : 6),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  MdiIcons.pill,
                  color: Colors.purple.shade800,
                  size: iconSize,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.access_time,
                      color: Colors.purple.shade800,
                      size: iconSize,
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Next',
                          style: TextStyle(
                            color: grey600,
                            fontSize: isSmallScreen ? 10 : 12,
                          ),
                        ),
                        Text(
                          'Lisinopril',
                          style: TextStyle(
                            color: grey800,
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '6:00 PM',
                    style: TextStyle(
                      color: Colors.purple.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      MdiIcons.pill,
                      color: Colors.purple.shade800,
                      size: iconSize,
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Morning',
                          style: TextStyle(
                            color: grey600,
                            fontSize: isSmallScreen ? 10 : 12,
                          ),
                        ),
                        Text(
                          'Atorvastatin',
                          style: TextStyle(
                            color: grey800,
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestRecordCard(bool isSmallScreen) {
    final padding = isSmallScreen ? 12.0 : 16.0;
    final iconSize = isSmallScreen ? 14.0 : 16.0;
    final contentPadding = isSmallScreen ? 8.0 : 12.0;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Latest Medical Record',
                style: TextStyle(
                  color: grey800,
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 4 : 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.description_outlined,
                  color: Colors.green.shade800,
                  size: iconSize,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Container(
            padding: EdgeInsets.all(contentPadding),
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Blood Test Results',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 2 : 4),
                      // For small screens, stack date and location vertically
                      isSmallScreen
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 10,
                                      color: grey600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'April 28, 2025',
                                      style: TextStyle(
                                        color: grey600,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 10,
                                      color: grey600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'City Medical Lab',
                                      style: TextStyle(
                                        color: grey600,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 12,
                                  color: grey600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'April 28, 2025',
                                  style: TextStyle(
                                    color: grey600,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Icon(
                                  Icons.location_on,
                                  size: 12,
                                  color: grey600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'City Medical Lab',
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
                  padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                    color: Colors.green.shade800,
                    size: iconSize,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointmentsList(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: grey100,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upcoming Appointments',
                style: TextStyle(
                  color: grey800,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  children: [
                    Text(
                      'See All',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Colors.blue.shade700,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildAppointmentItem(
                  'Dr. Jean Grey',
                  'Cardiologist',
                  'Today, 3:00 PM',
                  isFirst: true,
                ),
                Divider(height: 1, color: grey200),
                _buildAppointmentItem(
                  'Regular Checkup',
                  'General Practitioner',
                  'Today, 2:00 PM',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalRecordsGrid(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: grey100,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Medical Records',
                style: TextStyle(
                  color: grey800,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  children: [
                    Text(
                      'See All',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Colors.blue.shade700,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildRecordGridItem(
                  'Blood Test',
                  'April 28, 2025',
                  Icons.description_outlined,
                  Colors.blue.shade100,
                  Colors.blue.shade700,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRecordGridItem(
                  'ECG Report',
                  'April 15, 2025',
                  Icons.monitor_heart_outlined,
                  Colors.red.shade100,
                  Colors.red.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildRecordGridItem(
                  'X-Ray',
                  'March 22, 2025',
                  Icons.image,
                  Colors.amber.shade100,
                  Colors.amber.shade700,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRecordGridItem(
                  'Vaccine',
                  'Feb 10, 2025',
                  MdiIcons.needle,
                  Colors.green.shade100,
                  Colors.green.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecordGridItem(String title, String date, IconData icon,
      Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 12,
                color: grey600,
              ),
              const SizedBox(width: 4),
              Text(
                date,
                style: TextStyle(
                  color: grey600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentItem(String title, String subtitle, String time,
      {bool isFirst = false}) {
    return InkWell(
      onTap: () {},
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
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.goNamed(RouteConstants.doctorSearch);
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
                'Search doctors...',
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

  Widget _buildNotificationButton(
    BuildContext context,
    IconData icon,
    String route, {
    bool hasNotification = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      child: Stack(
        children: [
          IconButton(
            icon: Icon(icon, color: black),
            onPressed: () => context.goNamed(route),
          ),
          if (hasNotification)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
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
                  text: '$name',
                  style: TextStyle(fontWeight: FontWeight.normal, color: black),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Welcome to your health dashboard',
            style: TextStyle(
              fontSize: 16,
              color: black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesGrid(BuildContext context, bool isSmallScreen) {
    final categories = [
      {
        'icon': Icons.calendar_today,
        'label': 'Booking',
        'onTap': () {
          context.goNamed(RouteConstants.appointmentHome);
        }
      },
      {
        'icon': MdiIcons.pill,
        'label': 'Medicines',
        'onTap': () {
          context.goNamed(RouteConstants.medicineReminder);
        }
      },
      {
        'icon': MdiIcons.stethoscope,
        'label': 'My Doctors',
        'onTap': () {
          context.goNamed(RouteConstants.favouriteDoctors);
        }
      },
      {
        'icon': MdiIcons.doctor,
        'label': 'My Appointments',
        'onTap': () {
          context.goNamed(RouteConstants.bookedAppointments);
        }
      },
    ];

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.9,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Center(
          child: Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: grey200,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    category['icon'] as IconData,
                    color: black,
                    size: 24,
                  ),
                  onPressed: () {
                    (category['onTap'] as Function)();
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text(
                category['label'] as String,
                style: const TextStyle(
                  fontSize: 14,
                  color: black,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}
