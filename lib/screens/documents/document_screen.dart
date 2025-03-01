import 'package:CuraDocs/components/colors.dart';
import 'package:flutter/material.dart';
import 'package:CuraDocs/screens/documents/prescription.dart';
import 'package:CuraDocs/screens/documents/timeline.dart';
import 'package:CuraDocs/screens/documents/test_records.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Sample timeline data
  final List<TimelineRecord> timelineData = [
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
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Records'),
        leading: IconButton(
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
          icon: Icon(Icons.menu, color: color2),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              size: 24,
              color: color2,
            ),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Timeline'),
            Tab(text: 'Prescriptions'),
            Tab(text: 'Test Reports'),
          ],
          indicator: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: color6, width: 2),
            ),
          ),
          splashBorderRadius: BorderRadius.circular(38),
          unselectedLabelColor: color3,
          indicatorColor: color3,
          dividerColor: color5,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          TimelineScreen(
            timelineData: timelineData,
          ),
          PrescriptionScreen(prescriptionData: prescriptionData),
          TestRecordsScreen(testRecordData: testRecordData),
        ],
      ),
    );
  }
}
