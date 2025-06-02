// ignore_for_file: use_build_context_synchronously

import 'package:CureBit/common/components/colors.dart';
import 'package:CureBit/utils/providers/auth_controllers.dart';
import 'package:CureBit/utils/providers/auth_providers.dart';
import 'package:CureBit/utils/providers/user_provider.dart';
import 'package:CureBit/utils/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

class DoctorSideMenu extends ConsumerStatefulWidget {
  const DoctorSideMenu({super.key});

  @override
  ConsumerState<DoctorSideMenu> createState() => _DoctorSideMenuState();
}

class _DoctorSideMenuState extends ConsumerState<DoctorSideMenu> {
  late String name;
  late String email;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider);
    name = user?.name ?? '';
    email = user?.email ?? '';
  }

  Future<void> _handleLogOut() async {
    try {
      final logOutController = ref.read(logoutControllerProvider);

      final user = ref.read(userProvider);
      await logOutController.logout(
          context, ref.read(authStateProvider.notifier), user?.role ?? '');

      context.pushReplacementNamed(RouteConstants.login);

      context.goNamed(RouteConstants.login);
    } catch (e) {
      debugPrint('Login error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      elevation: 2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    children: [
                      _buildProfileOptions(context),
                      const Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0xFFEEEEEE),
                          indent: 20,
                          endIndent: 20),
                      _buildSettingsSection(context),
                      const Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0xFFEEEEEE),
                          indent: 20,
                          endIndent: 20),
                      _buildLanguageAndHelpSection(context),
                      const Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0xFFEEEEEE),
                          indent: 20,
                          endIndent: 20),
                      _buildAboutSection(context),
                      const Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0xFFEEEEEE),
                          indent: 20,
                          endIndent: 20),
                      // _buildAccountsSection(context),
                      _buildLogoutButton(),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 30, 16, 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 142, 148, 184),
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
                  "$email",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: .8),
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
                      color: Colors.white.withValues(alpha: .2),
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

  Widget _buildProfileOptions(context) {
    return Container(
      color: Colors.white,
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
                color: Colors.black87,
              ),
            ),
          ),
          _buildOptionItem(
            icon: Icons.person_outline,
            label: 'Share your profile',
            trailing: const Icon(Icons.share, size: 18, color: Colors.black54),
          ),
          _buildOptionItem(
              icon: Icons.qr_code_scanner_outlined,
              label: 'Scan QR',
              trailing: const Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.black54),
              onTap: () {
                context.goNamed(RouteConstants.qrScan);
              }),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              "Preferences",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          _buildOptionItem(
            icon: Icons.settings_outlined,
            label: 'Settings & Privacy',
            onTap: () {
              // context.goNamed(RouteConstants.settings);
            },
          ),
          // _buildOptionItem(
          //   icon: Icons.insights_outlined,
          //   label: 'Your Activity',
          //   badge: Container(
          //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          //     decoration: BoxDecoration(
          //       color: Colors.red,
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //     child: const Text(
          //       "2",
          //       style: TextStyle(color: Colors.white, fontSize: 12),
          //     ),
          //   ),
          // ),
          // _buildOptionItem(
          //   icon: Icons.brightness_6_outlined,
          //   label: 'Switch Appearance',
          //   trailing: Switch(
          //     value: false,
          //     onChanged: (value) {},
          //     activeColor: Theme.of(context).primaryColor,
          //   ),
          // ),
          _buildOptionItem(
            icon: Icons.report_problem_outlined,
            label: 'Report a problem',
            onTap: () {
              context.goNamed(RouteConstants.reportProblem);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageAndHelpSection(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              "Support",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          // _buildOptionItem(
          //   icon: Icons.language,
          //   label: 'Language',
          //   trailing: Row(
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       const Text(
          //         "English",
          //         style: TextStyle(color: Colors.black54, fontSize: 14),
          //       ),
          //       const SizedBox(width: 4),
          //       const Icon(Icons.arrow_forward_ios,
          //           size: 16, color: Colors.black54),
          //     ],
          //   ),
          // ),
          _buildOptionItem(
            icon: Icons.help_outline,
            label: 'Help Center',
            onTap: () {
              context.goNamed(RouteConstants.helpAndSupport);
            },
          ),
          _buildOptionItem(
            icon: Icons.privacy_tip_outlined,
            label: 'Contact Us',
            onTap: () {
              context.goNamed(RouteConstants.contactUs);
            },
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
        final Uri url = Uri.parse('https://www.CureBit.in/about.html');
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        } else {
          throw 'Could not launch $url';
        }
      },
    );
  }

  Widget _buildAccountsSection(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              "Account",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          _buildOptionItem(
            icon: Icons.swap_horiz,
            label: 'Switch accounts',
            trailing: CircleAvatar(
              radius: 12,
              backgroundColor: Colors.grey[300],
              child: const Text(
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: Colors.white,
      child: ElevatedButton.icon(
        onPressed: () {
          _handleLogOut();
        },
        icon: const Icon(Icons.logout, size: 20),
        label: const Text("Log Out"),
        style: ElevatedButton.styleFrom(
          backgroundColor: grey800,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          elevation: 1,
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: grey800,
          size: 22,
        ),
      ),
      title: Text(
        label,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing ??
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
      onTap: onTap ?? () {},
      tileColor: Colors.white,
      dense: true,
      visualDensity: const VisualDensity(horizontal: 0, vertical: -1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      horizontalTitleGap: 12,
      subtitle: badge != null ? const SizedBox(height: 4) : null,
    );
  }
}
