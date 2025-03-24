import 'package:CuraDocs/components/colors.dart';
import 'package:CuraDocs/components/menu_pop_up.dart';
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
        appBar: AppBar(
          elevation: 0,
          title: Text('Doctor Profile'),
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              context.goNamed('home');
            },
          ),
        ),
        // backgroundColor: Color(0xFFF5F8FB),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileHeader(context),
                      SizedBox(height: 4),
                      _buildActionButtons(),
                      SizedBox(height: 24),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color3,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildInfoSection(),
                            _buildWorkingHours(),
                            _buildLocationSection(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: Colors.grey[200],
              child: Icon(
                Icons.person,
                size: 40,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr Sarah Johnson',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Cardiologist',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 18),
                      SizedBox(width: 5),
                      Text(
                        '5.0',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.message_outlined),
                label: Text('Message'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  if (!isConnected) {
                    // Only show animation when connecting, not disconnecting
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
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isConnected ? color2 : color3,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  foregroundColor:
                      isConnected ? Theme.of(context).primaryColor : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated icon
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
                    // Animated text
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
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 12),
            PopupMenuHelper.buildPopupMenu(
              context,
              onSelected: (value) {
                if (value == 'book') {
                  // Handle book appointment action
                  context.goNamed(RouteConstants.bookAppointment);
                } else if (value == 'doctorQR') {
                  // Handle help action
                  context.goNamed(RouteConstants.help);
                }
              },
              optionsList: [
                {'book': 'Book an appointment'},
                {'doctorQR': 'Doctor\'s QR'},
              ],
            ),
          ],
        ),
        // Celebration animation overlay
        if (showConnectionAnimation)
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Positioned(
                top: 0,
                bottom: 0,
                left: MediaQuery.of(context).size.width / 2 - 50,
                child: Opacity(
                  opacity: _scaleAnimation.value > 0.1 ? 1.0 : 0.0,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: Theme.of(context).primaryColor,
                        size: 50,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          _buildInfoRow('Specialisation', 'Cardiologist'),
          SizedBox(height: 8),
          _buildInfoRow('Qualification', 'MBBS, MD'),
          SizedBox(height: 8),
          _buildInfoRow('Location', 'Chandni Chowk, Delhi'),
          SizedBox(height: 8),
          _buildInfoRow('Years of experience', '8'),
          SizedBox(height: 8),
          _buildInfoRow('Patients attended', '2.4K +'),
          SizedBox(height: 8),
        ],
      ),
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
            color: color3,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkingHours() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Working Hours',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          _buildWorkingRow('Mon-Fri', '08:00-14:00'),
          SizedBox(height: 8),
          _buildWorkingRow('Sat-Sun', '09:00-13:00'),
        ],
      ),
    );
  }

  Widget _buildWorkingRow(String days, String hours) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          days,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        Text(
          hours,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Location',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
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
      ),
    );
  }

  Widget _buildLocationCard(String time, String address) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            time,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            address,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
