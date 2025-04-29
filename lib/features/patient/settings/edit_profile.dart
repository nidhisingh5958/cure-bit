import 'package:CuraDocs/components/app_header.dart';
import 'package:CuraDocs/components/colors.dart';
import 'package:CuraDocs/utils/snackbar.dart';
import 'package:flutter/material.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bloodGroupController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _emergencyNameController =
      TextEditingController();
  final TextEditingController _emergencyPhoneController =
      TextEditingController();
  final TextEditingController _emergencyEmailController =
      TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  bool _isDiabetic = false;
  bool _hasAllergies = false;
  bool _hasPsychologicalDisorders = false;

  String? _imagePath;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bloodGroupController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _emergencyEmailController.dispose();
    super.dispose();
  }

  Map<String, dynamic> collectProfileData() {
    return {
      'name': _nameController.text,
      'phone': _phoneController.text,
      'bloodGroup': _bloodGroupController.text,
      'height': _heightController.text,
      'weight': _weightController.text,
      'isDiabetic': _isDiabetic,
      'hasAllergies': _hasAllergies,
      'hasPsychologicalDisorders': _hasPsychologicalDisorders,
      'emergencyContact': {
        'name': _emergencyNameController.text,
        'phone': _emergencyPhoneController.text,
        'email': _emergencyEmailController.text,
      },
      'profileImage': _imagePath,
    };
  }

  void _updateProfile() {
    final profileData = collectProfileData();
    print('Profile Data: $profileData');
    showSnackBar(context: context, message: 'Profile updated successfully!');
  }

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
            icon: const Icon(Icons.check),
            onPressed: () {
              _updateProfile();
            },
          ),
        ],
      ),
      backgroundColor: white,
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
                color: transparent,
                borderRadius: BorderRadius.all(Radius.circular(25)),
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.black12,
                //     blurRadius: 10,
                //     offset: Offset(0, 4),
                //   ),
                // ],
              ),
              margin: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  buildProfileInfoField(
                    icon: Icons.phone,
                    title: 'Phone Number',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  const _ProfileDivider(),
                  buildProfileInfoWithValueField(
                    icon: Icons.bloodtype_rounded,
                    title: 'Blood Group',
                    controller: _bloodGroupController,
                  ),
                  const _ProfileDivider(),
                  buildProfileInfoWithValueField(
                    icon: Icons.height_rounded,
                    title: 'Height',
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    suffix: 'cm',
                  ),
                  const _ProfileDivider(),
                  buildProfileInfoWithValueField(
                    icon: Icons.monitor_weight_rounded,
                    title: 'Weight',
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    suffix: 'Kg',
                  ),
                  const _ProfileDivider(),
                  buildProfileInfoWithCheckbox(
                    icon: Icons.medical_services_rounded,
                    title: 'Diabetic',
                    value: _isDiabetic,
                    onChanged: (value) {
                      setState(() {
                        _isDiabetic = value!;
                      });
                    },
                  ),
                  const _ProfileDivider(),
                  buildProfileInfoWithCheckbox(
                    icon: Icons.error_rounded,
                    title: 'Allergies',
                    value: _hasAllergies,
                    onChanged: (value) {
                      setState(() {
                        _hasAllergies = value!;
                      });
                    },
                  ),
                  const _ProfileDivider(),
                  buildProfileInfoWithCheckbox(
                    icon: Icons.sentiment_neutral_sharp,
                    title: 'Psychological Disorders',
                    value: _hasPsychologicalDisorders,
                    onChanged: (value) {
                      setState(() {
                        _hasPsychologicalDisorders = value!;
                      });
                    },
                    isSmallerFont: true,
                  ),
                  const _ProfileDivider(),
                  buildEmergencyContactFields(
                    nameController: _emergencyNameController,
                    phoneController: _emergencyPhoneController,
                    emailController: _emergencyEmailController,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            const SizedBox(height: 10),
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
            color: white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: black.withValues(alpha: .2),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _imagePath != null
              ? CircleAvatar(
                  backgroundImage: AssetImage(_imagePath!),
                  backgroundColor: grey200,
                  // radius: size / 2,
                )
              : CircleAvatar(
                  backgroundImage: const AssetImage('assets/images/user.png'),
                  backgroundColor: grey200,
                  // radius: size / 2,
                ),
        ),
        // Edit Icon
        Positioned(
          bottom: 0,
          right: size * 0.3 + 5,
          child: GestureDetector(
            onTap: () {
              debugPrint('Pick Image');
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: grey600,
                shape: BoxShape.circle,
                border: Border.all(color: white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildProfileInfoField({
    required IconData icon,
    required String title,
    required TextEditingController controller,
    String? description,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
      child: Expanded(
        child: Column(
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
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  border: InputBorder.none,
                  hintText: 'Enter $title',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                ),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// input field
  Widget buildProfileInfoWithValueField({
    required IconData icon,
    required String title,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 100,
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: InputBorder.none,
                hintText: title,
                suffixText: suffix,
                hintStyle: TextStyle(
                  color: grey400,
                  fontSize: 16,
                ),
              ),
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

// Checkbox fields
  Widget buildProfileInfoWithCheckbox({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
    bool isSmallerFont = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isSmallerFont ? 16 : 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.green[700],
          ),
        ],
      ),
    );
  }

//  emergency contact fields
  Widget buildEmergencyContactFields({
    required TextEditingController nameController,
    required TextEditingController phoneController,
    required TextEditingController emailController,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
      child: Column(
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
          _buildContactFieldRow('Name', nameController),
          const SizedBox(height: 4),
          _buildContactFieldRow('Phone', phoneController, TextInputType.phone),
          const SizedBox(height: 4),
          _buildContactFieldRow(
              'Email', emailController, TextInputType.emailAddress),
        ],
      ),
    );
  }

  Widget _buildContactFieldRow(String label, TextEditingController controller,
      [TextInputType keyboardType = TextInputType.text]) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: InputBorder.none,
              hintText: 'Enter $label',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }
}

// Divider for profile sections
class _ProfileDivider extends StatelessWidget {
  const _ProfileDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      color: transparent,
      thickness: 1,
      indent: 20,
      endIndent: 20,
    );
  }
}
