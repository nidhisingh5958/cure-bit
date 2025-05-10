import 'package:CuraDocs/components/app_header.dart';
import 'package:CuraDocs/components/colors.dart';
import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DoctorSecurityAndLoginSettings extends StatelessWidget {
  const DoctorSecurityAndLoginSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        onBackPressed: () {
          Navigator.pop(context);
        },
        title: 'Security And Login Settings',
      ),
      backgroundColor: const Color.fromRGBO(244, 246, 245, 1),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              icon: Icons.lock,
              title: 'Security and login',
              onTap: () {
                context.goNamed(RouteConstants.securitySettings);
              },
            ),
          ],
        ),
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
}
