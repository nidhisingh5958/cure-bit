// ignore_for_file: use_build_context_synchronously

import 'package:CureBit/services/user/user_helper.dart';
import 'package:CureBit/common/components/app_header.dart';
import 'package:CureBit/common/components/colors.dart';
import 'package:CureBit/services/features_api_repository/profile/private_profile/get_private_repository.dart';
import 'package:CureBit/services/features_api_repository/profile/private_profile/private_profile_repository.dart'
    as impl;
import 'package:CureBit/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

class PatientEditPrivateProfile extends ConsumerStatefulWidget {
  final String? cin;
  const PatientEditPrivateProfile({super.key, this.cin});

  @override
  ConsumerState<PatientEditPrivateProfile> createState() =>
      _PatientEditPrivateProfileState();
}

class _PatientEditPrivateProfileState
    extends ConsumerState<PatientEditPrivateProfile> {
  // Constants
  static const double profileImageSize = 120.0;

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
  String? _imagePath;

  final impl.PrivateProfileRepository _privateProfileRepository =
      impl.PrivateProfileRepository();
  bool _isLoading = false;
  bool _isPrivateProfileLoaded = false;
  impl.PrivateProfileData? _privateProfileData;
  final String _defaultCin = 'VHUZ8128'; // Default CIN for testing
  late String role;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // If CIN is provided via parameters, use it; otherwise, use the default
    final cinToUse = widget.cin ?? _defaultCin;
    _cinController.text = cinToUse;

    role = UserHelper.getUserAttribute<String>(ref, 'role') ?? '';

    // Fetch profile data on initialization
    Future.microtask(() => _loadProfileData(cinToUse));
  }

  Future<void> _loadProfileData(String cin) async {
    if (cin.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // First try to get profile using Riverpod provider
      final profileDataAsync =
          await ref.read(patientProfileDataProvider(cin).future);

      // Parse the profile data from Riverpod
      if (profileDataAsync is Map<String, dynamic>) {
        // Extract relevant fields from the response
        final Map<String, dynamic> profile = profileDataAsync;

        // Populate controllers with data from profile
        if (profile['name'] != null) {
          final nameParts = profile['name'].split(' ');
          if (nameParts.isNotEmpty) {
            _firstNameController.text = nameParts[0];
            if (nameParts.length > 1) {
              _lastNameController.text = nameParts.sublist(1).join(' ');
            }
          }
        }

        if (profile['email'] != null) {
          _emergencyEmailController.text = profile['email'];
        }

        if (profile['location'] != null) {
          _stateController.text = profile['location'];
        }
      }

      // Then load private profile data with more detailed information
      await _loadPrivateProfile();
    } catch (e) {
      showSnackBar(
          context: context,
          message: 'Error loading profile data: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPrivateProfile() async {
    if (_cinController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      _privateProfileData = await _privateProfileRepository.getPrivateProfile(
          _cinController.text, role);

      // Populate public profile fields if they're empty
      if (_privateProfileData != null) {
        // Populate private profile fields
        _dateOfBirthController.text = _privateProfileData!.dateOfBirth;
        _selectedGender = _privateProfileData!.gender;
        _stateController.text = _privateProfileData!.state;
        _cityController.text = _privateProfileData!.city;
        _homeAddressController.text = _privateProfileData!.homeAddress;
        _pincodeController.text = _privateProfileData!.pincode;

        // Populate emergency contact fields
        final emergency = _privateProfileData!.emergencyContactDetails;
        _emergencyNameController.text = emergency.name;
        _emergencyEmailController.text = emergency.email;
        _emergencyPhoneController.text = emergency.phoneNumber;
        _emergencyCountryCodeController.text = emergency.countryCode;

        setState(() {
          _isPrivateProfileLoaded = true;
        });
      }
    } catch (e) {
      showSnackBar(
          context: context,
          message: 'Error loading private profile: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
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
      final emergencyContact = impl.EmergencyContact(
        name: _emergencyNameController.text,
        email: _emergencyEmailController.text,
        phoneNumber: _emergencyPhoneController.text,
        countryCode: _emergencyCountryCodeController.text,
      );

      final privateProfileData = impl.PrivateProfileData(
        cin: _cinController.text,
        dateOfBirth: _dateOfBirthController.text,
        gender: _selectedGender,
        state: _stateController.text,
        city: _cityController.text,
        homeAddress: _homeAddressController.text,
        pincode: _pincodeController.text,
        emergencyContactDetails: emergencyContact,
      );

      // Update the profile
      final success = await _privateProfileRepository.updatePrivateProfile(
          privateProfileData, context, role);

      if (success) {
        // Refresh the cache using the repository method
        try {
          await _privateProfileRepository.refreshCache(
              _cinController.text, context, role);

          // Also refresh the Riverpod cache if the provider exists
          try {
            await ref.read(
                refreshPatientProfileCacheProvider(_cinController.text).future);
          } catch (e) {
            // If Riverpod cache refresh fails, it's not critical
            debugPrint('Riverpod cache refresh failed: $e');
          }

          showSnackBar(
              context: context,
              message: 'Profile updated and cache refreshed successfully!');
        } catch (cacheError) {
          // Even if cache refresh fails, the update was successful
          showSnackBar(
              context: context,
              message:
                  'Profile updated successfully, but cache refresh failed: ${cacheError.toString()}');
        }

        // Navigate back to the profile page
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      showSnackBar(
          context: context, message: 'Error saving profile: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Manual refresh cache method that can be called independently
  Future<void> _refreshCacheManually() async {
    if (_cinController.text.isEmpty) {
      showSnackBar(context: context, message: 'Please enter CIN first');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Use the silent version to avoid duplicate snackbars
      final success = await _privateProfileRepository.refreshCacheSilent(
          _cinController.text, role);

      if (success) {
        showSnackBar(context: context, message: 'Cache refreshed successfully');

        // Reload the profile data after cache refresh
        await _loadPrivateProfile();
      } else {
        showSnackBar(context: context, message: 'Failed to refresh cache');
      }
    } catch (e) {
      showSnackBar(
          context: context, message: 'Error refreshing cache: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    // Parse the existing date if available
    DateTime initialDate;
    try {
      initialDate = _dateOfBirthController.text.isNotEmpty
          ? DateFormat('yyyy-MM-dd').parse(_dateOfBirthController.text)
          : DateTime.now();
    } catch (e) {
      initialDate = DateTime.now();
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
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
        title: 'Edit Account Details',
        // Add a refresh button to the app bar
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _refreshCacheManually,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Cache',
          ),
        ],
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
                              _isPrivateProfileLoaded, // Make CIN read-only if profile is loaded
                        ),

                        // Date of Birth field with date picker
                        buildProfileInfoField(
                          title: 'Date of Birth',
                          controller: _dateOfBirthController,
                          keyboardType: TextInputType.datetime,
                          prefixIcon: const Icon(Icons.calendar_today,
                              color: Colors.grey),
                          readOnly: true,
                          onTap: () => _selectDate(context),
                        ),

                        // Gender dropdown
                        _buildGenderDropdown(),

                        const SizedBox(height: 25),
                        _buildSectionHeader('Address Information', Icons.home),
                        const SizedBox(height: 15),

                        // State field
                        buildProfileInfoField(
                          title: 'State',
                          controller: _stateController,
                          keyboardType: TextInputType.text,
                          prefixIcon:
                              const Icon(Icons.location_on, color: Colors.grey),
                        ),

                        // City field
                        buildProfileInfoField(
                          title: 'City',
                          controller: _cityController,
                          keyboardType: TextInputType.text,
                          prefixIcon: const Icon(Icons.location_city,
                              color: Colors.grey),
                        ),

                        // Home Address field
                        buildProfileInfoField(
                          title: 'Home Address',
                          controller: _homeAddressController,
                          keyboardType: TextInputType.streetAddress,
                          prefixIcon:
                              const Icon(Icons.home, color: Colors.grey),
                          maxLines: 2,
                        ),

                        // Pincode field
                        buildProfileInfoField(
                          title: 'Pincode',
                          controller: _pincodeController,
                          keyboardType: TextInputType.number,
                          prefixIcon:
                              const Icon(Icons.pin_drop, color: Colors.grey),
                        ),

                        const SizedBox(height: 25),
                        _buildSectionHeader(
                            'Emergency Contact', Icons.emergency),
                        const SizedBox(height: 15),

                        // Emergency contact name
                        buildProfileInfoField(
                          title: 'Emergency Contact Name',
                          controller: _emergencyNameController,
                          keyboardType: TextInputType.name,
                          prefixIcon:
                              const Icon(Icons.person, color: Colors.grey),
                        ),

                        // Emergency contact email
                        buildProfileInfoField(
                          title: 'Emergency Contact Email',
                          controller: _emergencyEmailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon:
                              const Icon(Icons.email, color: Colors.grey),
                        ),

                        // Country code and phone number in a row
                        _buildPhoneNumberWithCountryCode(),

                        const SizedBox(height: 25),
                        _buildSectionHeader('About You', Icons.info_outline),
                        const SizedBox(height: 15),

                        // Description field
                        buildDescriptionField(
                          title: 'Description',
                          controller: _descriptionController,
                          maxLines: 5,
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

  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5, bottom: 8),
            child: Text(
              'Gender',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: grey600,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: grey200.withValues(alpha: .5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: grey200.withValues(alpha: .5),
                width: 1.5,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedGender,
                isExpanded: true,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                icon: const Icon(Icons.arrow_drop_down),
                borderRadius: BorderRadius.circular(12),
                items: _genderOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGender = newValue!;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneNumberWithCountryCode() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5, bottom: 8),
            child: Text(
              'Emergency Contact Phone Number',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: grey600,
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Country code field
              Flexible(
                flex: 1,
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: TextField(
                    controller: _emergencyCountryCodeController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 15),
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
                      hintText: '+91',
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
                ),
              ),
              // Phone number field
              Flexible(
                flex: 3,
                child: TextField(
                  controller: _emergencyPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 15),
                    border: InputBorder.none,
                    fillColor: grey200.withValues(alpha: .5),
                    filled: true,
                    prefixIcon: const Icon(Icons.phone, color: Colors.grey),
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
                    hintText: 'Phone Number',
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
              ),
            ],
          ),
        ],
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
          child: InkWell(
            onTap: () async {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(
                source: ImageSource.gallery,
                maxWidth: 512,
                maxHeight: 512,
              );
              if (image != null) {
                setState(() {
                  _imagePath = image.path;
                });
                debugPrint('Picked image path: ${image.path}');
              }
            },
            child: _imagePath != null
                ? CircleAvatar(
                    backgroundImage: AssetImage(_imagePath!),
                    backgroundColor: grey200,
                  )
                : CircleAvatar(
                    backgroundImage:
                        const AssetImage('assets/images/PersonalProfile.png'),
                    backgroundColor: grey200,
                  ),
          ),
        ),
        // Edit Icon
        Positioned(
          bottom: 0,
          right: size * 0.3,
          child: GestureDetector(
            onTap: () {
              final ImagePicker picker = ImagePicker();
              picker
                  .pickImage(
                source: ImageSource.gallery,
                maxWidth: 512,
                maxHeight: 512,
              )
                  .then((XFile? image) {
                if (image != null) {
                  setState(() {
                    _imagePath = image.path;
                  });
                }
              });
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
