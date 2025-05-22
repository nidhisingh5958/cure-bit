import 'package:CuraDocs/common/components/app_header.dart';
import 'package:CuraDocs/common/components/colors.dart';
import 'package:CuraDocs/app/features_api_repository/profile/doc_public_profile/doctor_profile_repository.dart';
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

class DoctorEditPublicProfile extends StatefulWidget {
  final String doctorId;
  final PostDoctorPublicProfile? initialProfile;

  const DoctorEditPublicProfile({
    super.key,
    required this.doctorId,
    this.initialProfile,
  });

  @override
  State<DoctorEditPublicProfile> createState() =>
      _DoctorEditPublicProfileState();
}

class _DoctorEditPublicProfileState extends State<DoctorEditPublicProfile> {
  final DoctorProfileRepository _repository = DoctorProfileRepository();

  // Basic profile controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _specializationController =
      TextEditingController();
  final TextEditingController _qualificationController =
      TextEditingController();
  final TextEditingController _experienceController = TextEditingController();

  // Professional information
  final TextEditingController _appointmentDurationController =
      TextEditingController();

  // Working address controllers
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  // Working hours controllers
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _breakStartController = TextEditingController();
  final TextEditingController _breakEndController = TextEditingController();

  // Working days
  List<String> allDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  List<String> workingDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday'
  ];
  List<String> holidays = ['Saturday', 'Sunday'];

  String? _imagePath;
  bool _isLoading = false;
  PostDoctorPublicProfile? _doctorProfile;

  @override
  void initState() {
    super.initState();

    // If initial profile is provided, populate the fields
    if (widget.initialProfile != null) {
      _populateFields(widget.initialProfile!);
    } else {
      // Otherwise fetch from repository
      _fetchDoctorProfile();
    }
  }

  Future<void> _fetchDoctorProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final profile =
          await _repository.getPostDoctorPublicProfile(widget.doctorId);
      setState(() {
        _doctorProfile = profile;
        _populateFields(profile);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showSnackBar(context: context, message: 'Failed to load profile: $e');
    }
  }

  void _populateFields(PostDoctorPublicProfile profile) {
    _firstNameController.text = profile.firstName;
    _lastNameController.text = profile.lastName;
    _descriptionController.text = profile.description;
    _specializationController.text = profile.specialization;
    _qualificationController.text = profile.qualification;
    _experienceController.text = profile.yearOfExperience;
    _appointmentDurationController.text = profile.avgAppointmentDuration;
    _imagePath = profile.profilePictureUrl;

    // Populate work address if available
    if (profile.workAddress.isNotEmpty) {
      final address = profile.workAddress[0];
      _addressController.text = address.address;
      _cityController.text = address.city;
      _stateController.text = address.state;
      _countryController.text = address.country;
      _pincodeController.text = address.pincode;
    }

    // Populate working time if available
    if (profile.workingTime.isNotEmpty) {
      final workTime = profile.workingTime[0];
      _startTimeController.text = workTime.startTime;
      _endTimeController.text = workTime.endTime;
      _breakStartController.text = workTime.startBreakTime;
      _breakEndController.text = workTime.endBreakTime;

      // Update working days and holidays
      if (workTime.workingDays.isNotEmpty) {
        workingDays = List.from(workTime.workingDays);
      }
      if (workTime.holidays.isNotEmpty) {
        holidays = List.from(workTime.holidays);
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _descriptionController.dispose();
    _specializationController.dispose();
    _qualificationController.dispose();
    _experienceController.dispose();
    _appointmentDurationController.dispose();

    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _pincodeController.dispose();

    _startTimeController.dispose();
    _endTimeController.dispose();
    _breakStartController.dispose();
    _breakEndController.dispose();

    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (_doctorProfile == null) {
      showSnackBar(context: context, message: 'Profile data not loaded yet');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Create working time object
    final workingTime = DoctorWorkingTime(
      startTime: _startTimeController.text,
      endTime: _endTimeController.text,
      startBreakTime: _breakStartController.text,
      endBreakTime: _breakEndController.text,
      workingDays: workingDays,
      holidays: holidays,
    );

    // Create work address object
    final workAddress = DoctorWorkAddress(
      address: _addressController.text,
      city: _cityController.text,
      state: _stateController.text,
      country: _countryController.text,
      pincode: _pincodeController.text,
    );

    // Build an updated profile
    final updatedProfile = PostDoctorPublicProfile(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      fullName: 'Dr. ${_firstNameController.text} ${_lastNameController.text}',
      cin: _doctorProfile!.cin, // Keep the original CIN
      description: _descriptionController.text,
      specialization: _specializationController.text,
      qualification: _qualificationController.text,
      yearOfExperience: _experienceController.text,
      numberOfPatientAttended:
          _doctorProfile!.numberOfPatientAttended, // Keep original
      avgAppointmentDuration: _appointmentDurationController.text,
      activityStatus: _doctorProfile!.activityStatus, // Keep original status
      workingTime: [workingTime],
      workAddress: [workAddress],
      profilePictureUrl: _imagePath,
    );

    try {
      final success = await _repository.updatePostDoctorPublicProfile(
        widget.doctorId,
        updatedProfile,
      );

      setState(() {
        _isLoading = false;
      });

      if (success) {
        showSnackBar(
            context: context, message: 'Profile updated successfully!');
      } else {
        showSnackBar(context: context, message: 'Failed to update profile');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showSnackBar(context: context, message: 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size information
    final Size screenSize = MediaQuery.of(context).size;
    final double profileImageSize =
        screenSize.width * 0.3; // 30% of screen width

    if (_isLoading) {
      return Scaffold(
        appBar: AppHeader(
          onBackPressed: () => Navigator.pop(context),
          title: 'Edit Profile',
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppHeader(
        onBackPressed: () {
          Navigator.pop(context);
        },
        title: 'Edit Profile',
      ),
      backgroundColor: white,
      body: SingleChildScrollView(
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

                  // First and Last Name in a Row
                  Row(
                    children: [
                      Expanded(
                        child: buildProfileInfoField(
                          title: 'First Name',
                          controller: _firstNameController,
                          keyboardType: TextInputType.name,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: buildProfileInfoField(
                          title: 'Last Name',
                          controller: _lastNameController,
                          keyboardType: TextInputType.name,
                        ),
                      ),
                    ],
                  ),

                  // Description
                  buildProfileInfoField(
                    title: 'Description',
                    controller: _descriptionController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 3,
                  ),

                  const SizedBox(height: 25),

                  _buildSectionHeader(
                      'Professional Information', Icons.work_outline),
                  const SizedBox(height: 15),

                  // Specialization and Qualification
                  buildProfileInfoField(
                    title: 'Specialization',
                    controller: _specializationController,
                  ),

                  buildProfileInfoField(
                    title: 'Qualification',
                    controller: _qualificationController,
                  ),

                  // Experience and Appointment Duration in a Row
                  Row(
                    children: [
                      Expanded(
                        child: buildProfileInfoField(
                          title: 'Years of Experience',
                          controller: _experienceController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: buildProfileInfoField(
                          title: 'Appointment Duration',
                          controller: _appointmentDurationController,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  _buildSectionHeader(
                      'Working Address', Icons.location_on_outlined),
                  const SizedBox(height: 15),

                  _buildWorkAddressContainer(),

                  const SizedBox(height: 25),

                  _buildSectionHeader('Working Hours', Icons.access_time),
                  const SizedBox(height: 15),

                  _buildWorkingHoursContainer(),

                  const SizedBox(height: 25),

                  _buildSectionHeader('Working Days', Icons.calendar_today),
                  const SizedBox(height: 15),

                  _buildWorkingDaysContainer(),

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
          onPressed: _isLoading ? null : _updateProfile,
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
              ? const CircularProgressIndicator(color: white)
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
                  backgroundImage: NetworkImage(_imagePath!),
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
            onTap: () async {
              // Here you would add image picker functionality
              debugPrint('Pick Image');
              // After picking image, you would update profile picture URL
              // Example: await _repository.updateDoctorProfilePicture(widget.doctorId, newImageUrl);
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

  Widget buildProfileInfoField({
    required String title,
    required TextEditingController controller,
    String? description,
    TextInputType keyboardType = TextInputType.text,
    String? suffixText,
    Widget? prefixIcon,
    int? maxLines,
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
            maxLines: maxLines,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkAddressContainer() {
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
              title: 'Address',
              controller: _addressController,
              maxLines: 2,
            ),

            // City and State in a Row
            Row(
              children: [
                Expanded(
                  child: buildProfileInfoField(
                    title: 'City',
                    controller: _cityController,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: buildProfileInfoField(
                    title: 'State',
                    controller: _stateController,
                  ),
                ),
              ],
            ),

            // Country and Pincode in a Row
            Row(
              children: [
                Expanded(
                  child: buildProfileInfoField(
                    title: 'Country',
                    controller: _countryController,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: buildProfileInfoField(
                    title: 'Pincode',
                    controller: _pincodeController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkingHoursContainer() {
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
            // Start and End time in a Row
            Row(
              children: [
                Expanded(
                  child: buildTimeField(
                    title: 'Start Time',
                    controller: _startTimeController,
                    context: context,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: buildTimeField(
                    title: 'End Time',
                    controller: _endTimeController,
                    context: context,
                  ),
                ),
              ],
            ),

            // Break times in a Row
            Row(
              children: [
                Expanded(
                  child: buildTimeField(
                    title: 'Break Start',
                    controller: _breakStartController,
                    context: context,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: buildTimeField(
                    title: 'Break End',
                    controller: _breakEndController,
                    context: context,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTimeField({
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
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: controller.text.isNotEmpty
                    ? _parseTimeString(controller.text)
                    : TimeOfDay.now(),
              );

              if (picked != null) {
                setState(() {
                  // Format the time as HH:MM
                  controller.text =
                      "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                });
              }
            },
            child: AbsorbPointer(
              child: createTextField(
                controller: controller,
                label: title,
                hintText: 'HH:MM',
                prefixIcon: const Icon(Icons.access_time, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TimeOfDay _parseTimeString(String timeString) {
    // Handle empty or invalid strings
    if (timeString.isEmpty) {
      return TimeOfDay.now();
    }

    try {
      final parts = timeString.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } catch (e) {
      return TimeOfDay.now();
    }
  }

  Widget _buildWorkingDaysContainer() {
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
            Text(
              'Select Working Days',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: grey600,
              ),
            ),
            const SizedBox(height: 10),
            // Days selection
            ...allDays.map((day) => _buildDayCheckbox(day)),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCheckbox(String day) {
    final isWorkingDay = workingDays.contains(day);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            if (isWorkingDay) {
              // Remove from working days and add to holidays
              workingDays.remove(day);
              if (!holidays.contains(day)) {
                holidays.add(day);
              }
            } else {
              // Add to working days and remove from holidays
              if (!workingDays.contains(day)) {
                workingDays.add(day);
              }
              holidays.remove(day);
            }
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 16,
                    color: grey800,
                  ),
                ),
              ),
              Transform.scale(
                scale: 0.9,
                child: Checkbox(
                  value: isWorkingDay,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        // Add to working days and remove from holidays
                        if (!workingDays.contains(day)) {
                          workingDays.add(day);
                        }
                        holidays.remove(day);
                      } else {
                        // Remove from working days and add to holidays
                        workingDays.remove(day);
                        if (!holidays.contains(day)) {
                          holidays.add(day);
                        }
                      }
                    });
                  },
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
    );
  }
}
