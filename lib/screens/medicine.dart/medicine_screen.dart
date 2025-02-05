import 'package:flutter/material.dart';

void main() => runApp(const MedicineReminder());

class MedicineReminder extends StatelessWidget {
  const MedicineReminder({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFF8F0),
        useMaterial3: true,
      ),
      home: const ReminderScreen(),
    );
  }
}

class ReminderScreen extends StatelessWidget {
  const ReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildDateSection(),
              const SizedBox(height: 24),
              _buildRemindersList(),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildHeader() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Icon(Icons.menu),
      const Text('Reminder', style: TextStyle(fontSize: 18)),
      const Icon(Icons.notifications_none),
    ],
  );
}

Widget _buildDateSection() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sep 14th',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            'Friday',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
      const Text('+',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w300)),
    ],
  );
}

Widget _buildRemindersList() {
  final reminders = [
    {'time': '8am', 'task': 'Vitamin C', 'icon': '💊', 'completed': true},
    {'time': '9am', 'task': 'Maxgrip', 'icon': '💊', 'completed': false},
    {'time': '2pm', 'task': 'Wash your hands', 'icon': '💧', 'completed': true},
    {
      'time': '3pm',
      'task': 'Wash your hands',
      'icon': '💧',
      'completed': false
    },
  ];

  return Expanded(
    child: ListView.builder(
      itemCount: reminders.length,
      itemBuilder: (context, index) {
        final reminder = reminders[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            children: [
              SizedBox(
                width: 48,
                child: Text(
                  reminder['time']! as String,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Text(reminder['icon']! as String,
                        style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(reminder['task']! as String),
                    const SizedBox(width: 8),
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
              Container(
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
            ],
          ),
        );
      },
    ),
  );
}
