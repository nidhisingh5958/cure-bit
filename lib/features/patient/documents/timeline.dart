import 'package:CuraDocs/components/colors.dart';
import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TimelineRecord {
  final DateTime date;
  final String diagnosis;
  final String doctor;

  TimelineRecord({
    required this.date,
    required this.diagnosis,
    required this.doctor,
  });
}

class TimelineScreen extends StatelessWidget {
  final List<TimelineRecord> timelineData;

  const TimelineScreen({required this.timelineData, super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data if provided list is empty
    final List<TimelineRecord> data = timelineData.isEmpty
        ? [
            TimelineRecord(
              date: DateTime(2024, 1, 15),
              diagnosis: 'Gallbladder Infection',
              doctor: 'Dr. Smith',
            ),
            TimelineRecord(
              date: DateTime(2024, 2, 20),
              diagnosis: '',
              doctor: '',
            ),
            TimelineRecord(
              date: DateTime(2025, 1, 10),
              diagnosis: 'Gallbladder Infection',
              doctor: 'Dr. Johnson',
            ),
            TimelineRecord(
              date: DateTime(2025, 2, 5),
              diagnosis: '',
              doctor: '',
            ),
            TimelineRecord(
              date: DateTime(2025, 2, 25),
              diagnosis: 'Gallbladder Infection',
              doctor: 'Dr. Williams',
            ),
          ]
        : timelineData;

    // Group timeline records by year and month
    Map<int, Map<int, List<TimelineRecord>>> groupedData = {};
    for (var record in data) {
      if (!groupedData.containsKey(record.date.year)) {
        groupedData[record.date.year] = {};
      }
      if (!groupedData[record.date.year]!.containsKey(record.date.month)) {
        groupedData[record.date.year]![record.date.month] = [];
      }
      groupedData[record.date.year]![record.date.month]!.add(record);
    }

    // Generate timeline items
    List<Widget> timelineItems = [];
    List<int> years = groupedData.keys.toList()..sort();

    for (int year in years) {
      // Add year header
      timelineItems.add(
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 16.0),
          child: Text(
            '$year',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: black,
            ),
          ),
        ),
      );

      // Add months for this year
      List<int> months = groupedData[year]!.keys.toList()..sort();
      for (int month in months) {
        // Add month header
        timelineItems.add(
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 4.0),
            child: Text(
              _getMonthName(month),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: color2,
              ),
            ),
          ),
        );

        // Add timeline for this month
        final records = groupedData[year]![month]!;
        for (int i = 0; i < records.length; i++) {
          final record = records[i];
          final isFirst = i == 0;
          final isLast = i == records.length - 1;

          timelineItems.add(
            TimelineTile(
              alignment: TimelineAlign.manual,
              lineXY: 0.15,
              isFirst: isFirst,
              isLast: isLast,
              indicatorStyle: IndicatorStyle(
                width: 20,
                height: 20,
                indicator: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: grey400,
                      width: 2,
                    ),
                  ),
                ),
                padding: const EdgeInsets.all(6),
              ),
              beforeLineStyle: LineStyle(
                color: white,
                thickness: 2,
              ),
              afterLineStyle: LineStyle(
                color: white,
                thickness: 2,
              ),
              startChild: record.diagnosis.isNotEmpty
                  ? SizedBox(
                      width: 40,
                      height: 20,
                    )
                  : null,
              endChild: record.diagnosis.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.diagnosis,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: color2,
                            ),
                          ),
                          if (record.doctor.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                record.doctor,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: grey400,
                                ),
                              ),
                            ),
                        ],
                      ),
                    )
                  : SizedBox(height: 30),
            ),
          );
        }
      }
    }

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  'Date',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color2,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Diagnosis',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color2,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Doctor',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color2,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Timeline content
        Expanded(
          child: ListView(
            children: timelineItems,
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC'
    ];
    return months[month - 1];
  }
}
