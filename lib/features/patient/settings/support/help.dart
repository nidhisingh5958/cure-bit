import 'package:CuraDocs/common/components/app_header.dart';
import 'package:CuraDocs/common/components/colors.dart';
import 'package:CuraDocs/utils/routes/route_constants.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        onBackPressed: () => context.goNamed(RouteConstants.profileSettings),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
        backgroundColor: greyWithGreenTint,
        centerTitle: true,
        title: 'Help',
      ),
      backgroundColor: const Color.fromARGB(255, 235, 240, 237),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildSettingsItem(
            title: 'Report a problem',
            onTap: () {},
          ),
          _buildSettingsItem(
            title: 'Account Status',
            onTap: () {},
          ),
          _buildSettingsItem(
            title: 'Help Center',
            onTap: () {},
          ),
          _buildSettingsItem(
            title: 'Privacy and security help',
            onTap: () {},
          ),
          _buildSettingsItem(
            title: 'Support request',
            onTap: () {},
          ),

          Spacer(),

          // attention needed should be chnaged in future --------
          Center(
            child: Text(
              'Feel Free to contact our Customer support',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          Center(
            child: Text(
              'team for any queries or issues at',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Center(
            child: Text(
              'Email: support@curadocs.in',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          SizedBox(
            height: 26,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: ListTile(
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: black,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: TextStyle(
                    color: grey600,
                    fontSize: 14,
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
}
