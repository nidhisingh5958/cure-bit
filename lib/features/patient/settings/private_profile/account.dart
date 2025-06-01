import 'package:CureBit/app/user/user_helper.dart';
import 'package:CureBit/common/components/app_header.dart';
import 'package:CureBit/common/components/colors.dart';
import 'package:CureBit/app/features_api_repository/profile/private_profile/get_private_repository.dart';
import 'package:CureBit/utils/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PersonalProfile extends ConsumerStatefulWidget {
  const PersonalProfile({super.key});

  @override
  ConsumerState<PersonalProfile> createState() => _PersonalProfileState();
}

class _PersonalProfileState extends ConsumerState<PersonalProfile> {
  String? _cin;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize CIN here where inherited widgets are available
    if (!_isInitialized) {
      _cin = UserHelper.getUserAttribute<String>(ref, 'cin') ?? 'VHUZ8128';
      _isInitialized = true;

      // Prefetch profile data after CIN is available
      if (_cin != null && _cin!.isNotEmpty) {
        Future.microtask(
            () => ref.read(patientProfileDataProvider(_cin!).future));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Return loading if CIN is not yet initialized
    if (!_isInitialized || _cin == null || _cin!.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Get screen size information
    final Size screenSize = MediaQuery.of(context).size;
    final double profileImageSize = screenSize.width * 0.25;

    final profileDataAsync = ref.watch(patientProfileDataProvider(_cin!));

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
                    .read(refreshPatientProfileCacheProvider(_cin!).future);

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
                    ref.invalidate(patientProfileDataProvider(_cin!));
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
    final String cin = profile['cin'] ?? 'VHUZ8128';
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
                    backgroundImage:
                        const AssetImage('assets/images/PersonalProfile.png'),
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

          // PersonalProfilename handle
          Text(
            cin,
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
    final String phone = profile['phone'] ?? '+92134567898';
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
                    color: grey600,
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
      color: black,
      thickness: 1,
      indent: 20,
      endIndent: 20,
    );
  }
}
