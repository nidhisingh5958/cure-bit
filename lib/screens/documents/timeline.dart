import 'package:CuraDocs/screens/documents/components/timelinetile.dart';
import 'package:flutter/material.dart';

final Color color1 = Colors.black;
final Color color2 = Colors.black.withOpacity(0.8);
final Color color3 = Colors.grey.shade600;

class Timeline {
  final String date;
  final String month;
  final String year;
  final String diagnosis;
  final String doctor;

  Timeline({
    required this.date,
    required this.month,
    required this.year,
    required this.diagnosis,
    required this.doctor,
  });
}

class TimelineScreen extends StatelessWidget {
  final List<Timeline> timelineData;

  const TimelineScreen({required this.timelineData, super.key});

  @override
  Widget build(BuildContext context) {
    // Group timeline data by year
    Map<String, List<Timeline>> groupedByYear = {};
    for (var item in timelineData) {
      if (!groupedByYear.containsKey(item.year)) {
        groupedByYear[item.year] = [];
      }
      groupedByYear[item.year]!.add(item);
    }

    // Convert to sorted list of years and their items
    List<MapEntry<String, List<Timeline>>> sortedYears = groupedByYear.entries
        .toList()
      ..sort(
          (a, b) => b.key.compareTo(a.key)); // Sort years in descending order

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: const [
                Expanded(
                  flex: 1,
                  child: Text('Date',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Diagnosis',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex: 1,
                  child: Text('Doctor',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          for (var yearEntry in sortedYears)
            _buildYearSection(yearEntry.key, yearEntry.value),
        ],
      ),
    );
  }

  Widget _buildYearSection(String year, List<Timeline> items) {
    // Sort items within a year by month (assuming month is a string like "JAN", "FEB")
    List<Timeline> sortedItems = List.from(items);
    const monthOrder = {
      "JAN": 1,
      "FEB": 2,
      "MAR": 3,
      "APR": 4,
      "MAY": 5,
      "JUN": 6,
      "JUL": 7,
      "AUG": 8,
      "SEP": 9,
      "OCT": 10,
      "NOV": 11,
      "DEC": 12
    };

    sortedItems.sort((a, b) {
      int monthA = monthOrder[a.month] ?? 0;
      int monthB = monthOrder[b.month] ?? 0;
      return monthA.compareTo(monthB);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 16.0),
          child: Text(
            year,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        for (int i = 0; i < sortedItems.length; i++)
          _buildMonthSection(
              sortedItems[i], i == 0, i == sortedItems.length - 1)
      ],
    );
  }

  Widget _buildMonthSection(Timeline item, bool isFirst, bool isLast) {
    Widget eventContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.diagnosis,
          style: TextStyle(
            color: color1,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.month,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: MyTimelineTile(
            isFirst: isFirst,
            isLast: isLast,
            isPast: true,
            eventCard: eventContent,
          ),
        ),
      ],
    );
  }
}

// Sample timeline data
final List<Timeline> timelineData = [
  Timeline(
    date: '15',
    month: 'JAN',
    year: '2024',
    diagnosis: 'Gallbladder Infection',
    doctor: 'Dr. Smith',
  ),
  Timeline(
    date: '28',
    month: 'FEB',
    year: '2024',
    diagnosis: 'Gallbladder Infection',
    doctor: 'Dr. Smith',
  ),
  Timeline(
    date: '10',
    month: 'JAN',
    year: '2025',
    diagnosis: 'Gallbladder Infection',
    doctor: 'Dr. Johnson',
  ),
  Timeline(
    date: '22',
    month: 'FEB',
    year: '2025',
    diagnosis: 'Gallbladder Infection',
    doctor: 'Dr. Williams',
  ),
];
