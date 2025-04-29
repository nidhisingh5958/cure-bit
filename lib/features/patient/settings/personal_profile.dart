import 'package:CuraDocs/components/app_header.dart';
import 'package:CuraDocs/components/colors.dart';
import 'package:flutter/material.dart';

class PersonalProfile extends StatefulWidget {
  const PersonalProfile({super.key});

  @override
  State<PersonalProfile> createState() => _PersonalProfileState();
}

class _PersonalProfileState extends State<PersonalProfile> {
  @override
  Widget build(BuildContext context) {
    // Get screen size information
    final Size screenSize = MediaQuery.of(context).size;
    final double profileImageSize =
        screenSize.width * 0.3; // 30% of screen width

    return Scaffold(
      appBar: AppHeader(
        onBackPressed: () {
          Navigator.pop(context);
        },
        title: 'Edit Profile',
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      backgroundColor: greyWithGreenTint,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            // Profile Image Section
            _buildProfileImageSection(profileImageSize),

            // Profile Details Container
            Container(
              width: screenSize.width * 0.9, // 90% of screen width
              decoration: const BoxDecoration(
                shape: BoxShape.rectangle,
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
              margin: const EdgeInsets.all(20),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  _ProfileInfoItem(
                    icon: Icons.mail,
                    title: 'Email',
                    subtitle: 'example@gmail.com',
                  ),
                  _ProfileDivider(),
                  _ProfileInfoItem(
                    icon: Icons.phone,
                    title: 'Phone Number',
                    subtitle: '+91 70426 94112',
                    description: 'Mobile',
                  ),
                  _ProfileDivider(),
                  _ProfileInfoItemWithValue(
                    icon: Icons.bloodtype_rounded,
                    title: 'Blood Group',
                    value: 'O+',
                  ),
                  _ProfileDivider(),
                  _ProfileInfoItemWithValue(
                    icon: Icons.height_rounded,
                    title: 'Height',
                    value: '157.3 cm',
                  ),
                  _ProfileDivider(),
                  _ProfileInfoItemWithValue(
                    icon: Icons.monitor_weight_rounded,
                    title: 'Weight',
                    value: '78.5 Kg',
                  ),
                  _ProfileDivider(),
                  _ProfileInfoItemWithCheckbox(
                    icon: Icons.medical_services_rounded,
                    title: 'Diabetic',
                    isChecked: true,
                  ),
                  _ProfileDivider(),
                  _ProfileInfoItemWithCheckbox(
                    icon: Icons.error_rounded,
                    title: 'Allergies',
                    isChecked: true,
                  ),
                  _ProfileDivider(),
                  _ProfileInfoItemWithCheckbox(
                    icon: Icons.sentiment_neutral_sharp,
                    title: 'Psychological Disorders',
                    isChecked: true,
                    isSmallerFont: true,
                  ),
                  _ProfileDivider(),
                  _EmergencyContactItem(
                    name: 'John doe',
                    phone: '1234567890',
                    email: 'johndoe@gmail.com',
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _buildEditButton(),
            const SizedBox(height: 70),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImageSection(double size) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Profile Image
        Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(3.0), // Border padding
            child: CircleAvatar(
              backgroundImage: const AssetImage('assets/images/user.png'),
              backgroundColor: grey200,
              radius: size / 2,
            ),
          ),
        ),
        // Edit Icon
        Positioned(
          bottom: 0,
          right: size * 0.3,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: grey600,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
        // Edit Text Label
        Positioned(
          top: size + 10,
          child: Text(
            'Edit Picture',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: grey600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditButton() {
    return ElevatedButton(
      onPressed: () {
        debugPrint('Edit Profile');
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
        backgroundColor: Colors.white,
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
    );
  }
}

// Extracted widgets for better organization and reuse

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

class _ProfileInfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? description;

  const _ProfileInfoItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: grey600),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (description != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    description!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  subtitle,
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
}

class _ProfileInfoItemWithValue extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ProfileInfoItemWithValue({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
      child: Row(
        children: [
          Icon(icon, size: 28, color: grey600),
          const SizedBox(width: 15),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoItemWithCheckbox extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isChecked;
  final bool isSmallerFont;

  const _ProfileInfoItemWithCheckbox({
    required this.icon,
    required this.title,
    required this.isChecked,
    this.isSmallerFont = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
      child: Row(
        children: [
          Icon(icon, size: 28, color: grey600),
          const SizedBox(width: 15),
          Text(
            title,
            style: TextStyle(
              fontSize: isSmallerFont ? 16 : 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Icon(
            isChecked ? Icons.check_box : Icons.check_box_outline_blank,
            size: 28,
            color: isChecked ? Colors.green[700] : Colors.grey[400],
          ),
        ],
      ),
    );
  }
}

class _EmergencyContactItem extends StatelessWidget {
  final String name;
  final String phone;
  final String email;

  const _EmergencyContactItem({
    required this.name,
    required this.phone,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.contact_emergency_rounded, size: 28, color: grey600),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Emergency Contact',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildContactRow('Name', name),
              const SizedBox(height: 4),
              _buildContactRow('Phone', phone),
              const SizedBox(height: 4),
              _buildContactRow('Email', email),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
