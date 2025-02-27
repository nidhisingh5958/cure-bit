import 'package:flutter/material.dart';

final Color color1 = Colors.black;
final Color color2 = Colors.black.withOpacity(0.8);
final Color color3 = Colors.grey.shade600;

class TestRecords {
  final String date;
  final String test;

  TestRecords({
    required this.date,
    required this.test,
  });
}

class TestRecordsScreen extends StatelessWidget {
  final List<TestRecords> testRecordData;

  const TestRecordsScreen({required this.testRecordData, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search and filter bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Search bar
              GestureDetector(
                child: Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color3),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(width: 12),
                        Icon(Icons.search, color: Colors.grey),
                        SizedBox(width: 8),
                        Text(
                          "Search Medical Records",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                onTap: () => print('Search'
                    ' Medical Records'),
              ),
              const SizedBox(width: 8),
              // Filters button
              GestureDetector(
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color3),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Filters",
                        style: TextStyle(
                          color: color2,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_drop_down, size: 20),
                    ],
                  ),
                ),
                onTap: () => print('Filters'),
              ),
            ],
          ),
        ),

        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Date',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color2,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'Test',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color2,
                  ),
                ),
              ),
            ],
          ),
        ),

        // List of test records
        Expanded(
          child: ListView.builder(
            itemCount: testRecordData.length,
            itemBuilder: (context, index) {
              final record = testRecordData[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        record.date,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        record.test,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Sample test record data
final List<TestRecords> testRecordData = [
  TestRecords(
    date: '10 Feb 25',
    test: 'RBC Count',
  ),
  TestRecords(
    date: '5 Jan 25',
    test: 'Thyroid Function Tests',
  ),
  TestRecords(
    date: '22 Nov 24',
    test: 'Hemoglobin Test',
  ),
  TestRecords(
    date: '13 Feb 24',
    test: 'Lipid Panel',
  ),
];
