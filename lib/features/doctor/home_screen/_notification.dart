import 'package:CuraDocs/components/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DoctorNotificationScreen extends StatelessWidget {
  const DoctorNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: white,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'Notifications',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '5 new notifications',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Colors.black87,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Today',
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _NotificationCard(
                  notification: _demoNotifications[index],
                );
              },
              childCount: _demoNotifications.length,
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationItem {
  final String title;
  final String message;
  final DateTime time;
  final NotificationType type;
  final bool isRead;

  NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
  });
}

enum NotificationType { appointment, medication, reminder, report, system }

extension NotificationTypeExtension on NotificationType {
  IconData get icon {
    switch (this) {
      case NotificationType.appointment:
        return Icons.calendar_today_rounded;
      case NotificationType.medication:
        return Icons.medication_rounded;
      case NotificationType.reminder:
        return Icons.notifications_active_rounded;
      case NotificationType.report:
        return Icons.description_rounded;
      case NotificationType.system:
        return Icons.system_update_rounded;
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.appointment:
        return Colors.blue;
      case NotificationType.medication:
        return Colors.green;
      case NotificationType.reminder:
        return Colors.orange;
      case NotificationType.report:
        return Colors.purple;
      case NotificationType.system:
        return Colors.grey;
    }
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationItem notification;

  const _NotificationCard({
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: notification.type.color.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    notification.type.icon,
                    color: notification.type.color,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            _formatTime(notification.time),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: notification.isRead
                                ? Colors.transparent
                                : notification.type.color,
                          ),
                          Spacer(),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              minimumSize: Size(0, 32),
                            ),
                            child: Text('View'),
                          ),
                        ],
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

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (time.day == now.day) {
      return DateFormat('HH:mm').format(time);
    } else {
      return DateFormat('MMM d, HH:mm').format(time);
    }
  }
}

// Demo data
final List<NotificationItem> _demoNotifications = [
  NotificationItem(
    title: 'Upcoming Appointment',
    message:
        'You have a doctor\'s appointment with Dr. Smith tomorrow at 10:00 AM.',
    time: DateTime.now().subtract(Duration(minutes: 5)),
    type: NotificationType.appointment,
  ),
  NotificationItem(
    title: 'Medication Reminder',
    message:
        'Time to take your evening medication. Don\'t forget to follow the prescribed dosage.',
    time: DateTime.now().subtract(Duration(hours: 1)),
    type: NotificationType.medication,
    isRead: true,
  ),
  NotificationItem(
    title: 'Lab Results Available',
    message:
        'Your recent lab test results are now available. Click to view the detailed report.',
    time: DateTime.now().subtract(Duration(hours: 3)),
    type: NotificationType.report,
  ),
  NotificationItem(
    title: 'Health Check Reminder',
    message:
        'It\'s time for your weekly health check. Please update your symptoms and vitals.',
    time: DateTime.now().subtract(Duration(hours: 5)),
    type: NotificationType.reminder,
    isRead: true,
  ),
  NotificationItem(
    title: 'System Update',
    message: 'We\'ve updated our privacy policy. Please review the changes.',
    time: DateTime.now().subtract(Duration(days: 1)),
    type: NotificationType.system,
    isRead: true,
  ),
];
