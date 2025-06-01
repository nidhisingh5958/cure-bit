import 'package:CureBit/app/user/user_helper.dart';
import 'package:CureBit/common/components/app_header.dart';
import 'package:CureBit/features/patient/home_screen/widgets/side_menu.dart';
import 'package:CureBit/utils/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:CureBit/common/components/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String cin = '';
  String name = '';
  bool _medicineModeReminder = true;
  bool _manuallyAddReminders = true;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      // Safe to access ref here
      cin = UserHelper.getUserAttribute<String>(ref, 'cin') ?? '';
      name = UserHelper.getUserAttribute<String>(ref, 'name') ?? '';
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Alternative: You can also get the values here in build method
    // final currentCin = UserHelper.getUserAttribute<String>(ref, 'cin') ?? '';
    // final currentName = UserHelper.getUserAttribute<String>(ref, 'name') ?? '';

    return Scaffold(
      backgroundColor: grey200,
      appBar: AppHeader(
        title: 'Profile and settings',
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
        centerTitle: true,
      ),
      drawer: const SideMenu(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // User Profile Header
            Column(
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 10),
                _buildProfileHeaderTitle(name: name, cin: cin),
              ],
            ),
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: white,
                borderRadius: BorderRadius.all(Radius.circular(25)),
                boxShadow: [
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
                      // Show dialog or navigate to medicine settings
                      _showMedicineReminderSettings();
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

                  const SizedBox(height: 70),
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
            child: const Icon(Icons.person, size: 50, color: Colors.black54),
          ),
          // edit button in profile picture
          Positioned(
            bottom: -5,
            child: CircleAvatar(
              radius: 15,
              backgroundColor: white,
              child: IconButton(
                icon: const Icon(Icons.edit),
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
            style: const TextStyle(
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
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            margin: const EdgeInsets.only(top: 5),
            child: Text(
              cin,
              style: const TextStyle(
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
        style: const TextStyle(
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
        style: const TextStyle(fontSize: 14),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: black.withValues(alpha: .8),
    );
  }

  void _showMedicineReminderSettings() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Medicine Reminder Settings'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text('Medicine Reminder'),
                    value: _medicineModeReminder,
                    onChanged: (bool value) {
                      setDialogState(() {
                        _medicineModeReminder = value;
                      });
                      setState(() {
                        _medicineModeReminder = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Manually add reminders'),
                    value: _manuallyAddReminders,
                    onChanged: (bool value) {
                      setDialogState(() {
                        _manuallyAddReminders = value;
                      });
                      setState(() {
                        _manuallyAddReminders = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
