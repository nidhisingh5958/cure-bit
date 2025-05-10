import 'package:CuraDocs/components/app_header.dart';
import 'package:CuraDocs/components/colors.dart';
import 'package:CuraDocs/utils/snackbar.dart';
import 'package:flutter/material.dart';

// reusable text field widget function
Widget createTextField({
  required TextEditingController controller,
  required String label,
  TextInputType keyboardType = TextInputType.text,
  bool isDense = true,
  Color? fieldColor,
  TextAlign textAlign = TextAlign.left,
  String? hintText,
  String? suffixText,
  EdgeInsetsGeometry? contentPadding,
  int? maxLines,
  Widget? prefixIcon,
}) {
  fieldColor = fieldColor ?? grey200.withValues(alpha: .5);

  return TextField(
    controller: controller,
    keyboardType: keyboardType,
    textAlign: textAlign,
    maxLines: maxLines ?? 1,
    decoration: InputDecoration(
      isDense: isDense,
      contentPadding: contentPadding ??
          const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
      border: InputBorder.none,
      fillColor: fieldColor,
      filled: true,
      prefixIcon: prefixIcon,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: grey600.withValues(alpha: .7), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: fieldColor, width: 1.5),
      ),
      hintText: hintText ?? 'Enter $label',
      suffixText: suffixText,
      hintStyle: TextStyle(
        color: Colors.grey[400],
        fontSize: 15,
      ),
    ),
    style: TextStyle(
      fontSize: 16,
      color: Colors.grey[700],
      fontWeight:
          textAlign == TextAlign.right ? FontWeight.w500 : FontWeight.normal,
    ),
  );
}

class DoctorEditProfile extends StatefulWidget {
  const DoctorEditProfile({super.key});

  @override
  State<DoctorEditProfile> createState() => _DoctorEditProfileState();
}

class _DoctorEditProfileState extends State<DoctorEditProfile> {
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

  // Adding controllers for the description fields
  final TextEditingController _diabeticDescController = TextEditingController();
  final TextEditingController _allergiesDescController =
      TextEditingController();
  final TextEditingController _psychDisordersDescController =
      TextEditingController();

  bool _isDiabetic = false;
  bool _hasAllergies = false;
  bool _hasPsychologicalDisorders = false;

  String? _imagePath;

  @override
  void initState() {
    super.initState();
    // Set a default DOB format for display (empty)
    _dobController.text = '';
  }

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
    _diabeticDescController.dispose();
    _allergiesDescController.dispose();
    _psychDisordersDescController.dispose();
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
      'diabeticDescription': _isDiabetic ? _diabeticDescController.text : null,
      'hasAllergies': _hasAllergies,
      'allergiesDescription':
          _hasAllergies ? _allergiesDescController.text : null,
      'hasPsychologicalDisorders': _hasPsychologicalDisorders,
      'psychDisordersDescription': _hasPsychologicalDisorders
          ? _psychDisordersDescController.text
          : null,
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
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.check, color: Colors.green),
        //     onPressed: () {
        //       _updateProfile();
        //     },
        //   ),
        // ],
      ),
      backgroundColor: white,
      body: SingleChildScrollView(
        // physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    grey600.withValues(alpha: .05),
                    white,
                  ],
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 25),
                  // Profile Image Section
                  _buildProfileImageSection(profileImageSize),
                  const SizedBox(height: 15),
                ],
              ),
            ),

            // Profile Details Container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  _buildSectionHeader('Personal Information', Icons.person),
                  const SizedBox(height: 15),

                  buildProfileInfoField(
                    title: 'Name',
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    prefixIcon:
                        const Icon(Icons.person_outline, color: Colors.grey),
                  ),

                  buildProfileInfoField(
                    title: 'Phone Number',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon:
                        const Icon(Icons.phone_outlined, color: Colors.grey),
                  ),

                  const SizedBox(height: 5),

                  buildDateField(
                    title: 'Date of Birth',
                    controller: _dobController,
                    context: context,
                  ),

                  // Height and Weight in a Row
                  Row(
                    children: [
                      Expanded(
                        child: buildProfileInfoField(
                          title: 'Height',
                          controller: _heightController,
                          keyboardType: TextInputType.number,
                          suffixText: 'cm',
                          prefixIcon:
                              const Icon(Icons.height, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: buildProfileInfoField(
                          title: 'Weight',
                          controller: _weightController,
                          keyboardType: TextInputType.number,
                          suffixText: 'kg',
                          prefixIcon: const Icon(Icons.monitor_weight_outlined,
                              color: Colors.grey),
                        ),
                      ),
                    ],
                  ),

                  buildProfileInfoField(
                    title: 'Blood Group',
                    controller: _bloodGroupController,
                    keyboardType: TextInputType.text,
                    prefixIcon: const Icon(Icons.bloodtype_outlined,
                        color: Colors.grey),
                  ),

                  const SizedBox(height: 25),

                  _buildSectionHeader('Medical Information',
                      Icons.medical_information_outlined),
                  const SizedBox(height: 15),

                  _buildMedicalInfoContainer([
                    buildProfileInfoWithCheckbox(
                      title: 'Diabetic',
                      value: _isDiabetic,
                      descriptionController: _diabeticDescController,
                      icon: Icons.medication_outlined,
                      onChanged: (value) {
                        setState(() {
                          _isDiabetic = value!;
                        });
                      },
                    ),
                    buildProfileInfoWithCheckbox(
                      title: 'Allergies',
                      value: _hasAllergies,
                      descriptionController: _allergiesDescController,
                      icon: Icons.sick_outlined,
                      onChanged: (value) {
                        setState(() {
                          _hasAllergies = value!;
                        });
                      },
                    ),
                    buildProfileInfoWithCheckbox(
                      title: 'Psychological Disorders',
                      value: _hasPsychologicalDisorders,
                      descriptionController: _psychDisordersDescController,
                      icon: Icons.psychology_outlined,
                      onChanged: (value) {
                        setState(() {
                          _hasPsychologicalDisorders = value!;
                        });
                      },
                    ),
                  ]),

                  const SizedBox(height: 25),

                  _buildSectionHeader(
                      'Emergency Contact', Icons.emergency_outlined),
                  const SizedBox(height: 15),

                  _buildEmergencyContactContainer(
                    nameController: _emergencyNameController,
                    phoneController: _emergencyPhoneController,
                    emailController: _emergencyEmailController,
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          onPressed: _updateProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: grey600,
            foregroundColor: white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Save Profile',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: grey600,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: grey800,
          ),
        ),
      ],
    );
  }

  Widget _buildMedicalInfoContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: .1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
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
                color: black.withValues(alpha: .1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: _imagePath != null
              ? CircleAvatar(
                  backgroundImage: AssetImage(_imagePath!),
                  backgroundColor: grey200,
                )
              : CircleAvatar(
                  backgroundImage: const AssetImage('assets/images/user.png'),
                  backgroundColor: grey200,
                ),
        ),
        // Edit Icon
        Positioned(
          bottom: 0,
          right: size * 0.3,
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
                boxShadow: [
                  BoxShadow(
                    color: grey600.withValues(alpha: .3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
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

  // Date of Birth field with date picker
  Widget buildDateField({
    required String title,
    required TextEditingController controller,
    required BuildContext context,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5, bottom: 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: grey600,
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: controller.text.isNotEmpty
                    ? DateTime.parse(controller.text)
                    : DateTime.now().subtract(const Duration(
                        days: 365 * 18)), // Default to 18 years ago
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: grey400,
                        onPrimary: white,
                        onSurface: grey800,
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: grey400,
                        ),
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (picked != null) {
                setState(() {
                  // Format the date as YYYY-MM-DD
                  controller.text =
                      "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                });
              }
            },
            child: AbsorbPointer(
              child: createTextField(
                controller: controller,
                label: title,
                hintText: 'YYYY-MM-DD',
                prefixIcon:
                    const Icon(Icons.calendar_today, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProfileInfoField({
    required String title,
    required TextEditingController controller,
    String? description,
    TextInputType keyboardType = TextInputType.text,
    String? suffixText,
    Widget? prefixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5, bottom: 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: grey600,
              ),
            ),
          ),
          if (description != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                description,
                style: TextStyle(fontSize: 14, color: grey600),
              ),
            ),
          createTextField(
            controller: controller,
            label: title,
            keyboardType: keyboardType,
            suffixText: suffixText,
            prefixIcon: prefixIcon,
          ),
        ],
      ),
    );
  }

  // Checkbox fields with description
  Widget buildProfileInfoWithCheckbox({
    required String title,
    required bool value,
    required TextEditingController descriptionController,
    required ValueChanged<bool?> onChanged,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox row with improved styling
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                onChanged(!value);
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    if (icon != null)
                      Icon(
                        icon,
                        size: 20,
                        color: value ? grey600 : grey800,
                      ),
                    if (icon != null) const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: value ? grey600 : grey800,
                        ),
                      ),
                    ),
                    Transform.scale(
                      scale: 0.9,
                      child: Checkbox(
                        value: value,
                        onChanged: onChanged,
                        activeColor: grey600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Animated container for description field
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: value ? 100 : 0,
            curve: Curves.easeInOut,
            child: value
                ? Padding(
                    padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
                    child: createTextField(
                      controller: descriptionController,
                      label: '',
                      hintText:
                          'Please describe your ${title.toLowerCase()}...',
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 15),
                      maxLines: 3,
                    ),
                  )
                : const SizedBox(),
          ),

          // Add a divider between items
          if (value)
            const SizedBox(height: 10)
          else
            const Divider(height: 1, thickness: 0.5),
        ],
      ),
    );
  }

  // Emergency contact container with improved styling
  Widget _buildEmergencyContactContainer({
    required TextEditingController nameController,
    required TextEditingController phoneController,
    required TextEditingController emailController,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: .1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildProfileInfoField(
              title: 'Contact Name',
              controller: nameController,
              prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
            ),
            buildProfileInfoField(
              title: 'Contact Phone',
              controller: phoneController,
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(Icons.phone_outlined, color: Colors.grey),
            ),
            buildProfileInfoField(
              title: 'Contact Email',
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
