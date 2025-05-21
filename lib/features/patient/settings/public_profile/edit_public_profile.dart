import 'package:CuraDocs/common/components/app_header.dart';
import 'package:CuraDocs/common/components/colors.dart';
import 'package:CuraDocs/features/features_api_repository/profile/patient_profile_repository.dart';
import 'package:CuraDocs/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditPublicProfile extends StatefulWidget {
  final String? cin;
  const EditPublicProfile({super.key, this.cin});

  @override
  State<EditPublicProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditPublicProfile> {
  // Constants
  final double profileImageSize = 120.0;

  // Public profile controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _cinController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Private profile controllers
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _homeAddressController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  // Emergency contact controllers
  final TextEditingController _emergencyNameController =
      TextEditingController();
  final TextEditingController _emergencyEmailController =
      TextEditingController();
  final TextEditingController _emergencyPhoneController =
      TextEditingController();
  final TextEditingController _emergencyCountryCodeController =
      TextEditingController(text: '+91');

  String _selectedGender = 'Male';
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  final PostPublicProfileRepository _profileRepository =
      PostPublicProfileRepository();
  bool _isLoading = false;
  bool _isProfileLoaded = false;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    if (widget.cin != null) {
      _cinController.text = widget.cin!;
      // We're not loading the profile data since the repository doesn't provide
      // a method to fetch the profile
    }
  }

  @override
  void dispose() {
    // Dispose public profile controllers
    _firstNameController.dispose();
    _lastNameController.dispose();
    _cinController.dispose();
    _stateController.dispose();
    _descriptionController.dispose();

    // Dispose private profile controllers
    _dateOfBirthController.dispose();
    _cityController.dispose();
    _homeAddressController.dispose();
    _pincodeController.dispose();

    // Dispose emergency contact controllers
    _emergencyNameController.dispose();
    _emergencyEmailController.dispose();
    _emergencyPhoneController.dispose();
    _emergencyCountryCodeController.dispose();

    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_cinController.text.isEmpty) {
      showSnackBar(context: context, message: 'Please enter CIN');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create full name from first and last name
      String fullName =
          '${_firstNameController.text} ${_lastNameController.text}'.trim();

      // Update only the public profile information
      bool success = await _profileRepository.updatePublicProfile(
        _firstNameController.text,
        _lastNameController.text,
        fullName,
        _cinController.text,
        _stateController.text,
        _descriptionController.text,
        context,
      );

      if (success) {
        setState(() {
          _isProfileLoaded = true;
        });
      }
    } catch (e) {
      showSnackBar(context: context, message: 'Error: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateOfBirthController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        onBackPressed: () {
          Navigator.pop(context);
        },
        title: 'Edit Public Profile',
      ),
      backgroundColor: white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
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
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildSectionHeader(
                            'Personal Information', Icons.person),
                        const SizedBox(height: 15),

                        // First name field
                        buildProfileInfoField(
                          title: 'First Name',
                          controller: _firstNameController,
                          keyboardType: TextInputType.name,
                          prefixIcon: const Icon(Icons.person_outline,
                              color: Colors.grey),
                        ),

                        // Last name field
                        buildProfileInfoField(
                          title: 'Last Name',
                          controller: _lastNameController,
                          keyboardType: TextInputType.name,
                          prefixIcon: const Icon(Icons.person_outline,
                              color: Colors.grey),
                        ),

                        // CIN field
                        buildProfileInfoField(
                          title: 'CIN (ID Number)',
                          controller: _cinController,
                          keyboardType: TextInputType.text,
                          prefixIcon:
                              const Icon(Icons.credit_card, color: Colors.grey),
                          readOnly:
                              _isProfileLoaded, // Make CIN read-only if profile is loaded
                        ),

                        // State field
                        buildProfileInfoField(
                          title: 'State',
                          controller: _stateController,
                          keyboardType: TextInputType.text,
                          prefixIcon:
                              const Icon(Icons.location_on, color: Colors.grey),
                        ),

                        const SizedBox(height: 25),
                        _buildSectionHeader('About You', Icons.info_outline),
                        const SizedBox(height: 15),

                        // Description field
                        buildDescriptionField(
                          title: 'Description',
                          controller: _descriptionController,
                          maxLines: 5,
                        ),

                        const SizedBox(height: 25),
                        const Divider(),
                        const SizedBox(height: 10),
                        const Text(
                          "Note: Private information and emergency contacts are managed separately.",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
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
          onPressed: _isLoading ? null : _saveProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: grey600,
            foregroundColor: white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: white,
                    strokeWidth: 3,
                  ),
                )
              : const Text(
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

  Widget buildProfileInfoField({
    required String title,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    Widget? prefixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
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
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: readOnly,
            onTap: onTap,
            maxLines: maxLines,
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
              border: InputBorder.none,
              fillColor: grey200.withValues(alpha: .5),
              filled: true,
              prefixIcon: prefixIcon,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: grey600.withValues(alpha: .7), width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: grey200.withValues(alpha: .5), width: 1.5),
              ),
              hintText: 'Enter $title',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 15,
              ),
            ),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDescriptionField({
    required String title,
    required TextEditingController controller,
    int maxLines = 3,
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
          TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              border: InputBorder.none,
              fillColor: grey200.withValues(alpha: .5),
              filled: true,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: grey600.withValues(alpha: .7), width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: grey200.withValues(alpha: .5), width: 1.5),
              ),
              hintText: 'Write a brief description about yourself...',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 15,
              ),
            ),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
        ],
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
}
