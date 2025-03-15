import 'package:CuraDocs/components/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorSideMenu extends StatelessWidget {
  const DoctorSideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(),
          _line(),
          _buildProfileOptions(),
          _line(),
          _buildSettingsSection(context),
          _line(),
          _buildLanguageAndHelpSection(),
          _buildAboutSection(context),
          _line(),
          _buildAccountsSection(context),
        ],
      ),
    );
  }

  Widget _line() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
      child: Container(
        height: 1,
        color: color1,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color3,
            backgroundImage: AssetImage('assets/images/profile_pic.jpeg'),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Dr. User",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "user@gmail.com",
                style: TextStyle(
                  fontSize: 14,
                  color: color3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptions() {
    return Column(
      children: [
        _buildOptionItem(
          icon: Icons.person_outline,
          label: 'Share your profile',
        ),
        _buildOptionItem(
          icon: Icons.qr_code_scanner_outlined,
          label: 'Scan QR',
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Column(
      children: [
        _buildOptionItem(
          icon: Icons.settings_outlined,
          label: 'Settings & Privacy',
        ),
        _buildOptionItem(
          icon: Icons.insights_outlined,
          label: 'Your Activity',
        ),
        _buildOptionItem(
          icon: Icons.brightness_6_outlined,
          label: 'Switch Appearance',
        ),
        _buildOptionItem(
          icon: Icons.report_problem_outlined,
          label: 'Report a problem',
        ),
      ],
    );
  }

  Widget _buildLanguageAndHelpSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Language",
            style: TextStyle(
              fontSize: 14,
              color: color1,
              fontWeight: FontWeight.normal,
            ),
          ),
          SizedBox(height: 16),
          Text(
            "Help",
            style: TextStyle(
              fontSize: 14,
              color: color1,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () async {
          final Uri url = Uri.parse('https://www.curadocs.in/about.html');
          if (await canLaunchUrl(url)) {
            await launchUrl(url);
          } else {
            throw 'Could not launch $url';
          }
        },
        child: Text(
          "About Cura Docs",
          style: TextStyle(
            fontSize: 14,
            color: color1,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildAccountsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Switch accounts",
            style: TextStyle(
              fontSize: 14,
              color: color1,
              fontWeight: FontWeight.normal,
            ),
          ),
          SizedBox(height: 16),
          Text(
            "Log Out",
            style: TextStyle(
              fontSize: 14,
              color: color1,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color1,
        size: 22,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: color1,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
      ),
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      horizontalTitleGap: 10,
    );
  }
}
