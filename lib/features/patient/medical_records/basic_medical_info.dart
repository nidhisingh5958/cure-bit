import 'package:CureBit/common/components/app_header.dart';
import 'package:CureBit/common/components/colors.dart';
import 'package:CureBit/utils/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BasicMedicalInfo extends StatefulWidget {
  const BasicMedicalInfo({super.key});

  @override
  State<BasicMedicalInfo> createState() => _BasicMedicalInfoState();
}

class _BasicMedicalInfoState extends State<BasicMedicalInfo> {
  @override
  Widget build(BuildContext context) {
    // Get screen size information
    final Size screenSize = MediaQuery.of(context).size;
    final double profileImageSize =
        screenSize.width * 0.25; // 25% of screen width

    return Scaffold(
      appBar: AppHeader(
        onBackPressed: () {
          Navigator.pop(context);
        },
        title: 'Account Details',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_outlined),
            onPressed: () {
              context.pushNamed(RouteConstants.editProfile);
            },
          ),
        ],
      ),
      backgroundColor: greyWithGreenTint,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header with Image
            _buildProfileHeader(profileImageSize),

            // Information Section
            _buildInformationSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(double imageSize) {
    return Container(
      width: double.infinity,
      color: white,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile Image
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: imageSize,
                width: imageSize,
                decoration: BoxDecoration(
                  color: white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3.0), // Border padding
                  child: CircleAvatar(
                    backgroundImage:
                        const AssetImage('assets/images/BasicMedicalInfo.png'),
                    backgroundColor: grey200,
                    radius: imageSize / 2,
                  ),
                ),
              ),
              // Edit Icon
              Positioned(
                bottom: 0,
                right: imageSize * 0.3,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: grey600,
                    shape: BoxShape.circle,
                    border: Border.all(color: white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: white,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // BasicMedicalInfoname handle
          const Text(
            '@livysheleina',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 4),

          // Name
          const Text(
            'Livy Sheleina',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          // Location and Join date
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'New York',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: grey400,
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                'Joined August 2023',
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

  Widget _buildInformationSection() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Website
          _buildInfoItem(
            icon: Icons.language,
            label: 'Date of Birth',
            value: 'January 1, 1990',
            description: 'Age: 35 yrs 4 months',
          ),

          const _ProfileDivider(),

          // Email
          _buildInfoItem(
            icon: Icons.mail,
            label: 'Email',
            value: 'sh.agency@gmail.com',
          ),

          const _ProfileDivider(),

          // Phone
          _buildInfoItem(
            icon: Icons.phone,
            label: 'Phone',
            value: '+62 878 XXX XXX',
            description: 'Mobile',
          ),

          const _ProfileDivider(),

          // Joined
          _buildInfoItem(
            icon: Icons.calendar_today,
            label: 'Joined',
            value: 'August 2023',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    String? description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: grey600),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (description != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    description,
                    style: TextStyle(fontSize: 14, color: grey600),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Skills grid
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildSkillChip('Design System'),
              _buildSkillChip('UI Designer'),
              _buildSkillChip('UX Researcher'),
              _buildSkillChip('Product Manager'),
            ],
          ),

          const SizedBox(height: 20),

          _buildEditButton(),
        ],
      ),
    );
  }

  Widget _buildSkillChip(String label) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
        ),
      ),
      backgroundColor: grey200,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildEditButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          debugPrint('Edit Profile');
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
          backgroundColor: white,
          foregroundColor: Colors.black87,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit, size: 20),
            SizedBox(width: 8),
            Text(
              'Edit Profile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileDivider extends StatelessWidget {
  const _ProfileDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      color: Colors.black12,
      thickness: 1,
      indent: 20,
      endIndent: 20,
    );
  }
}
