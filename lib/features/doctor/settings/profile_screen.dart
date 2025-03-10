import 'package:CuraDocs/features/patient/home_screen/widgets/side_menu.dart';
import 'package:flutter/material.dart';
import 'package:CuraDocs/components/colors.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = '';
  String cin = '';
  bool _medicineModeReminder = true;
  bool _manuallyAddReminders = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        title: Text('Profile'),
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                  _buildProfileHeaderTitle(
                      name: 'John Doe', cin: 'CIN: 345AS34'),
                ],
              ),
            ),
            SizedBox(height: 30),
            // Profile Sections
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                child: Container(
                  color: color4,
                  height: MediaQuery.of(context).size.height - 250,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 16,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Account Section
                          _buildProfileSection(
                            title: 'Account',
                            items: [
                              _buildProfileItem(
                                title: 'Personal Information',
                                onTap: () {},
                              ),
                              _buildProfileItem(
                                title: 'Country',
                                onTap: () {},
                              ),
                            ],
                          ),
                          // General Section
                          _buildProfileSection(
                            title: 'General',
                            items: [
                              _buildProfileItem(
                                title: 'Notifications',
                                onTap: () {},
                              ),
                              _buildProfileItem(
                                title: 'Display',
                                onTap: () {
                                  _buildSwitchProfileItem(
                                    title: 'Medicine Reminder',
                                    value: _medicineModeReminder,
                                    onChanged: (bool value) {
                                      setState(() {
                                        _medicineModeReminder = value;
                                      });
                                    },
                                  );
                                  _buildSwitchProfileItem(
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
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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
              backgroundColor: color4,
              child: Icon(Icons.edit, size: 16, color: color1),
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
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            cin,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color1,
            ),
          ),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildProfileItem({
    required String title,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontSize: 16, color: color2),
      ),
      trailing: Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSwitchProfileItem({
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
      activeColor: color2,
    );
  }
}
