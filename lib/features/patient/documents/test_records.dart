import 'package:CuraDocs/components/colors.dart';
import 'package:CuraDocs/features/patient/documents/components/search.dart';
import 'package:flutter/material.dart';

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
        SearchWithFilter(),

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
                    color: black.withValues(alpha: .8),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'Test',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: black.withValues(alpha: .8),
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
