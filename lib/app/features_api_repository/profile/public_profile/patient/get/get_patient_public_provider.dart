import 'package:CuraDocs/app/features_api_repository/api_constant.dart';
import 'package:CuraDocs/app/features_api_repository/profile/public_profile/patient/get/get_patient_public_repository.dart';
import 'package:CuraDocs/app/features_api_repository/profile/public_profile/patient/get/patient_public_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Repository Provider
final patientPublicProfileRepositoryProvider =
    Provider<PatientPublicProfileRepository>((ref) {
  return PatientPublicProfileRepository(
    baseUrl: patientPublicProfile,
  );
});

// Patient Public Profile Provider - fetches data based on CIN
final patientPublicProfileProvider =
    FutureProvider.family<PatientPublicProfileModel, String>((ref, cin) async {
  final repository = ref.read(patientPublicProfileRepositoryProvider);
  return repository.getPatientPublicProfile(cin);
});

// State Notifier for managing patient profile state with additional actions
class PatientPublicProfileNotifier
    extends StateNotifier<AsyncValue<PatientPublicProfileModel?>> {
  final PatientPublicProfileRepository _repository;

  PatientPublicProfileNotifier(this._repository)
      : super(const AsyncValue.data(null));

  // Load patient profile
  Future<void> loadPatientProfile(String cin) async {
    state = const AsyncValue.loading();
    try {
      final profile = await _repository.getPatientPublicProfile(cin);
      state = AsyncValue.data(profile);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Clear patient profile data
  Future<String?> clearPatientProfile(String cin) async {
    try {
      final result = await _repository.clearPatientPublicProfile(cin);
      // Optionally reload the profile after clearing
      await loadPatientProfile(cin);
      return result;
    } catch (error) {
      // Handle error appropriately
      rethrow;
    }
  }

  // Clear cache
  Future<String?> clearCache(String cin) async {
    try {
      final result = await _repository.clearCachePatientPublicProfile(cin);
      return result;
    } catch (error) {
      rethrow;
    }
  }

  // Refresh profile data
  Future<void> refresh(String cin) async {
    await loadPatientProfile(cin);
  }

  // Update profile locally (for optimistic updates)
  void updateProfile(PatientPublicProfileModel updatedProfile) {
    state = AsyncValue.data(updatedProfile);
  }
}

// State Notifier Provider
final patientPublicProfileNotifierProvider = StateNotifierProvider<
    PatientPublicProfileNotifier,
    AsyncValue<PatientPublicProfileModel?>>((ref) {
  final repository = ref.read(patientPublicProfileRepositoryProvider);
  return PatientPublicProfileNotifier(repository);
});

// Provider for current patient CIN (you might want to get this from authentication or routing)
final currentPatientCinProvider = StateProvider<String?>((ref) => null);

// Combined provider that automatically fetches profile when CIN changes
final currentPatientProfileProvider =
    Provider<AsyncValue<PatientPublicProfileModel?>>((ref) {
  final cin = ref.watch(currentPatientCinProvider);

  if (cin == null) {
    return const AsyncValue.data(null);
  }

  return ref.watch(patientPublicProfileProvider(cin));
});

// Action providers for UI interactions
final clearPatientProfileActionProvider = Provider((ref) {
  return (String cin) async {
    final notifier = ref.read(patientPublicProfileNotifierProvider.notifier);
    return await notifier.clearPatientProfile(cin);
  };
});

final clearCacheActionProvider = Provider((ref) {
  return (String cin) async {
    final notifier = ref.read(patientPublicProfileNotifierProvider.notifier);
    return await notifier.clearCache(cin);
  };
});

final refreshProfileActionProvider = Provider((ref) {
  return (String cin) async {
    final notifier = ref.read(patientPublicProfileNotifierProvider.notifier);
    await notifier.refresh(cin);
  };
});
