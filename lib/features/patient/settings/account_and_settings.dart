import 'package:CuraDocs/app/user/user_helper.dart';
import 'package:CuraDocs/common/components/app_header.dart';
import 'package:CuraDocs/features/patient/home_screen/widgets/side_menu.dart';
import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:CuraDocs/common/components/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late String cin;
  late String name;
  bool _medicineModeReminder = true;
  bool _manuallyAddReminders = true;

  @override
  void initState() {
    cin = UserHelper.getUserAttribute<String>(ref, 'cin') ?? '';
    name = UserHelper.getUserAttribute<String>(ref, 'name') ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grey200,
      appBar: AppHeader(
        title: 'Profile and settings',
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
        centerTitle: true,
      ),
      drawer: SideMenu(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            // User Profile Header
            Container(
              child: Column(
                children: [
                  _buildProfileHeader(),
                  SizedBox(height: 10),
                  _buildProfileHeaderTitle(name: name, cin: cin),
                ],
              ),
            ),
            SizedBox(height: 20),

            Container(
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
                  _buildSectionHeader('Your account'),
                  _buildSettingsItem(
                    icon: Icons.account_circle,
                    title: 'Account information',
                    onTap: () {
                      context.goNamed(RouteConstants.personalProfile);
                    },
                  ),
                  _buildSettingsItem(
                      icon: LucideIcons.user,
                      title: 'Public Profile',
                      onTap: () {
                        context.goNamed(RouteConstants.publicProfile);
                      }),
                  _buildSettingsItem(
                    icon: Icons.lock,
                    title: 'Security and login',
                    onTap: () {
                      context.goNamed(RouteConstants.securitySettings);
                    },
                  ),
                  _buildSettingsItem(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    onTap: () {
                      context.goNamed(RouteConstants.notifications);
                    },
                  ),

                  // account activity
                  _buildSectionHeader('Your activity'),
                  _buildSettingsItem(
                    icon: Icons.history,
                    title: 'Activity log',
                    onTap: () {
                      context.goNamed(RouteConstants.notifications);
                    },
                  ),
                  _buildSettingsItem(
                    icon: Icons.favorite,
                    title: 'Favorites',
                    onTap: () {
                      context.goNamed(RouteConstants.notifications);
                    },
                  ),
                  _buildSettingsItem(
                    icon: Icons.reviews,
                    title: 'Your reviews',
                    onTap: () {
                      context.goNamed(RouteConstants.notifications);
                    },
                  ),
                  _buildSettingsItem(
                    icon: Icons.medication_liquid,
                    title: 'Medicine Remainder',
                    onTap: () {
                      _buildSwitchItem(
                        title: 'Medicine Reminder',
                        value: _medicineModeReminder,
                        onChanged: (bool value) {
                          setState(() {
                            _medicineModeReminder = value;
                          });
                        },
                      );
                      _buildSwitchItem(
                        title: 'Manually add reminders',
                        value: _manuallyAddReminders,
                        onChanged: (bool value) {
                          setState(() {
                            _manuallyAddReminders = value;
                          });
                        },
                      );
                    },
                  ),

                  // app settings
                  _buildSectionHeader('Your app and media'),
                  _buildSettingsItem(
                    icon: Icons.smartphone,
                    title: 'Device permissions',
                    onTap: () {},
                  ),
                  _buildSettingsItem(
                    icon: Icons.download,
                    title: 'Archiving and downloading',
                    onTap: () {},
                  ),
                  _buildSettingsItem(
                    icon: Icons.accessibility,
                    title: 'Accessibility and translations',
                    onTap: () {},
                  ),
                  _buildSettingsItem(
                    icon: Icons.language,
                    title: 'Language',
                    onTap: () {},
                  ),
                  _buildSettingsItem(
                    icon: Icons.data_usage,
                    title: 'Data usage and media quality',
                    onTap: () {},
                  ),
                  _buildSettingsItem(
                    icon: Icons.web,
                    title: 'App website permissions',
                    onTap: () {},
                  ),
                  _buildSettingsItem(
                    icon: Icons.science,
                    title: 'Early access to features',
                    onTap: () {},
                  ),

                  // family settings
                  _buildSectionHeader('For families'),
                  _buildSettingsItem(
                    icon: Icons.home,
                    title: 'Family Center',
                    onTap: () {},
                  ),

                  // login settings
                  // _buildSectionHeader('Login'),
                  // _buildAdditionalSettings('Add account', Colors.blue),

                  SizedBox(height: 70),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey.shade300,
            child: Icon(Icons.person, size: 50, color: Colors.black54),
          ),
          // edit button in profile picture
          Positioned(
            bottom: -5,
            child: CircleAvatar(
              radius: 15,
              backgroundColor: white,
              child: IconButton(
                icon: Icon(Icons.edit),
                iconSize: 16,
                color: black,
                onPressed: () {
                  context.goNamed(RouteConstants.editProfile);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // user name and CIN
  Widget _buildProfileHeaderTitle({required String name, required String cin}) {
    return Center(
      child: Column(
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            margin: EdgeInsets.only(top: 5),
            child: Text(
              cin,
              style: TextStyle(
                fontSize: 14,
                color: black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: ListTile(
          leading: Icon(
            icon,
            color: grey600,
            size: 28,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: grey600,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: TextStyle(
                    color: grey200,
                  ),
                )
              : null,
          trailing: Icon(
            Icons.chevron_right,
            color: grey400,
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalSettings(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(fontSize: 14),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: black.withValues(alpha: .8),
    );
  }
}
