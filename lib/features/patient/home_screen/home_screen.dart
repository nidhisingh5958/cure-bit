import 'package:CuraDocs/components/app_header.dart';
import 'package:CuraDocs/components/colors.dart';
import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:CuraDocs/features/patient/home_screen/widgets/side_menu.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppHeader(
        onMenuPressed: () {
          Scaffold.of(context).openDrawer();
        },
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        actions: [
          _buildActionButtons(context),
        ],
      ),
      drawer: const Drawer(
        child: SideMenu(),
      ),
      floatingActionButton: _buildChatBotFloatingButton(context),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
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
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreeting(),
          const SizedBox(height: 40),
          _buildFeaturesSection(context),
          const SizedBox(height: 40),
          _buildUpcomingSection(context),
          const SizedBox(height: 32),
          _buildMedicalRecordsSection(context),
        ],
      ),
    );
  }

  Widget _buildChatBotFloatingButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => context.goNamed(RouteConstants.chatBot),
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        _buildIconButton(
          context,
          Icons.search_outlined,
          RouteConstants.doctorSearch,
          hasNotification: false,
        ),
        _buildIconButton(
          context,
          Icons.notifications_none_outlined,
          RouteConstants.notifications,
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
            icon: Icon(icon, color: Colors.black),
            onPressed: () => context.goNamed(route),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.shade100,
              padding: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
                  color: Colors.black,
                  shape: BoxShape.circle,
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
            children: const [
              Text(
                'Hello, ',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Random',
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.black,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Welcome to your health dashboard',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    // List of features
    final features = [
      {
        'icon': Icons.description_outlined,
        'label': 'Prescription',
        'route': 'prescriptions',
      },
      {
        'icon': Icons.calendar_today_outlined,
        'label': 'Booking',
        'route': 'appointmentHome',
      },
      {
        'icon': Icons.science_outlined,
        'label': 'Test Record',
        'route': 'test-records',
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
        const Text(
          'Quick Access',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
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
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Calculate item width based on screen width
    // Subtracting total horizontal padding (48) and spacing between items (3 * 12 = 36)
    final itemWidth = (screenWidth - 84) / 4;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: itemWidth,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              offset: const Offset(0, 2),
              blurRadius: 5,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black : Colors.black54,
              size: 26,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.black : Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
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
        _buildSectionHeader(context, 'Upcoming', onSeeAll: () {}),
        const SizedBox(height: 20),
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
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Row(
            children: const [
              Text(
                'See All',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
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
        elevation: 0,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
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
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: Colors.black87,
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
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Confirmed',
                              style: TextStyle(
                                color: Colors.black,
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
                          color: Colors.grey.shade700,
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
                            Colors.black,
                          ),
                          if (rating != null) ...[
                            const SizedBox(width: 12),
                            _buildInfoChip(
                              context,
                              Icons.star,
                              rating,
                              Colors.black,
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
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.black54,
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

  Widget _buildMedicalRecordsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Medical Records', onSeeAll: () {}),
        const SizedBox(height: 20),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 2,
          itemBuilder: (context, index) {
            return _buildMedicalRecordsCard(
              context,
              title: index == 0 ? 'Blood Test Results' : 'ECG Report',
              facility: index == 0 ? 'City Medical Lab' : 'Heart Institute',
              date: 'April ${index == 0 ? '28' : '15'}, 2025',
              type: index == 0 ? 'Lab Result' : 'Diagnostic',
              index: index,
            );
          },
        ),
      ],
    );
  }

  Widget _buildMedicalRecordsCard(
    BuildContext context, {
    required String title,
    required String facility,
    required String date,
    required String type,
    required int index,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        elevation: 0,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // File/Record Icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        index == 0
                            ? Icons.description_outlined
                            : Icons.monitor_heart_outlined,
                        color: Colors.black87,
                        size: 32,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Record Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              type,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        facility,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildInfoChip(
                            context,
                            Icons.calendar_today_outlined,
                            date,
                            Colors.black,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Arrow indicator
                Container(
                  margin: const EdgeInsets.only(left: 12),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.black54,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.06),
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
          const SizedBox(width: 6),
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
