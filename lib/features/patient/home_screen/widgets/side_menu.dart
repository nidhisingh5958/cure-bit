import 'package:CuraDocs/common/components/colors.dart';
import 'package:CuraDocs/utils/providers/user_provider.dart';
import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:CuraDocs/utils/providers/auth_controllers.dart';
import 'package:CuraDocs/utils/providers/auth_providers.dart';

class SideMenu extends ConsumerStatefulWidget {
  const SideMenu({super.key});

  @override
  ConsumerState<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends ConsumerState<SideMenu> {
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

      await logOutController.logout(
          context, ref.read(authStateProvider.notifier));

      context.pushReplacementNamed(RouteConstants.login);

      context.goNamed(RouteConstants.login);
    } catch (e) {
      print('Login error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 30),
          _buildHeader(),
          _line(),
          _buildProfileOptions(context),
          _line(),
          _buildSettingsSection(context),
          _line(),
          _buildLanguageAndHelpSection(context),
          _line(),
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
        color: black,
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
            backgroundColor: grey600,
            backgroundImage: AssetImage('assets/images/profile_pic.jpeg'),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$name",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "$email",
                style: TextStyle(
                  fontSize: 14,
                  color: grey600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptions(BuildContext context) {
    return Column(
      children: [
        _buildOptionItem(
          icon: Icons.person_outline,
          label: 'Share your profile',
          onTap: () {
            Navigator.pop(context); // Close drawer first
            context.goNamed(RouteConstants.qrCode);
          },
        ),
        _buildOptionItem(
          icon: Icons.qr_code_scanner_outlined,
          label: 'Scan QR',
          onTap: () {
            Navigator.pop(context); // Close drawer first
            context.goNamed(RouteConstants.qrScan);
          },
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
          onTap: () {
            Navigator.pop(context); // Close drawer first
            context.goNamed(RouteConstants.profileSettings);
          },
        ),
        // _buildOptionItem(
        //   icon: Icons.insights_outlined,
        //   label: 'Your Activity',
        //   onTap: () {
        //     Navigator.pop(context); // Close drawer first
        //     if (context.canPop()) {
        //       context
        //           .goNamed(RouteConstants.profile, extra: {'fromDrawer': true});
        //     }
        //   },
        // ),
        // _buildOptionItem(
        //   icon: Icons.brightness_6_outlined,
        //   label: 'Switch Appearance',
        //   onTap: () {
        //     Navigator.pop(context); // Close drawer first
        //     // Handle theme switching
        //   },
        // ),
        _buildOptionItem(
          icon: Icons.report_problem_outlined,
          label: 'Report a problem',
          onTap: () {
            Navigator.pop(context); // Close drawer first
            context.goNamed(RouteConstants.reportProblem);
          },
        ),
        // _buildOptionItem(
        //   icon: Icons.privacy_tip_outlined,
        //   label: 'Feedback',
        //   onTap: () {
        //     Navigator.pop(context); // Close drawer first
        //     if (context.canPop()) {
        //       context.goNamed(RouteConstants.feedback);
        //     }
        //   },
        // ),
      ],
    );
  }

  Widget _buildLanguageAndHelpSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   "Language",
          //   style: TextStyle(
          //     fontSize: 16,
          //     color: black,
          //     fontWeight: FontWeight.normal,
          //   ),
          // ),
          // SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              Navigator.pop(context); // Close drawer first
              context.goNamed(RouteConstants.helpAndSupport);
            },
            child: Text(
              "Help & Support",
              style: TextStyle(
                fontSize: 16,
                color: black,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () async {
              Navigator.pop(context); // Close drawer first
              final Uri url = Uri.parse('https://www.curadocs.in/about');
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              } else {
                throw 'Could not launch $url';
              }
            },
            child: Text(
              "About Cura Docs",
              style: TextStyle(
                fontSize: 16,
                color: black,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              Navigator.pop(context); // Close drawer first
              context.goNamed(RouteConstants.contactUs);
            },
            child: Text(
              "Contact Us",
              style: TextStyle(
                fontSize: 16,
                color: black,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // InkWell(
          //   onTap: () {
          //     Navigator.pop(context); // Close drawer first
          //     // Implement switch account feature
          //   },
          //   child: Text(
          //     "Switch accounts",
          //     style: TextStyle(
          //       fontSize: 16,
          //       color: black,
          //       fontWeight: FontWeight.normal,
          //     ),
          //   ),
          // ),
          // SizedBox(height: 16),
          InkWell(
            onTap: () {
              _handleLogOut();
            },
            child: Text(
              "Log Out",
              style: TextStyle(
                fontSize: 16,
                color: black,
                fontWeight: FontWeight.normal,
              ),
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
        color: black,
        size: 22,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: black,
          fontSize: 16,
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
