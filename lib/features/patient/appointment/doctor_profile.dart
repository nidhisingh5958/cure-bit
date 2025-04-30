import 'package:CuraDocs/components/colors.dart';
import 'package:CuraDocs/components/app_header.dart'; // Import the header component
import 'package:CuraDocs/components/pop_up.dart';
import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class DoctorProfile extends StatefulWidget {
  const DoctorProfile({super.key});

  @override
  State<DoctorProfile> createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile>
    with TickerProviderStateMixin {
  bool isConnected = false;
  bool showConnectionAnimation = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 40,
      ),
    ]).animate(_animationController);

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          showConnectionAnimation = false;
        });
        _animationController.reset();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: blueish,
        // Using the consistent header component
        appBar: AppHeader(
          title: 'Doctor Profile',
          onBackPressed: () => context.goNamed('home'),
        ),
        body: SingleChildScrollView(
          // physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildProfileHeader(context),
              SizedBox(height: 10),
              _buildInfoCard(context),
              SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 1,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Profile image with shadow and border
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: black.withValues(alpha: .1),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: white,
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: grey200,
                  child: Icon(
                    Icons.person,
                    size: 55,
                    color: grey400,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            // Doctor name and details
            Text(
              'Dr. Sarah Johnson',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
            SizedBox(height: 6),
            Text(
              'Cardiologist',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            // Rating display with improved styling
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: .15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 20),
                  SizedBox(width: 5),
                  Text(
                    '5.0',
                    style: TextStyle(
                      color: Colors.amber[800],
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    ' (124 reviews)',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.message_outlined),
            label: Text('Message'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withValues(alpha: .1),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (!isConnected) {
                setState(() {
                  showConnectionAnimation = true;
                  isConnected = true;
                });
                _animationController.forward();
              } else {
                setState(() {
                  isConnected = false;
                });
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: isConnected
                  ? Colors.white
                  : Theme.of(context).colorScheme.primary,
              backgroundColor: isConnected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.primary.withValues(alpha: .1),
              elevation: isConnected ? 2 : 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(vertical: 14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: child,
                    );
                  },
                  child: Icon(
                    isConnected ? Icons.check : MdiIcons.vectorLink,
                    key: ValueKey<bool>(isConnected),
                  ),
                ),
                SizedBox(width: 8),
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: Text(
                    isConnected ? 'Connected' : 'Connect',
                    key: ValueKey<bool>(isConnected),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        PopupMenuHelper.buildPopupMenu(
          context,
          onSelected: (value) {
            if (value == 'book') {
              context.goNamed(RouteConstants.bookAppointment);
            } else if (value == 'doctorQR') {
              context.goNamed(RouteConstants.help);
            }
          },
          optionsList: [
            {'book': 'Book an appointment'},
            {'doctorQR': 'Doctor\'s QR'},
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: white,
          borderRadius: const BorderRadius.all(Radius.circular(25)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildSectionWithIcon(
              context,
              'Information',
              Icons.info_outline,
              _buildInfoSection(),
            ),
            Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
            _buildSectionWithIcon(
              context,
              'Working Hours',
              Icons.access_time,
              _buildWorkingHours(),
            ),
            Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
            _buildSectionWithIcon(
              context,
              'Location',
              Icons.location_on_outlined,
              _buildLocationSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionWithIcon(
    BuildContext context,
    String title,
    IconData icon,
    Widget content,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      children: [
        _buildInfoRow('Specialisation', 'Cardiologist'),
        SizedBox(height: 12),
        _buildInfoRow('Qualification', 'MBBS, MD'),
        SizedBox(height: 12),
        _buildInfoRow('Location', 'Chandni Chowk, Delhi'),
        SizedBox(height: 12),
        _buildInfoRow('Years of experience', '8'),
        SizedBox(height: 12),
        _buildInfoRow('Patients attended', '2.4K +'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkingHours() {
    return Column(
      children: [
        _buildWorkingRow('Mon-Fri', '08:00-14:00'),
        SizedBox(height: 12),
        _buildWorkingRow('Sat-Sun', '09:00-13:00'),
      ],
    );
  }

  Widget _buildWorkingRow(String days, String hours) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                days,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
        Text(
          hours,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLocationCard(
          '09:00 am - 02:00 pm',
          'Medanta Hospital, Plot 45, Main road, Sector 12, Gurgaon',
        ),
        SizedBox(height: 16),
        _buildLocationCard(
          '03:00 pm - 08:00 pm',
          'Medanta Hospital, Plot 45, Main road, Sector 12, Gurgaon',
        ),
      ],
    );
  }

  Widget _buildLocationCard(String time, String address) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              SizedBox(width: 6),
              Text(
                time,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  address,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
