import 'package:CureBit/app/features_api_repository/profile/public_profile/patient/patient_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:CureBit/app/features_api_repository/profile/public_profile/patient/get/patient_public_model.dart';
import 'package:CureBit/app/features_api_repository/profile/public_profile/patient/get/get_patient_public_provider.dart';
import 'package:CureBit/common/components/app_header.dart';
import 'package:CureBit/common/components/colors.dart';
import 'package:CureBit/common/components/pop_up.dart';
import 'package:CureBit/utils/routes/route_constants.dart';

final PostPublicProfileRepository _profileRepository =
    PostPublicProfileRepository();

Color primaryColor = black;
Color secondaryColor = grey400;

class PatientProfile extends ConsumerStatefulWidget {
  final String? patientCin;

  const PatientProfile({
    super.key,
    this.patientCin,
  });

  @override
  ConsumerState<PatientProfile> createState() => _PatientProfileState();
}

class _PatientProfileState extends ConsumerState<PatientProfile>
    with TickerProviderStateMixin {
  bool isConnected = false;
  bool showConnectionAnimation = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  PatientPublicProfileModel? _patientProfile;
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

    // Fetch patient data when the widget is initialized
    _fetchPatientData();
  }

  Future<void> _fetchPatientData() async {
    if (widget.patientCin == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Patient ID not provided";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final patientProfileNotifier =
          ref.read(patientPublicProfileNotifierProvider.notifier);
      await patientProfileNotifier.loadPatientProfile(widget.patientCin!);

      final profileState = ref.read(patientPublicProfileNotifierProvider);

      if (profileState is AsyncData && profileState.value != null) {
        setState(() {
          _patientProfile = profileState.value;
          _isLoading = false;
        });
      } else if (profileState is AsyncError) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              "Failed to load patient profile: ${profileState.error}";
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
    // Listen to the patient profile provider state
    final patientProfileState = ref.watch(patientPublicProfileNotifierProvider);

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 212, 218, 222),
        appBar: AppHeader(
          title: 'Patient Profile',
          onBackPressed: () => context.goNamed('home'),
        ),
        body: patientProfileState.isLoading || _isLoading
            ? _buildLoadingState()
            : patientProfileState.hasError || _errorMessage != null
                ? _buildErrorState(
                    _errorMessage ?? patientProfileState.error.toString())
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
          Text('Loading patient profile...'),
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
            'Failed to load patient profile',
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
            onPressed: _fetchPatientData,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final patientData = _getPatientData();

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
                    backgroundImage: patientData.profileImageUrl.isNotEmpty
                        ? NetworkImage(patientData.profileImageUrl)
                        : AssetImage('assets/images/girl.jpeg')
                            as ImageProvider,
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
                    // Patient name and details
                    Text(
                      patientData.name,
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
                      '@${patientData.username}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    // Age display
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: .15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cake, color: Colors.blue, size: 20),
                          SizedBox(width: 5),
                          Text(
                            '${patientData.age} years old',
                            style: TextStyle(
                              color: Colors.blue[800],
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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

  // Helper method to get patient data safely
  PatientPublicProfileModel _getPatientData() {
    return _patientProfile ??
        PatientPublicProfileModel(
          cin: widget.patientCin ?? 'Unknown',
          username: 'unknown',
          name: 'Unknown Patient',
          email: '',
          phone: '',
          location: '',
          dateOfBirth: '',
          age: 0,
          joinedDate: '',
          profileImageUrl: '',
        );
  }

  Widget _buildActionButtons() {
    final patientData = _getPatientData();

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
              // Pass patient information to booking screen
              context.goNamed(
                RouteConstants.bookAppointment,
                queryParameters: {
                  'patientCin': patientData.cin,
                  'patientName': patientData.name,
                  'patientAge': patientData.age.toString(),
                },
              );
            } else if (value == 'patientQR') {
              context.goNamed(RouteConstants.helpAndSupport);
            } else if (value == 'clearProfile') {
              _clearPatientProfile();
            } else if (value == 'clearCache') {
              _clearCache();
            }
          },
          optionsList: [
            {'book': 'Book appointment'},
            {'patientQR': 'Patient\'s QR'},
            {'clearProfile': 'Clear Profile'},
            {'clearCache': 'Clear Cache'},
          ],
        ),
      ],
    );
  }

  // Method to clear patient profile
  Future<void> _clearPatientProfile() async {
    if (widget.patientCin == null) return;

    try {
      final clearAction = ref.read(clearPatientProfileActionProvider);
      final result = await clearAction(widget.patientCin!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

// Method to clear cache
  Future<void> _clearCache() async {
    if (widget.patientCin == null) return;

    try {
      final clearCacheAction = ref.read(clearCachePatientPublicProfile);
      final result = await clearCacheAction(widget.patientCin!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear cache: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildInfoCard(BuildContext context) {
    final patientData = _getPatientData();

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
              'Personal Information',
              Icons.person_outline,
              _buildPersonalInfoSection(patientData),
            ),
            Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
            _buildSectionWithIcon(
              context,
              'Contact Information',
              Icons.contact_phone_outlined,
              _buildContactInfoSection(patientData),
            ),
            Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
            _buildSectionWithIcon(
              context,
              'Account Information',
              Icons.account_circle_outlined,
              _buildAccountInfoSection(patientData),
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

  Widget _buildPersonalInfoSection(PatientPublicProfileModel patientData) {
    return Column(
      children: [
        _buildInfoRow('Full Name', patientData.name),
        SizedBox(height: 12),
        _buildInfoRow('Age', '${patientData.age} years'),
        SizedBox(height: 12),
        _buildInfoRow(
            'Date of Birth',
            patientData.dateOfBirth.isNotEmpty
                ? patientData.dateOfBirth
                : 'Not provided'),
        SizedBox(height: 12),
        _buildInfoRow(
            'Location',
            patientData.location.isNotEmpty
                ? patientData.location
                : 'Not provided'),
      ],
    );
  }

  Widget _buildContactInfoSection(PatientPublicProfileModel patientData) {
    return Column(
      children: [
        _buildInfoRow('Email',
            patientData.email.isNotEmpty ? patientData.email : 'Not provided'),
        SizedBox(height: 12),
        _buildInfoRow('Phone',
            patientData.phone.isNotEmpty ? patientData.phone : 'Not provided'),
      ],
    );
  }

  Widget _buildAccountInfoSection(PatientPublicProfileModel patientData) {
    return Column(
      children: [
        _buildInfoRow('Username', '@${patientData.username}'),
        SizedBox(height: 12),
        _buildInfoRow('Patient ID', patientData.cin),
        SizedBox(height: 12),
        _buildInfoRow(
            'Joined Date',
            patientData.joinedDate.isNotEmpty
                ? patientData.joinedDate
                : 'Not available'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: grey600,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
