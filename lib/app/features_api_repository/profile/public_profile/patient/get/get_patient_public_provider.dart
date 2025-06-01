import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:CureBit/app/features_api_repository/profile/public_profile/patient/get/patient_public_model.dart';
import 'package:CureBit/app/features_api_repository/profile/public_profile/patient/get/get_patient_public_repository.dart';
import 'package:CureBit/app/features_api_repository/api_constant.dart';

// Repository provider
final patientPublicProfileRepositoryProvider =
    Provider<PatientPublicProfileRepository>((ref) {
  return PatientPublicProfileRepository(
    baseUrl:
        patientPublicProfile, // Make sure this constant exists in api_constant.dart
  );
});

// Current patient CIN state provider
final currentPatientCinProvider = StateProvider<String>((ref) => '');

// Patient public profile data provider
final patientPublicProfileProvider =
    FutureProvider.family<PatientPublicProfileModel?, String>((ref, cin) async {
  if (cin.isEmpty || cin == 'default_cin') return null;

  final repository = ref.read(patientPublicProfileRepositoryProvider);

  try {
    final profile = await repository.getPatientPublicProfile(cin);
    return profile;
  } catch (e) {
    // Log the error but don't throw it, return null instead
    print('Error fetching profile for CIN $cin: $e');
    throw e; // Re-throw so the UI can handle the error state
  }
});

// Clear patient profile action provider
final clearPatientProfileActionProvider =
    Provider<Future<String> Function(String)>((ref) {
  return (String cin) async {
    final repository = ref.read(patientPublicProfileRepositoryProvider);

    try {
      final result = await repository.clearPatientPublicProfile(cin);

      // Invalidate the profile data after clearing
      ref.invalidate(patientPublicProfileProvider(cin));

      return result ?? 'Profile cleared successfully';
    } catch (e) {
      throw Exception('Failed to clear profile: $e');
    }
  };
});

// Clear cache action provider
final clearCacheActionProvider =
    Provider<Future<String> Function(String)>((ref) {
  return (String cin) async {
    final repository = ref.read(patientPublicProfileRepositoryProvider);

    try {
      final result = await repository.clearCachePatientPublicProfile(cin);

      // Invalidate the profile data after clearing cache
      ref.invalidate(patientPublicProfileProvider(cin));

      return result ?? 'Cache cleared successfully';
    } catch (e) {
      throw Exception('Failed to clear cache: $e');
    }
  };
});

// Auto-refresh provider (optional - for periodic updates)
final autoRefreshProvider =
    StreamProvider.family<PatientPublicProfileModel?, String>((ref, cin) {
  return Stream.periodic(const Duration(minutes: 5), (count) async {
    if (cin.isEmpty || cin == 'default_cin') return null;

    final repository = ref.read(patientPublicProfileRepositoryProvider);
    try {
      return await repository.getPatientPublicProfile(cin);
    } catch (e) {
      return null;
    }
  }).asyncMap((futureProfile) => futureProfile);
});
