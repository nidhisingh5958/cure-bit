import 'package:CuraDocs/common/components/colors.dart';
import 'package:CuraDocs/common/components/app_header.dart';
import 'package:CuraDocs/common/components/pop_up.dart';
import 'package:CuraDocs/app/features_api_repository/profile/doc_public_profile/get/get_doc_public_provider.dart';
import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:CuraDocs/app/features_api_repository/profile/doc_public_profile/get/doctor_model.dart'
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
  ConsumerState<DoctorProfile> createState() => _ProfileState();
}

class _ProfileState extends ConsumerState<DoctorProfile>
    with TickerProviderStateMixin {
  bool isConnected = false;
  bool showConnectionAnimation = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  model.DoctorProfileModel? _doctorProfile;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
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

    // Fetch doctor data when the widget is initialized
    _fetchDoctorData();
  }

  Future<void> _fetchDoctorData() async {
    if (widget.doctorCin == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Doctor ID not provided";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final doctorProfileNotifier =
          ref.read(doctorProfileNotifierProvider.notifier);
      await doctorProfileNotifier.getDoctorPublicProfile(widget.doctorCin!);

      final profileState = ref.read(doctorProfileNotifierProvider);

      if (profileState is AsyncData && profileState.value != null) {
        try {
          // Parse the JSON string to create a DoctorProfile object
          final doctorProfile =
              model.DoctorProfileModel.fromResponseString(profileState.value!);
          setState(() {
            _doctorProfile = doctorProfile;
            _isLoading = false;
          });
        } catch (parseError) {
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
      setState(() {
        _isLoading = false;
        _errorMessage = "Error: ${e.toString()}";
      });
    }
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

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 212, 218, 222),
        appBar: AppHeader(
          title: 'Patient Profile',
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
                        _buildProfileHeader(context),
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
            child: Text('Retry'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
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
                      doctorData.name,
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
                      doctorData.specialty ?? 'Specialist',
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
                    _buildActionButtons(),
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
          cin: widget.doctorCin ?? 'Unknown',
          name: 'Dr. Unknown',
        );
  }

  Widget _buildActionButtons() {
    final doctorData = _getDoctorData();

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
            onPressed: () {
              if (!isConnected) {
                setState(() {
                  showConnectionAnimation = true;
                  isConnected = true;
                });
                _animationController.forward();
              } else {
                setState(() {
                  isConnected = false;
                });
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
            child: Row(
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
                  'doctorCin': doctorData.cin,
                  'doctorName': doctorData.name,
                  'doctorSpecialty': doctorData.specialty ?? '',
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
        _buildInfoRow('Specialisation', doctorData.specialty ?? 'N/A'),
        SizedBox(height: 12),
        _buildInfoRow('Qualification',
            'MBBS, MD'), // Replace with actual data when available
        SizedBox(height: 12),
        _buildInfoRow(
            'Rating', '4.8'), // Replace with actual data when available
        SizedBox(height: 12),
        _buildInfoRow('Years of experience',
            '8 +'), // Replace with actual data when available
        SizedBox(height: 12),
        _buildInfoRow('Patients attended',
            '2.4K +'), // Replace with actual data when available
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLocationCard(
          '09:00 am - 02:00 pm',
          doctorData.address ?? 'Address not available',
        ),
        SizedBox(height: 16),
        _buildLocationCard(
          '03:00 pm - 08:00 pm',
          doctorData.address ?? 'Address not available',
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
