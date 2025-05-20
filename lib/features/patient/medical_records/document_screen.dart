import 'package:CuraDocs/common/components/app_header.dart';
import 'package:CuraDocs/common/components/colors.dart';
import 'package:CuraDocs/features/patient/medical_records/components/animated_fab_medicalrecords.dart';
import 'package:CuraDocs/features/patient/medical_records/data/sample.dart'
    show patientData;
import 'package:CuraDocs/features/patient/home_screen/widgets/side_menu.dart';
import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:CuraDocs/features/patient/medical_records/prescription.dart';
import 'package:CuraDocs/features/patient/medical_records/timeline.dart';
import 'package:CuraDocs/features/patient/medical_records/test_records.dart';
import 'package:go_router/go_router.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isViewingPreviousAppointments = false;

  // Sample timeline data
  // final List<TimelineRecord> timelineData = [
  //   TimelineRecord(
  //     date: DateTime(2024, 1, 15),
  //     diagnosis: 'Gallbladder Infection',
  //     doctor: 'Dr. Smith',
  //   ),
  //   TimelineRecord(
  //     date: DateTime(2024, 2, 20),
  //     diagnosis: '',
  //     doctor: '',
  //   ),
  //   TimelineRecord(
  //     date: DateTime(2025, 1, 10),
  //     diagnosis: 'Gallbladder Infection',
  //     doctor: 'Dr. Johnson',
  //   ),
  //   TimelineRecord(
  //     date: DateTime(2025, 2, 5),
  //     diagnosis: '',
  //     doctor: '',
  //   ),
  //   TimelineRecord(
  //     date: DateTime(2025, 2, 25),
  //     diagnosis: 'Gallbladder Infection',
  //     doctor: 'Dr. Williams',
  //   ),
  // ];

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
      appBar: AppHeader(
        onDetailPressed: () =>
            context.goNamed(RouteConstants.patientBasicMedicalInfo),
        title: 'Records',
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              size: 24,
              color: black.withValues(alpha: .8),
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
              bottom: BorderSide(color: grey400, width: 2),
            ),
          ),
          splashBorderRadius: BorderRadius.circular(38),
          unselectedLabelColor: grey600,
          indicatorColor: grey800,
          dividerColor: transparent,
        ),
      ),
      drawer: SideMenu(),
      floatingActionButton: !_isViewingPreviousAppointments
          ? AnimatedFloatingActionButtonRecords(
              onAddDocument: () {
                // Handle new appointment action
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Creating new appointment...')),
                );
              },
              onUploadDocument: () {
                // Handle reschedule action
                context.goNamed(RouteConstants.doctorRescheduleAppointment);
              },
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: TabBarView(
        controller: _tabController,
        children: [
          TimelinePage(
            data: [
              TimelineEntry(
                title: "Fever",
                date: '20 JAN 2024',
                content: TimelineItemContent(
                  text:
                      "Built and launched Aceternity UI and Aceternity UI Pro from scratch",
                  images: [
                    "assets/startup-1.webp",
                    "assets/startup-2.webp",
                    "assets/startup-3.webp",
                    "assets/startup-4.webp",
                  ],
                ),
              ),
              TimelineEntry(
                title: "Leg Sprain",
                date: '1 FEB 2024',
                content: TimelineItemContent(
                  text:
                      "I usually run out of copy, but when I see content this big, I try to "
                      "integrate lorem ipsum.\n"
                      "Lorem ipsum is for people who are too lazy to write copy. But we are "
                      "not. Here are some more example of beautiful designs I built.",
                  images: [
                    "assets/hero-sections.png",
                    "assets/features-section.png",
                    "assets/bento-grids.png",
                    "assets/cards.png",
                  ],
                ),
              ),
              TimelineEntry(
                title: "Changelog",
                date: '7 MAR 2025',
                content: TimelineItemContent(
                  text: "Deployed 5 new components on Aceternity today",
                  checklistItems: [
                    "Card grid component",
                    "Startup template Aceternity",
                    "Random file upload lol",
                    "Himesh Reshammiya Music CD",
                    "Salman Bhai Fan Club registrations open",
                  ],
                  images: [
                    "assets/hero-sections.png",
                    "assets/features-section.png",
                    "assets/bento-grids.png",
                    "assets/cards.png",
                  ],
                ),
              ),
            ],
          ),
          // TimelineItem(
          //   title: "2024",
          //   content: TimelineContent(
          //     textContent:
          //         "Built and launched Aceternity UI and Aceternity UI Pro from scratch",
          //     textColor: black,
          //   ),
          // ),
          // TimelineItem(
          //   title: "Early 2023",
          //   content: TimelineContent(
          //     textContent:
          //         "I usually run out of copy, but when I see content this big, I try to "
          //         "integrate lorem ipsum.\n\nLorem ipsum is for people who are too lazy to write copy. "
          //         "But we are not. Here are some more example of beautiful designs I built.",
          //     textColor: black,
          //   ),
          // ),
          // TimelineItem(
          //   title: "Changelog",
          //   content: TimelineContent(
          //     textContent: "Deployed 5 new components on Aceternity today",
          //     textColor: black,
          //     bulletPoints: [
          //       "Card grid component",
          //       "Startup template Aceternity",
          //       "Random file upload lol",
          //       "Himesh Reshammiya Music CD",
          //       "Salman Bhai Fan Club registrations open",
          //     ],
          //     bulletPointColor: grey800,
          //   ),
          // ),

          PatientManagementScreen(patientData: patientData),
          TestRecordsScreen(testRecordData: testRecordData),
        ],
      ),
    );
  }

  Widget _buildAddFloatingButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => context.goNamed(RouteConstants.addDocument),
      backgroundColor: white,
      child: Icon(Icons.add),
    );
  }
}
