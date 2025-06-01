import 'package:CureBit/services/features_api_repository/profile/public_profile/patient/get/get_patient_public_provider.dart';
import 'package:CureBit/services/features_api_repository/profile/public_profile/patient/get/patient_public_model.dart';
import 'package:CureBit/common/components/app_header.dart';
import 'package:CureBit/common/components/colors.dart';
import 'package:CureBit/utils/routes/route_constants.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PatientPublicProfile extends ConsumerStatefulWidget {
  final String? cin;

  const PatientPublicProfile({super.key, this.cin});

  @override
  ConsumerState<PatientPublicProfile> createState() =>
      _PatientPublicProfileState();
}

class _PatientPublicProfileState extends ConsumerState<PatientPublicProfile> {
  late String patientCin;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    patientCin = widget.cin ?? 'default_cin';

    // Set the current patient CIN in the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentPatientCinProvider.notifier).state = patientCin;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double profileImageSize = screenSize.width * 0.25;

    // Watch the patient profile
    final profileAsyncValue =
        ref.watch(patientPublicProfileProvider(patientCin));

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
              context.pushNamed(RouteConstants.editPublicProfile);
            },
          ),
          // Add refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshProfile(),
          ),
        ],
      ),
      backgroundColor: greyWithGreenTint,
      body: profileAsyncValue.when(
        data: (profile) => profile != null
            ? _buildProfileContent(profile, profileImageSize)
            : const Center(child: Text('Profile not found')),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _buildErrorWidget(error),
      ),
    );
  }

  Widget _buildProfileContent(
      PatientPublicProfileModel profile, double profileImageSize) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(profile, profileImageSize),
          _buildInformationSection(profile),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error loading profile',
            style: TextStyle(fontSize: 18, color: grey600),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: TextStyle(fontSize: 14, color: grey400),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshProfile,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(
      PatientPublicProfileModel profile, double imageSize) {
    return Container(
      width: double.infinity,
      color: white,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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
                      color: black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: CircleAvatar(
                    backgroundImage: profile.profileImageUrl.isNotEmpty
                        ? NetworkImage(profile.profileImageUrl)
                        : const AssetImage(
                                'assets/images/PatientPublicProfile.png')
                            as ImageProvider,
                    backgroundColor: grey200,
                    radius: imageSize / 2,
                  ),
                ),
              ),
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
          Text(
            '${profile.cin}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                profile.location,
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
                'Joined ${profile.joinedDate}',
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

  Widget _buildInformationSection(PatientPublicProfileModel profile) {
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
          _buildInfoItem(
            icon: Icons.language,
            label: 'Date of Birth',
            value: profile.dateOfBirth,
            description: 'Age: ${profile.age} yrs',
          ),
          const _ProfileDivider(),
          _buildInfoItem(
            icon: Icons.mail,
            label: 'Email',
            value: profile.email,
          ),
          const _ProfileDivider(),
          _buildInfoItem(
            icon: Icons.phone,
            label: 'Phone',
            value: profile.phone,
            description: 'Mobile',
          ),
          const _ProfileDivider(),
          _buildInfoItem(
            icon: Icons.calendar_today,
            label: 'Joined',
            value: profile.joinedDate,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _clearProfile,
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _clearCache,
                  icon: const Icon(Icons.cached),
                  label: const Text('Clear Cache'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
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
                    color: grey800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Action methods
  void _refreshProfile() {
    ref.invalidate(patientPublicProfileProvider(patientCin));
  }

  Future<void> _clearProfile() async {
    try {
      final clearAction = ref.read(clearPatientProfileActionProvider);
      final result = await clearAction(patientCin);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile cleared: $result'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error clearing profile: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearCache() async {
    try {
      final clearAction = ref.read(clearCachePatientPublicProfile);
      final result = await clearAction(patientCin);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cache cleared: $result'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the profile after clearing cache
        _refreshProfile();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error clearing cache: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
