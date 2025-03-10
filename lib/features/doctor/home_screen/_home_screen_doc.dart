import 'package:CuraDocs/components/colors.dart';
import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:CuraDocs/features/doctor/home_screen/widgets/_side_menu.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DoctorHomeScreen extends StatelessWidget {
  const DoctorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: color5,
        actions: [
          _buildActionButtons(context),
        ],
      ),
      drawer: Drawer(
        child: DoctorSideMenu(),
      ),
      // floatingActionButton property
      floatingActionButton: _buildChatBotFloatingButton(context),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBody(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreeting(),
          const SizedBox(height: 32),
          _buildFeaturesSection(context),
          const SizedBox(height: 32),
          _buildUpcomingSection(context),
        ],
      ),
    );
  }

  Widget _buildChatBotFloatingButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => context.goNamed(RouteConstants.doctorChatBot),
      backgroundColor: color2,
      child: Icon(Icons.chat_bubble_outline),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        _buildIconButton(
          context,
          Icons.search_outlined,
          RouteConstants.doctorPatientSearch,
          hasNotification: false,
        ),
        _buildIconButton(
          context,
          Icons.notifications_none_outlined,
          RouteConstants.doctorNotifications,
          hasNotification: true,
        ),
      ],
    );
  }

  Widget _buildIconButton(
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
            icon: Icon(icon, color: color1),
            onPressed: () => context.goNamed(route),
            style: IconButton.styleFrom(
              backgroundColor: color5,
              padding: const EdgeInsets.all(12),
            ),
          ),
          if (hasNotification)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color5,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    String name = 'Random';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Hello, ',
                style: TextStyle(
                  color: color1,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              Text(
                name,
                style: TextStyle(
                  fontSize: 30,
                  color: color1,
                  height: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Welcome to your health dashboard',
            style: TextStyle(
              fontSize: 16,
              color: color2,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    final features = [
      {
        'icon': Icons.description_outlined,
        'label': 'Prescription',
        'route': 'myPatientsPrescriptions',
      },
      {
        'icon': Icons.calendar_today_outlined,
        'label': 'Booking',
        'route': 'myPatientsAppointments',
      },
      {
        'icon': Icons.science_outlined,
        'label': 'Test Record',
        'route': 'myPatientsTestRecords',
      },
      {
        'icon': Icons.medication_outlined,
        'label': 'Medicines',
        'route': 'medicineReminder',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Quick Access'),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: features.map((feature) {
              return _buildFeatureItem(
                context,
                feature['icon'] as IconData,
                feature['label'] as String,
                onTap: () => context.goNamed(feature['route'] as String),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String label, {
    VoidCallback? onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Calculate item width based on screen width
    // Subtracting total horizontal padding (40) and spacing between items (3 * 12 = 36)
    final itemWidth = (screenWidth - 76) / 4;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: itemWidth,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          // color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          // border: Border.all(
          //   color: Colors.blue.withOpacity(0.2),
          //   width: 1,
          // ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color2, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color2,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Upcoming ', onSeeAll: () {}),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 2,
          itemBuilder: (context, index) {
            return _buildAppointmentCard(
              context,
              title: index == 0 ? 'Dr. Jean Grey' : 'Regular Checkup',
              specialty: index == 0 ? 'Cardiologist' : 'General Practitioner',
              rating: index == 0 ? '4.8' : null,
              time: 'Today, ${index == 0 ? '15:00' : '14:00'} PM',
              index: index,
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    VoidCallback? onSeeAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: color1,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
          ),
          child: Row(
            children: const [
              Text('See All'),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentCard(
    BuildContext context, {
    required String title,
    required String specialty,
    String? rating,
    required String time,
    required int index,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color1,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Doctor/Appointment Avatar
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: Theme.of(context).colorScheme.primary,
                        size: 32,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Appointment Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: color1,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Confirmed',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        specialty,
                        style: TextStyle(
                          color: color3,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildInfoChip(
                            context,
                            Icons.access_time,
                            time,
                            Colors.blue,
                          ),
                          if (rating != null) ...[
                            const SizedBox(width: 12),
                            _buildInfoChip(
                              context,
                              Icons.star,
                              rating,
                              Colors.amber,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Arrow indicator
                Container(
                  margin: const EdgeInsets.only(left: 12),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: color3,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
