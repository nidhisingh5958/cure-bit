import 'package:CuraDocs/app/user/user_helper.dart';
import 'package:CuraDocs/common/components/app_header.dart';
import 'package:CuraDocs/common/components/colors.dart';
import 'package:CuraDocs/app/features_api_repository/profile/private_profile/get_private_repository.dart';
import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DoctorPersonalProfile extends ConsumerStatefulWidget {
  const DoctorPersonalProfile({super.key});

  @override
  ConsumerState<DoctorPersonalProfile> createState() =>
      _DoctorPersonalProfileState();
}

class _DoctorPersonalProfileState extends ConsumerState<DoctorPersonalProfile> {
  late final String _cin;

  @override
  void initState() {
    _cin = UserHelper.getUserAttribute<String>(ref, 'cin') ?? '';
    super.initState();
    // Prefetch the doctor profile data when the screen is loaded
    Future.microtask(() => ref.read(doctorProfileDataProvider(_cin).future));
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size information
    final Size screenSize = MediaQuery.of(context).size;
    final double profileImageSize =
        screenSize.width * 0.25; // 25% of screen width

    // Watch the doctor profile data
    final profileDataAsync = ref.watch(doctorProfileDataProvider(_cin));

    return Scaffold(
      appBar: AppHeader(
        onBackPressed: () {
          Navigator.pop(context);
        },
        title: 'Account Details',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_outlined),
            onPressed: () {
              context.pushNamed(RouteConstants.editProfile);
            },
          ),
          // Add refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              try {
                // Show a loading indicator
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Refreshing profile data...')));

                // Call the refresh cache provider
                final result = await ref
                    .read(refreshDoctorProfileCacheProvider(_cin).future);

                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(result.message)));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error refreshing cache: $e')));
                }
              }
            },
          ),
        ],
      ),
      backgroundColor: greyWithGreenTint,
      body: profileDataAsync.when(
        data: (profileData) {
          // Parse the profile data
          final Map<String, dynamic> profile =
              profileData is Map<String, dynamic>
                  ? profileData
                  : {'name': 'Livy Sheleina'};

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header with Image
                _buildProfileHeader(profileImageSize, profile),

                // Information Section
                _buildInformationSection(profile),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error loading profile data: $error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(doctorProfileDataProvider(_cin));
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(double imageSize, Map<String, dynamic> profile) {
    final String username = profile['username'] ?? '@livysheleina';
    final String name = profile['name'] ?? 'Livy Sheleina';
    final String location = profile['location'] ?? 'New York';
    final String joinDate = profile['joined_date'] ?? 'August 2023';

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
                    backgroundImage: const AssetImage(
                        'assets/images/DoctorPersonalProfile.png'),
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

          // DoctorPersonalProfilename handle
          Text(
            username,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 4),

          // Name
          Text(
            name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          // Location and Join date
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                location,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                ),
              ),
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
                'Joined $joinDate',
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

  Widget _buildInformationSection(Map<String, dynamic> profile) {
    final String dob = profile['date_of_birth'] ?? 'January 1, 1990';
    final String age = profile['age'] ?? '35 yrs 4 months';
    final String email = profile['email'] ?? 'sh.agency@gmail.com';
    final String phone = profile['phone'] ?? '+62 878 XXX XXX';
    final String phoneType = profile['phone_type'] ?? 'Mobile';
    final String joined = profile['joined_date'] ?? 'August 2023';

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

          // Date of Birth
          _buildInfoItem(
            icon: Icons.calendar_today,
            label: 'Date of Birth',
            value: dob,
            description: 'Age: $age',
          ),

          const _ProfileDivider(),

          // Email
          _buildInfoItem(
            icon: Icons.mail,
            label: 'Email',
            value: email,
          ),

          const _ProfileDivider(),

          // Phone
          _buildInfoItem(
            icon: Icons.phone,
            label: 'Phone',
            value: phone,
            description: phoneType,
          ),

          const _ProfileDivider(),

          // Joined
          _buildInfoItem(
            icon: Icons.calendar_today,
            label: 'Joined',
            value: joined,
          ),
        ],
      ),
    );
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
