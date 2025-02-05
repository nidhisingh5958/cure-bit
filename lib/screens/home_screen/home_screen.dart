import 'package:CuraDocs/components/routes/route_constants.dart';
import 'package:CuraDocs/screens/home_screen/widgets/side_menu.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 250, 250, 250),
        actions: [
          _buildActionButtons(context),
        ],
      ),
      drawer: Drawer(
        child: SideMenu(),
      ),
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
          const SizedBox(height: 18),
          _TopDoctorSection(),
          const SizedBox(height: 32),
          _buildFeaturesSection(context),
          const SizedBox(height: 32),
          _buildUpcomingSection(context),
        ],
      ),
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
          Icons.chat_bubble_outline,
          RouteConstants.chat,
          hasNotification: true,
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
            icon: Icon(icon, color: Theme.of(context).colorScheme.primary),
            onPressed: () => context.goNamed(route),
            style: IconButton.styleFrom(
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
                    color: Theme.of(context).scaffoldBackgroundColor,
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
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            backgroundImage: AssetImage('assets/images/profile_pic.jpeg'),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hello',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
            ],
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
        'route': 'prescriptions',
      },
      {
        'icon': Icons.calendar_today_outlined,
        'label': 'Appointment',
        'route': 'appointments',
      },
      {
        'icon': Icons.science_outlined,
        'label': 'Test Records',
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
        _buildSectionHeader(context, 'Quick Access', onSeeAll: () {}),
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
            Icon(icon, color: Colors.blue, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.blue,
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
        _buildSectionHeader(context, 'Upcoming Appointments', onSeeAll: () {}),
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
          style: const TextStyle(
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
                color: Colors.grey.withOpacity(0.1),
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
                            style: const TextStyle(
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
                          color: Colors.grey.shade600,
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
                    color: Colors.grey.shade400,
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

class _TopDoctorSection extends StatefulWidget {
  const _TopDoctorSection({Key? key}) : super(key: key);

  @override
  __TopDoctorSectionState createState() => __TopDoctorSectionState();
}

class __TopDoctorSectionState extends State<_TopDoctorSection> {
  final List<Map<String, dynamic>> doctors = [
    {
      'id': 1,
      'icon': Icons.favorite_outline,
      'doctorName': 'Dr. Jean Grey',
      'specialisation': 'Cardiologist',
      'rating': '4.8',
      'route': RouteConstants.doctorProfile,
    },
    {
      'id': 2,
      'icon': Icons.medical_services_outlined,
      'doctorName': 'Dr. Hema',
      'specialisation': 'General Practitioner',
      'rating': '4.5',
      'route': RouteConstants.doctorProfile,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Doctors',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          CarouselSlider.builder(
            itemCount: doctors.length,
            itemBuilder: (context, index, realIndex) {
              final doctor = doctors[index];
              return _buildTopDoctorCard(context, doctor);
            },
            options: CarouselOptions(
              height: 160,
              viewportFraction: 1.0,
              enableInfiniteScroll: true,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 5),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              scrollDirection: Axis.horizontal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopDoctorCard(
      BuildContext context, Map<String, dynamic> doctor) {
    return InkWell(
      onTap: () => context.goNamed(doctor['route']),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                doctor['icon'],
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    doctor['doctorName'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor['specialisation'],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    doctor['rating'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
