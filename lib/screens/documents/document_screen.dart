import 'package:flutter/material.dart';

import 'package:CuraDocs/screens/documents/prescription.dart';
import 'package:CuraDocs/screens/documents/timeline.dart';
import 'package:CuraDocs/screens/documents/test_records.dart';

final Color color1 = Colors.black;
final Color color2 = Colors.black.withOpacity(0.8);
final Color color3 = Colors.grey.shade600;
final Color color4 = Colors.grey.shade300;
final Color color5 = Colors.transparent;

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

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
          unselectedLabelColor: color3,
          indicatorColor: color3,
          dividerColor: color5,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          TimelineScreen(timelineData: timelineData),
          PrescriptionScreen(prescriptionData: prescriptionData),
          TestRecordsScreen(testRecordData: testRecordData),
        ],
      ),
    );
  }
}
