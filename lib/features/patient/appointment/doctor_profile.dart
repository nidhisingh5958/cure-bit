import 'dart:convert';

import 'package:CureBit/common/components/colors.dart';
import 'package:CureBit/common/components/app_header.dart';
import 'package:CureBit/common/components/pop_up.dart';
import 'package:CureBit/services/features_api_repository/connect/send_connect_provider.dart';
import 'package:CureBit/services/features_api_repository/connect/send_connect_provider.dart'
    as connect;
import 'package:CureBit/services/features_api_repository/profile/public_profile/doctor/get/get_doc_public_provider.dart';
import 'package:CureBit/utils/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:CureBit/services/features_api_repository/profile/public_profile/doctor/get/doctor_model.dart'
    as model;

Color primaryColor = black;
Color secondaryColor = grey400;

class DoctorProfile extends ConsumerStatefulWidget {
  final String? doctorCin;

  const DoctorProfile({
    super.key,
    this.doctorCin,
  });

  @override
  ConsumerState<DoctorProfile> createState() => _DoctorProfileState();
}

class _DoctorProfileState extends ConsumerState<DoctorProfile>
    with TickerProviderStateMixin {
  bool showConnectionAnimation = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  model.DoctorProfileModel? _doctorProfile;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 40,
      ),
    ]).animate(_animationController);

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          showConnectionAnimation = false;
        });
        _animationController.reset();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDoctorData();
      _checkConnectionStatus();
    });
  }

  Future<void> _checkConnectionStatus() async {
    if (widget.doctorCin != null) {
      try {
        // Initialize the connection status check
        final connectionNotifier = ref.read(connectionProvider.notifier);
        await connectionNotifier.checkConnectionStatus(widget.doctorCin!);
        // await connectionNotifier.checkConnectionStatus('GAJB8522');
      } catch (e) {
        debugPrint('Error checking connection status: $e');
      }
    }
  }

  Future<void> _fetchDoctorData() async {
    if (widget.doctorCin == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Doctor ID not provided";
      });
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final doctorProfileNotifier =
          ref.read(doctorProfileNotifierProvider.notifier);
      await doctorProfileNotifier.getDoctorPublicProfile(widget.doctorCin!);
      // await doctorProfileNotifier.getDoctorPublicProfile(
      //   'GAJB8522',
      // );

      final profileState = ref.read(doctorProfileNotifierProvider);

      if (profileState is AsyncData && profileState.value != null) {
        try {
          debugPrint('Raw response: ${profileState.value}');

          // Parse JSON directly instead of using fromResponseString
          final jsonData = json.decode(profileState.value!);

          // Create DoctorProfile with safe null handling
          final doctorProfile = model.DoctorProfileModel(
            cin: jsonData['CIN'] as String? ?? 'GAJB8522',
            name: _buildFullName(jsonData) as String? ?? 'Doctor Name',
            specialization:
                jsonData['specialization'] as String? ?? 'General Practitioner',
            qualification: jsonData['qualification'] as String? ?? 'MBBS',
            experience: jsonData['year_of_experience'] as String? ?? '0',
            address: _extractAddress(jsonData['work_address']),
            bio: jsonData['description'] as String?,
            workingTime: _extractWorkingTime(jsonData['working_time']),
            patientsAttended:
                jsonData['number_of_patient_attended'] as String? ?? '0',
          );

          if (mounted) {
            setState(() {
              _doctorProfile = doctorProfile;
              _isLoading = false;
            });
          }
        } catch (parseError) {
          debugPrint('Parse error details: $parseError');
          setState(() {
            _isLoading = false;
            _errorMessage = "Failed to parse doctor data: $parseError";
          });
        }
      } else if (profileState is AsyncError) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              "Failed to load doctor profile: ${profileState.error}";
        });
      }
    } catch (e) {
      debugPrint('General error: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = "Error: ${e.toString()}";
      });
    }
  }

  // Helper method to build full name safely
  String _buildFullName(Map<String, dynamic> jsonData) {
    final firstName = jsonData['first_name'] as String? ?? '';
    final lastName = jsonData['last_name'] as String? ?? '';
    final fullName = jsonData['full_name'] as String?;

    // Prioritize full_name, then combine first and last name
    if (fullName != null && fullName.isNotEmpty && fullName != 'string') {
      return fullName;
    } else if (firstName.isNotEmpty && firstName != 'string') {
      return lastName.isNotEmpty && lastName != 'string'
          ? '$firstName $lastName'
          : firstName;
    } else {
      return 'Doctor Name';
    }
  }

  String _extractAddress(dynamic workAddress) {
    if (workAddress == null) return 'Address not available';

    if (workAddress is String) {
      return workAddress.isEmpty || workAddress == 'string'
          ? 'Address not available'
          : workAddress;
    }

    if (workAddress is Map<String, dynamic>) {
      final address = workAddress['address'] as String?;
      return address?.isNotEmpty == true && address != 'string'
          ? address!
          : 'Address not available';
    }

    return 'Address not available';
  }

  String _extractWorkingTime(dynamic workingTime) {
    if (workingTime == null) return 'Working hours not available';

    if (workingTime is String) {
      return workingTime.isEmpty || workingTime == 'string'
          ? 'Working hours not available'
          : workingTime;
    }

    if (workingTime is Map<String, dynamic>) {
      final hours = workingTime['hours'] as String?;
      return hours?.isNotEmpty == true && hours != 'string'
          ? hours!
          : 'Working hours not available';
    }

    return 'Working hours not available';
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the doctor profile provider state
    final doctorProfileState = ref.watch(doctorProfileNotifierProvider);

    // Listen to the connection state provider
    final connectionState = ref.watch(connectionProvider);

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 212, 218, 222),
        appBar: AppHeader(
          title: 'Doctor Profile',
          onBackPressed: () => context.goNamed('home'),
        ),
        body: doctorProfileState.isLoading || _isLoading
            ? _buildLoadingState()
            : doctorProfileState.hasError || _errorMessage != null
                ? _buildErrorState(
                    _errorMessage ?? doctorProfileState.error.toString())
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildProfileHeader(context, connectionState),
                        SizedBox(height: 10),
                        _buildInfoCard(context),
                        SizedBox(height: 5),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading doctor profile...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'Failed to load doctor profile',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchDoctorData,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(
      BuildContext context, connect.ConnectionState connectionState) {
    final doctorData = _getDoctorData();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: black.withValues(alpha: .05),
              blurRadius: 10,
              spreadRadius: 1,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Background header with gradient or image
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                image: DecorationImage(
                  image: AssetImage('assets/images/header_bg.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).primaryColor.withValues(alpha: .3),
                    BlendMode.darken,
                  ),
                ),
              ),
            ),

            // Profile image with overlap and shadow
            Transform.translate(
              offset: Offset(0, -50),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: black.withValues(alpha: .1),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: white,
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: grey200,
                    backgroundImage: AssetImage('assets/images/girl.jpeg'),
                  ),
                ),
              ),
            ),

            // Negative margin to compensate for the transform
            Transform.translate(
              offset: Offset(0, -35),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Doctor name and details
                    Text(
                      doctorData.name ?? 'Doctor Name',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 6),
                    Text(
                      doctorData.specialization ?? 'Specialist',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    // Only show ratings if available
                    if (_hasReviews())
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: .15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 20),
                            SizedBox(width: 5),
                            Text(
                              '5.0',
                              style: TextStyle(
                                color: Colors.amber[800],
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              ' (124 reviews)',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 16),
                    _buildActionButtons(connectionState),
                    if (connectionState.error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          connectionState.error!,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to check if reviews are available
  bool _hasReviews() {
    // This is a placeholder. Replace with actual logic when review data is available
    return false;
  }

  // Helper method to get doctor data safely
  model.DoctorProfileModel _getDoctorData() {
    return _doctorProfile ??
        model.DoctorProfileModel(
          cin: widget.doctorCin ?? 'GAJB8522',
          name: 'Loading...', // Better fallback text
          specialization:
              'General Practitioner', // Add fallback for specialization
          address: 'Address not available',
        );
  }

  Widget _buildActionButtons(connect.ConnectionState connectionState) {
    final doctorData = _getDoctorData();
    final bool isConnected = connectionState.isConnected;
    final bool isLoading = connectionState.isLoading;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              context.goNamed(RouteConstants.chat);
            },
            icon: Icon(Icons.message_outlined),
            label: Text('Message'),
            style: ElevatedButton.styleFrom(
              foregroundColor: primaryColor,
              backgroundColor: secondaryColor.withValues(alpha: .1),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    if (widget.doctorCin != null) {
                      final connectionNotifier =
                          ref.read(connectionProvider.notifier);
                      connectionNotifier.toggleConnection(widget.doctorCin!);
                      // connectionNotifier.toggleConnection(
                      //   'GAJB8522',
                      // );

                      if (!isConnected) {
                        setState(() {
                          showConnectionAnimation = true;
                        });
                        _animationController.forward();
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              foregroundColor: isConnected ? Colors.white : primaryColor,
              backgroundColor:
                  isConnected ? grey800 : secondaryColor.withValues(alpha: .1),
              elevation: isConnected ? 2 : 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(vertical: 14),
            ),
            child: isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isConnected ? Colors.white : primaryColor,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child: Icon(
                          isConnected ? Icons.check : MdiIcons.vectorLink,
                          key: ValueKey<bool>(isConnected),
                        ),
                      ),
                      SizedBox(width: 8),
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        child: Text(
                          isConnected ? 'Connected' : 'Connect',
                          key: ValueKey<bool>(isConnected),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        PopupMenuHelper.buildPopupMenu(
          context,
          onSelected: (value) {
            if (value == 'book') {
              // Pass doctor information to booking screen
              context.goNamed(
                RouteConstants.bookAppointment,
                queryParameters: {
                  'doctorCin': doctorData.cin ?? '',
                  'doctorName': doctorData.name ?? '',
                  'doctorSpecialty': doctorData.specialization ?? '',
                },
              );
            } else if (value == 'doctorQR') {
              context.goNamed(RouteConstants.helpAndSupport);
            }
          },
          optionsList: [
            {'book': 'Book an appointment'},
            {'doctorQR': 'Doctor\'s QR'},
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final doctorData = _getDoctorData();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
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
          children: [
            _buildSectionWithIcon(
              context,
              'Information',
              Icons.info_outline,
              _buildInfoSection(doctorData),
            ),
            Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
            _buildSectionWithIcon(
              context,
              'Working Hours',
              Icons.access_time,
              _buildWorkingHours(),
            ),
            Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
            _buildSectionWithIcon(
              context,
              'Location',
              Icons.location_on_outlined,
              _buildLocationSection(doctorData),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionWithIcon(
    BuildContext context,
    String title,
    IconData icon,
    Widget content,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: secondaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: primaryColor,
                ),
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildInfoSection(model.DoctorProfileModel doctorData) {
    return Column(
      children: [
        _buildInfoRow('Specialisation', doctorData.specialization ?? 'N/A'),
        SizedBox(height: 12),
        _buildInfoRow('Qualification', doctorData.qualification ?? 'MBBS, MD'),
        SizedBox(height: 12),
        _buildInfoRow('Rating', '4.8'),
        SizedBox(height: 12),
        _buildInfoRow('Years of experience', doctorData.experience ?? '8 +'),
        SizedBox(height: 12),
        _buildInfoRow(
            'Patients attended', doctorData.patientsAttended ?? '2.4K +'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: grey600,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (label == 'Rating')
              Icon(
                Icons.star,
                color: Colors.amber,
                size: 16,
              ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkingHours() {
    return Column(
      children: [
        _buildWorkingRow('Mon-Fri', '08:00-14:00'),
        SizedBox(height: 12),
        _buildWorkingRow('Sat-Sun', '09:00-13:00'),
      ],
    );
  }

  Widget _buildWorkingRow(String days, String hours) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                days,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
        Text(
          hours,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection(model.DoctorProfileModel doctorData) {
    final address = doctorData.address ?? 'Address not available';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLocationCard(
          '09:00 am - 02:00 pm',
          address,
        ),
        SizedBox(height: 16),
        _buildLocationCard(
          '03:00 pm - 08:00 pm',
          address,
        ),
      ],
    );
  }

  Widget _buildLocationCard(String time, String address) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              SizedBox(width: 6),
              Text(
                time,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  address,
                  style: TextStyle(
                    fontSize: 15,
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
