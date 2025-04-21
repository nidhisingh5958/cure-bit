import 'package:flutter/material.dart';

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
                          '$reviews reviews',
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
