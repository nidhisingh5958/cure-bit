import 'package:cure_bit/components/navigation_bar.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar with Search and Notification
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.grey),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Stack(
                        children: [
                          const Icon(Icons.notifications_outlined),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 8,
                                minHeight: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Greeting Section
                const Text(
                  'Hi, Kevin',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                // Available Plans Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'The Available Plans',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Learn new up',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.run_circle_rounded,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Lessons Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Features',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('See All'),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildLessonItem(Icons.receipt, 'Prescription'),
                    _buildLessonItem(
                        Icons.calendar_view_day_rounded, 'Appointment'),
                    _buildLessonItem(Icons.science, 'Test Records'),
                    _buildLessonItem(Icons.medication, 'Medicines'),
                  ],
                ),

                const SizedBox(height: 20),

                // Live Video Section
                // const Text(
                //   'Live Video',
                //   style: TextStyle(
                //     fontSize: 18,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Upcoming',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('See All'),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Appointment Cards
                AppointmentCard(
                  doctorName: 'Jean Grey',
                  rating: 4.8,
                  reviews: 220,
                  date: '30 April',
                  time: '15:00',
                  backgroundColor: Colors.blue.shade300,
                ),
                const SizedBox(height: 10),
                AppointmentCard(
                  isScheduled: true,
                  date: '23 Mar',
                  backgroundColor: const Color.fromRGBO(66, 188, 229, 1),
                ),
                const SizedBox(height: 10),
                AppointmentCard(
                  isScheduled: true,
                  date: '23 Mar',
                  backgroundColor: const Color.fromARGB(255, 164, 115, 229),
                ),
                const SizedBox(height: 10),
                AppointmentCard(
                  isScheduled: true,
                  date: '23 Mar',
                  backgroundColor: Colors.red.shade300,
                ),
              ],
            ),
          ),
        ),
      ),

      // bottom navigation bar from components/navigation_bar.dart
      bottomNavigationBar: const BottomNavigation(),
    );
  }

  Widget _buildLessonItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 24,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final String? doctorName;
  final double? rating;
  final int? reviews;
  final String date;
  final String? time;
  final Color backgroundColor;
  final bool isScheduled;

  const AppointmentCard({
    this.doctorName,
    this.rating,
    this.reviews,
    required this.date,
    this.time,
    required this.backgroundColor,
    this.isScheduled = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isScheduled) ...[
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: backgroundColor),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctorName!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '${reviews} reviews',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.star,
                          color: Colors.yellow,
                          size: 16,
                        ),
                        Text(
                          rating.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
          ],
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: Colors.white,
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                date,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              if (time != null) ...[
                SizedBox(width: 16),
                Icon(
                  Icons.access_time,
                  color: Colors.white,
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  time!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
