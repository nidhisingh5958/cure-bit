import 'package:CuraDocs/common/components/colors.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

final String name = "John Doe";

class DoctorSideMenu extends StatelessWidget {
  const DoctorSideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildProfileOptions(),
                    Divider(
                        height: 1,
                        thickness: 1,
                        color: black,
                        indent: 20,
                        endIndent: 20),
                    _buildSettingsSection(context),
                    Divider(
                        height: 1,
                        thickness: 1,
                        color: black,
                        indent: 20,
                        endIndent: 20),
                    _buildLanguageAndHelpSection(),
                    _buildAboutSection(context),
                    Divider(
                        height: 1,
                        thickness: 1,
                        color: black,
                        indent: 20,
                        endIndent: 20),
                    _buildAccountsSection(context),
                  ],
                ),
              ),
            ),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 30, 16, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3F51B5), Color(0xFF303F9F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage('assets/images/profile_pic.jpeg'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dr. $name",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "user@gmail.com",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    // Handle edit profile action
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: Text(
                      "Edit Profile",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              "Profile",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: grey600,
              ),
            ),
          ),
          _buildOptionItem(
            icon: Icons.person_outline,
            label: 'Share your profile',
            trailing: Icon(Icons.share, size: 18, color: grey600),
          ),
          _buildOptionItem(
            icon: Icons.qr_code_scanner_outlined,
            label: 'Scan QR',
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: grey600),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              "Preferences",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: grey600,
              ),
            ),
          ),
          _buildOptionItem(
            icon: Icons.settings_outlined,
            label: 'Settings & Privacy',
          ),
          _buildOptionItem(
            icon: Icons.insights_outlined,
            label: 'Your Activity',
            badge: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "2",
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
          _buildOptionItem(
            icon: Icons.brightness_6_outlined,
            label: 'Switch Appearance',
            trailing: Switch(
              value: false,
              onChanged: (value) {},
              activeColor: Theme.of(context).primaryColor,
            ),
          ),
          _buildOptionItem(
            icon: Icons.report_problem_outlined,
            label: 'Report a problem',
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageAndHelpSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              "Support",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: grey600,
              ),
            ),
          ),
          _buildOptionItem(
            icon: Icons.language,
            label: 'Language',
            trailing: Row(
              children: [
                Text(
                  "English",
                  style: TextStyle(color: grey600, fontSize: 14),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, size: 16, color: grey600),
              ],
            ),
          ),
          _buildOptionItem(
            icon: Icons.help_outline,
            label: 'Help Center',
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return _buildOptionItem(
      icon: Icons.info_outline,
      label: 'About Cura Docs',
      onTap: () async {
        final Uri url = Uri.parse('https://www.curadocs.in/about.html');
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        } else {
          throw 'Could not launch $url';
        }
      },
    );
  }

  Widget _buildAccountsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              "Account",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: grey600,
              ),
            ),
          ),
          _buildOptionItem(
            icon: Icons.swap_horiz,
            label: 'Switch accounts',
            trailing: CircleAvatar(
              radius: 12,
              backgroundColor: Colors.grey[300],
              child: Text(
                "2",
                style: TextStyle(fontSize: 12, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: Icon(Icons.logout, size: 20),
        label: Text("Log Out"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFF44336),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String label,
    Widget? trailing,
    Widget? badge,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Color(0xFF3F51B5),
          size: 22,
        ),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: black,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing:
          trailing ?? Icon(Icons.arrow_forward_ios, size: 16, color: grey600),
      onTap: onTap ?? () {},
      dense: true,
      visualDensity: VisualDensity(horizontal: 0, vertical: -1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      horizontalTitleGap: 12,
      subtitle: badge != null ? SizedBox(height: 4) : null,
      titleAlignment: ListTileTitleAlignment.center,
    );
  }
}
