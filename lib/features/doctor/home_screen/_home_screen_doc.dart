import 'package:CuraDocs/common/components/app_header.dart';
import 'package:CuraDocs/common/components/colors.dart';
import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:CuraDocs/features/doctor/home_screen/widgets/_side_menu.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DoctorHomeScreen extends StatelessWidget {
  const DoctorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive adjustments
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Builder(
          builder: (context) => AppHeader(
            backgroundColor: grey200,
            onMenuPressed: () {
              Scaffold.of(context).openDrawer();
            },
            centerTitle: false,
            foregroundColor: black,
            elevation: 0,
            actions: [
              _buildIconButton(
                context,
                Icons.search_outlined,
                RouteConstants.doctorPatientSearch,
                hasNotification: false,
              ),
              _buildIconButton(
                context,
                Icons.notifications_none_outlined,
                RouteConstants.doctorNotifications,
                hasNotification: true,
              ),
            ],
          ),
        ),
      ),
      drawer: const Drawer(
        child: DoctorSideMenu(),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              grey200.withValues(alpha: .8),
              grey200.withValues(alpha: .6),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 16),
                _buildWelcomeSection(),
                Container(
                  margin: const EdgeInsets.only(top: 24),
                  decoration: const BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 16,
                        offset: Offset(0, -8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPatientsAttendedSection(),
                        const SizedBox(height: 32),
                        _buildUpcomingSection(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: black,
                height: 1.2,
                letterSpacing: -0.5,
              ),
              children: [
                TextSpan(text: 'Hello, '),
                TextSpan(
                  text: 'Dr. Sahil',
                  style: TextStyle(fontWeight: FontWeight.normal, color: black),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Welcome to your personal assistant',
            style: TextStyle(
              fontSize: 16,
              color: black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientsAttendedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Patients attended',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: black,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: grey100,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '148',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: black,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: ChartPainter(),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('1 Oct', style: TextStyle(color: grey600, fontSize: 12)),
                  Text('8 Oct', style: TextStyle(color: grey600, fontSize: 12)),
                  Text('15 Oct',
                      style: TextStyle(color: grey600, fontSize: 12)),
                  Text('22 Oct',
                      style: TextStyle(color: grey600, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String label, {
    required VoidCallback onTap,
    required bool isSmallScreen,
  }) {
    return Column(
      children: [
        Container(
          width: isSmallScreen ? 60 : 70,
          height: isSmallScreen ? 60 : 70,
          decoration: BoxDecoration(
            color: grey200,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              icon,
              color: black,
              size: 28,
            ),
            onPressed: onTap,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: black,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildUpcomingSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Upcoming',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: black,
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(50, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                children: [
                  Text(
                    'See All',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildAppointmentItem(
          context,
          name: 'Dhruv Gupta',
          condition: 'Pain',
          time: 'wed 1:30 pm',
        ),
        const SizedBox(height: 16),
        _buildAppointmentItem(
          context,
          name: 'Dhruvi Singh',
          condition: 'Thyroid',
          time: 'wed 2:15 pm',
        ),
      ],
    );
  }

  Widget _buildAppointmentItem(
    BuildContext context, {
    required String name,
    required String condition,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: grey200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline,
              color: grey800,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  condition,
                  style: TextStyle(
                    color: grey600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              time,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(
    BuildContext context,
    IconData icon,
    String route, {
    bool hasNotification = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      child: Stack(
        children: [
          IconButton(
            icon: Icon(icon, color: black),
            onPressed: () => context.goNamed(route),
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              padding: const EdgeInsets.all(12),
            ),
          ),
          if (hasNotification)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Paint for the grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1;

    // Paint for the chart line
    final linePaint = Paint()
      ..color = Colors.blue.shade500
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Draw horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Define data points for the wavy line (similar to the image)
    final points = [
      Offset(0, size.height * 0.6), // Starting point
      Offset(size.width * 0.15, size.height * 0.3), // Rise
      Offset(size.width * 0.3, size.height * 0.45), // Fall
      Offset(size.width * 0.45, size.height * 0.65), // Fall more
      Offset(size.width * 0.6, size.height * 0.5), // Rise a bit
      Offset(size.width * 0.75, size.height * 0.2), // Rise to peak
      Offset(size.width * 0.9, size.height * 0.3), // Slight fall
      Offset(size.width, size.height * 0.25), // End point
    ];

    // Create a path for the line
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 1; i < points.length; i++) {
      // Use quadratic bezier curves for smooth lines
      final controlPointX = (points[i - 1].dx + points[i].dx) / 2;
      path.quadraticBezierTo(
        controlPointX,
        points[i - 1].dy,
        points[i].dx,
        points[i].dy,
      );
    }

    // Draw the path
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
