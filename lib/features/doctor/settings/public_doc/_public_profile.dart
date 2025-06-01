import 'package:CureBit/app/features_api_repository/profile/public_profile/doctor/get/doctor_model.dart';
import 'package:CureBit/app/features_api_repository/profile/public_profile/doctor/get/get_doc_public_provider.dart';
import 'package:CureBit/common/components/app_header.dart';
import 'package:CureBit/common/components/colors.dart';
import 'package:CureBit/utils/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Import your provider and model files here
// import 'package:CureBit/path/to/your/provider_file.dart';
// import 'package:CureBit/path/to/doctor_model.dart';

class DoctorPublicProfile extends ConsumerStatefulWidget {
  final String? cin; // CIN parameter for API call

  const DoctorPublicProfile({
    super.key,
    this.cin,
  });

  @override
  ConsumerState<DoctorPublicProfile> createState() =>
      _DoctorPublicProfileState();
}

class _DoctorPublicProfileState extends ConsumerState<DoctorPublicProfile> {
  String get doctorCin =>
      widget.cin ?? 'default_cin'; // Provide default or get from auth

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Trigger the API call when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(doctorProfileNotifierProvider.notifier)
          .getDoctorPublicProfile(doctorCin);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider state
    final profileState = ref.watch(doctorProfileNotifierProvider);

    // Get screen size information
    final Size screenSize = MediaQuery.of(context).size;
    final double profileImageSize = screenSize.width * 0.25;

    return Scaffold(
      appBar: AppHeader(
        onBackPressed: () {
          Navigator.pop(context);
        },
        title: 'Public Profile',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_outlined),
            onPressed: () {
              context.pushNamed(RouteConstants.doctorEditPublicProfile);
            },
          ),
          // Add refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref
                  .read(doctorProfileNotifierProvider.notifier)
                  .getDoctorPublicProfile(doctorCin);
            },
          ),
        ],
      ),
      backgroundColor: greyWithGreenTint,
      body: profileState.when(
        data: (responseString) {
          DoctorProfileModel? doctorProfile;
          try {
            if (responseString != null && responseString.isNotEmpty) {
              doctorProfile =
                  DoctorProfileModel.fromResponseString(responseString);
            }
          } catch (e) {
            debugPrint('Error parsing doctor profile: $e');
          }
          return _buildProfileContent(profileImageSize, doctorProfile);
        },
        loading: () => _buildLoadingState(),
        error: (error, stackTrace) => _buildErrorState(error),
      ),
    );
  }

  Widget _buildProfileContent(
      double profileImageSize, DoctorProfileModel? doctorProfile) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header with Image
          _buildProfileHeader(profileImageSize, doctorProfile),

          // Information Section
          _buildInformationSection(doctorProfile),

          // Additional sections if doctor profile has more data
          if (doctorProfile?.bio != null && doctorProfile!.bio!.isNotEmpty)
            _buildBioSection(doctorProfile.bio!),

          if (doctorProfile?.specialization != null)
            _buildSpecializationSection(doctorProfile!),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading profile...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                ref
                    .read(doctorProfileNotifierProvider.notifier)
                    .getDoctorPublicProfile(doctorCin);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBioSection(String bio) {
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
          const Text(
            'About',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            bio,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecializationSection(DoctorProfileModel doctorProfile) {
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
          const Text(
            'Specialization',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Specialization chip
          if (doctorProfile.specialization != null)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildSpecialtyChip(doctorProfile.specialization!),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSpecialtyChip(String specialty) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border.all(color: Colors.blue[200]!),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(
        specialty,
        style: TextStyle(
          fontSize: 14,
          color: Colors.blue[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
      double imageSize, DoctorProfileModel? doctorProfile) {
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
                      color: black.withValues(alpha: .2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3.0), // Border padding
                  child: CircleAvatar(
                    backgroundImage: const AssetImage(
                        'assets/images/DoctorPublicProfile.png'),
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

          // Username handle (use CIN or generate from name)
          Text(
            '@${doctorProfile?.cin ?? 'doctor'}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 4),

          // Name (from API or fallback)
          Text(
            doctorProfile?.name ?? 'Doctor Name',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          // Specialization
          if (doctorProfile?.specialization != null)
            Text(
              doctorProfile!.specialization!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue[700],
                fontWeight: FontWeight.w500,
              ),
            ),

          const SizedBox(height: 8),

          // Location and Experience
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (doctorProfile?.address != null) ...[
                Flexible(
                  child: Text(
                    doctorProfile!.address!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (doctorProfile?.experience != null) ...[
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
                    '${doctorProfile!.experience!} exp',
                    style: TextStyle(
                      fontSize: 14,
                      color: grey600,
                    ),
                  ),
                ],
              ] else if (doctorProfile?.experience != null)
                Text(
                  '${doctorProfile!.experience!} experience',
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

  Widget _buildInformationSection(DoctorProfileModel? doctorProfile) {
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

          // Build info items dynamically based on available data
          ..._buildDynamicInfoItems(doctorProfile),
        ],
      ),
    );
  }

  List<Widget> _buildDynamicInfoItems(DoctorProfileModel? doctorProfile) {
    List<Widget> items = [];

    // Qualification
    if (doctorProfile?.qualification != null &&
        doctorProfile!.qualification!.isNotEmpty) {
      items.add(_buildInfoItem(
        icon: Icons.school,
        label: 'Qualification',
        value: doctorProfile.qualification!,
      ));
      items.add(const _ProfileDivider());
    }

    // Email
    if (doctorProfile?.email != null && doctorProfile!.email!.isNotEmpty) {
      items.add(_buildInfoItem(
        icon: Icons.mail,
        label: 'Email',
        value: doctorProfile.email!,
      ));
      items.add(const _ProfileDivider());
    }

    // Phone
    if (doctorProfile?.phone != null && doctorProfile!.phone!.isNotEmpty) {
      items.add(_buildInfoItem(
        icon: Icons.phone,
        label: 'Phone',
        value: doctorProfile.phone!,
        description: 'Mobile',
      ));
      items.add(const _ProfileDivider());
    }

    // Address
    if (doctorProfile?.address != null && doctorProfile!.address!.isNotEmpty) {
      items.add(_buildInfoItem(
        icon: Icons.location_on,
        label: 'Address',
        value: doctorProfile.address!,
      ));
      items.add(const _ProfileDivider());
    }

    // Working Time
    if (doctorProfile?.workingTime != null &&
        doctorProfile!.workingTime!.isNotEmpty) {
      items.add(_buildInfoItem(
        icon: Icons.access_time,
        label: 'Working Hours',
        value: doctorProfile.workingTime!,
      ));
      items.add(const _ProfileDivider());
    }

    // Patients Attended
    if (doctorProfile?.patientsAttended != null &&
        doctorProfile!.patientsAttended!.isNotEmpty) {
      items.add(_buildInfoItem(
        icon: Icons.people,
        label: 'Patients Attended',
        value: doctorProfile.patientsAttended!,
      ));
      items.add(const _ProfileDivider());
    }

    // Experience
    if (doctorProfile?.experience != null &&
        doctorProfile!.experience!.isNotEmpty) {
      items.add(_buildInfoItem(
        icon: Icons.work,
        label: 'Experience',
        value: doctorProfile.experience!,
      ));
      items.add(const _ProfileDivider());
    }

    // CIN
    if (doctorProfile?.cin != null && doctorProfile!.cin!.isNotEmpty) {
      items.add(_buildInfoItem(
        icon: Icons.badge,
        label: 'CIN',
        value: doctorProfile.cin!,
      ));
    }

    // Remove last divider if items exist
    if (items.isNotEmpty && items.last is _ProfileDivider) {
      items.removeLast();
    }

    // If no data available, show placeholder
    if (items.isEmpty) {
      items.add(
        const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'No information available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      );
    }

    return items;
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
