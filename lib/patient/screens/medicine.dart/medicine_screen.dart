import 'package:CuraDocs/screens/medicine.dart/widgets/custom_rect_tween.dart';
import 'package:CuraDocs/components/status_bar_color.dart';
import 'package:CuraDocs/screens/medicine.dart/widgets/hero_dialog_route.dart';
import 'package:CuraDocs/screens/medicine.dart/reminder_details.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ReminderScreen extends StatelessWidget {
  ReminderScreen({super.key});

  final Color _backgroundColor = Color.fromARGB(255, 252, 243, 226);

  @override
  Widget build(BuildContext context) {
    setStatusBarColor(_backgroundColor);
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        title: Text('Reminder', style: TextStyle(fontSize: 18)),
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: Colors.black),
          onPressed: () => GoRouter.of(context).go('/home'),
        ),
        actions: [
          Icon(Icons.notifications_none, color: Colors.black),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          _buildDateSection(),
          const SizedBox(height: 24),
          ReminderList(),
        ],
      ),
    );
  }
}

Widget _buildDateSection() {
  final now = DateTime.now();
  final months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  final days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  String formattedDate = '${months[now.month - 1]} ${now.day}th';
  String dayName = days[now.weekday - 1];

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formattedDate,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            Text(
              dayName,
              style: TextStyle(color: Colors.grey[600], fontSize: 22),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => print('Add reminder'),
          child: Icon(
            LucideIcons.plus,
            color: Colors.black,
            size: 28,
            semanticLabel: 'Add reminder',
          ),
        ),
      ],
    ),
  );
}

class ReminderList extends StatefulWidget {
  const ReminderList({super.key});

  @override
  State<ReminderList> createState() => _ReminderListState();
}

class _ReminderListState extends State<ReminderList> {
  final List<Map<String, dynamic>> reminders = [
    {
      'time': '8am',
      'task': 'Vitamin C',
      'icon': '💊',
      'completed': true,
    },
    {
      'time': '9am',
      'task': 'Maxgrip',
      'icon': '💊',
      'completed': false,
    },
    {
      'time': '2pm',
      'task': 'Wash your hands',
      'icon': '💧',
      'completed': true,
    },
    {
      'time': '3pm',
      'task': 'Wash your hands',
      'icon': '💧',
      'completed': false
    },
  ];

  void toggleComplete(int index) {
    setState(() {
      reminders[index]['completed'] = !(reminders[index]['completed'] as bool);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              const SizedBox(height: 24),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      HeroDialogRoute(
                        builder: (context) => Center(
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text('Reminder Details'),
                          ),
                        ),
                      ),
                    );
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: reminders.length,
                    itemBuilder: (context, index) {
                      final reminder = reminders[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            HeroDialogRoute(
                              builder: (context) =>
                                  ReminderDetails(reminder: reminder),
                            ),
                          );
                        },
                        child: _buildReminderItem(reminder, index),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReminderItem(Map<String, dynamic> reminder, int index) {
    return Hero(
      tag: 'reminder-${reminder['task']}',
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 48,
                child: Text(
                  reminder['time']! as String,
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ),
              const SizedBox(width: 8),
              Text(reminder['icon']! as String,
                  style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder['task']! as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'min 20 sec',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => toggleComplete(index),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: reminder['completed']! as bool
                          ? Colors.teal
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                    color: reminder['completed']! as bool
                        ? Colors.teal
                        : Colors.transparent,
                  ),
                  child: reminder['completed']! as bool
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
