import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ReminderDetails extends StatelessWidget {
  final Map<String, dynamic> reminder;

  const ReminderDetails({super.key, required this.reminder});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Hero(
          tag: 'reminder-${reminder['task']}',
          child: Material(
            color: Colors.transparent,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 300,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 50),
                      Text(
                        reminder['task'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(LucideIcons.minus, size: 20),
                            onPressed: () {
                              // Add logic to decrease the number of pills
                            },
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            '2 pills',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: Icon(LucideIcons.plus, size: 20),
                            onPressed: () {
                              // Add logic to increase the number of pills
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        reminder['time'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () =>
                            (context).goNamed(RouteConstants.notifications),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[300],
                          minimumSize: const Size(200, 45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Remind me',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                    top: -50, // Moves it outside the card
                    left: 110,
                    child: Opacity(
                      opacity: 0.7, // transparent
                      child: reminder['icon'] == '💊'
                          // ? Icon(
                          //     LucideIcons.pill,
                          //     size: 100,
                          //     color: Colors.red[300],
                          //   )
                          ? Image.asset(
                              'assets/images/pill.png',
                              height: 170,
                              width: 170,
                            )
                          : Image.asset(
                              'assets/images/droplet.png',
                              height: 130,
                              width: 130,
                            ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
