import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:CureBit/services/features_api_repository/profile/public_profile/patient/get/patient_public_model.dart';
import 'package:CureBit/services/features_api_repository/profile/public_profile/patient/get/get_patient_public_repository.dart';
import 'package:CureBit/services/features_api_repository/api_constant.dart';

// Repository provider
final patientPublicProfileRepositoryProvider =
    Provider<PatientPublicProfileRepository>((ref) {
  return PatientPublicProfileRepository(
    baseUrl: patientPublicProfile,
  );
});

// Current patient CIN state provider
final currentPatientCinProvider = StateProvider<String>((ref) => '');

// StateNotifier for managing patient profile state
class PatientPublicProfileNotifier
    extends StateNotifier<AsyncValue<PatientPublicProfileModel?>> {
  final PatientPublicProfileRepository _repository;

  PatientPublicProfileNotifier(this._repository)
      : super(const AsyncValue.data(null));

  Future<void> loadPatientProfile(String cin) async {
    if (cin.isEmpty || cin == 'default_cin') {
      state = const AsyncValue.data(null);
      return;
    }

    state = const AsyncValue.loading();

    try {
      final profile = await _repository.getPatientPublicProfile(cin);
      state = AsyncValue.data(profile);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> clearProfile(String cin) async {
    try {
      await _repository.clearPatientPublicProfile(cin);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> clearCache(String cin) async {
    try {
      await _repository.clearCachePatientPublicProfile(cin);
      // Reload the profile after clearing cache
      await loadPatientProfile(cin);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// StateNotifierProvider for patient profile
final patientPublicProfileNotifierProvider = StateNotifierProvider<
    PatientPublicProfileNotifier,
    AsyncValue<PatientPublicProfileModel?>>((ref) {
  final repository = ref.read(patientPublicProfileRepositoryProvider);
  return PatientPublicProfileNotifier(repository);
});

// Patient public profile data provider (keeping for backward compatibility)
final patientPublicProfileProvider =
    FutureProvider.family<PatientPublicProfileModel?, String>((ref, cin) async {
  if (cin.isEmpty || cin == 'default_cin') return null;

  final repository = ref.read(patientPublicProfileRepositoryProvider);

  try {
    final profile = await repository.getPatientPublicProfile(cin);
    return profile;
  } catch (e) {
    print('Error fetching profile for CIN $cin: $e');
    throw e;
  }
});

// Clear patient profile action provider (updated to use the notifier)
final clearPatientProfileActionProvider =
    Provider<Future<String> Function(String)>((ref) {
  return (String cin) async {
    final repository = ref.read(patientPublicProfileRepositoryProvider);

    try {
      final result = await repository.clearPatientPublicProfile(cin);

      // Update the notifier state
      ref.read(patientPublicProfileNotifierProvider.notifier).clearProfile(cin);

      // Also invalidate the family provider
      ref.invalidate(patientPublicProfileProvider(cin));

      return result ?? 'Profile cleared successfully';
    } catch (e) {
      throw Exception('Failed to clear profile: $e');
    }
  };
});

// Clear cache action provider (updated to use the notifier)
final clearCachePatientPublicProfile =
    Provider<Future<String> Function(String)>((ref) {
  return (String cin) async {
    final repository = ref.read(patientPublicProfileRepositoryProvider);

    try {
      final result = await repository.clearCachePatientPublicProfile(cin);

      // Update the notifier state
      ref.read(patientPublicProfileNotifierProvider.notifier).clearCache(cin);

      // Also invalidate the family provider
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
