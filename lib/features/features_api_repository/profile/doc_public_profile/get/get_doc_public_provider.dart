import 'package:CuraDocs/features/features_api_repository/profile/doc_public_profile/get/get_doctor_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the DoctorRepository
final doctorRepositoryProvider = Provider<GetDoctorProfileRepository>((ref) {
  final repository = GetDoctorProfileRepository(
    baseUrl:
        'https://your-api-base-url.com', // Replace with your actual API base URL
  );

  // Make sure to dispose of the repository when the provider is disposed
  ref.onDispose(() {
    repository.dispose();
  });

  return repository;
});

/// Provider for fetching doctor public profile data
final doctorPublicProfileProvider =
    FutureProvider.family<String, String>((ref, cin) async {
  final repository = ref.watch(doctorRepositoryProvider);
  return await repository.getDoctorPublicProfileData(cin);
});

/// Provider for clearing doctor public profile data
final clearDoctorPublicProfileProvider =
    FutureProvider.family<String, String>((ref, cin) async {
  final repository = ref.watch(doctorRepositoryProvider);
  return await repository.clearDoctorPublicProfileData(cin);
});

/// Provider for clearing cache of doctor public profile data
final clearCacheDoctorPublicProfileProvider =
    FutureProvider.family<String, String>((ref, cin) async {
  final repository = ref.watch(doctorRepositoryProvider);
  return await repository.clearCacheDoctorPublicProfileData(cin);
});

/// Provider for managing doctor profile data operations with loading and error states
class DoctorProfileNotifier extends StateNotifier<AsyncValue<String?>> {
  final GetDoctorProfileRepository _repository;

  DoctorProfileNotifier(this._repository) : super(const AsyncValue.loading());

  Future<void> getDoctorPublicProfile(String cin) async {
    state = const AsyncValue.loading();
    try {
      final data = await _repository.getDoctorPublicProfileData(cin);
      state = AsyncValue.data(data);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> clearDoctorPublicProfile(String cin) async {
    state = const AsyncValue.loading();
    try {
      final data = await _repository.clearDoctorPublicProfileData(cin);
      state = AsyncValue.data(data);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> clearCacheDoctorPublicProfile(String cin) async {
    state = const AsyncValue.loading();
    try {
      final data = await _repository.clearCacheDoctorPublicProfileData(cin);
      state = AsyncValue.data(data);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

/// Provider for the DoctorProfileNotifier
final doctorProfileNotifierProvider =
    StateNotifierProvider<DoctorProfileNotifier, AsyncValue<String?>>((ref) {
  final repository = ref.watch(doctorRepositoryProvider);
  return DoctorProfileNotifier(repository);
});
