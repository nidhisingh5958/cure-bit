import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:CureBit/services/features_api_repository/search/internal_search/patient_search_repository.dart';

// State class for patient search
class PatientSearchState {
  final List<dynamic> searchResults;
  final bool isLoading;
  final String errorMessage;
  final String query;

  PatientSearchState({
    this.searchResults = const [],
    this.isLoading = false,
    this.errorMessage = '',
    this.query = '',
  });

  PatientSearchState copyWith({
    List<dynamic>? searchResults,
    bool? isLoading,
    String? errorMessage,
    String? query,
  }) {
    return PatientSearchState(
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      query: query ?? this.query,
    );
  }
}

// Repository provider
final patientSearchRepositoryProvider =
    Provider<PatientSearchRepository>((ref) {
  return PatientSearchRepository();
});

// Patient search state notifier
class PatientSearchNotifier extends StateNotifier<PatientSearchState> {
  final PatientSearchRepository _repository;
  final String doctorCIN;

  PatientSearchNotifier(this._repository, this.doctorCIN)
      : super(PatientSearchState());

  Future<void> searchPatients(String query) async {
    if (query.isEmpty) {
      state = PatientSearchState(query: query);
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: '', query: query);

    try {
      final results = await _repository.searchPatients(query, doctorCIN);
      state = state.copyWith(
        searchResults: results,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error searching patients: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  Future<void> refreshSearchIndex() async {
    state = state.copyWith(isLoading: true, errorMessage: '');

    try {
      await _repository.refreshSearchIndex(state.query, doctorCIN);
      // After refreshing, search again with the current query
      await searchPatients(state.query);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error refreshing data: ${e.toString()}',
        isLoading: false,
      );
    }
  }
}

// Provider family for patient search based on doctor CIN
final patientSearchProvider = StateNotifierProvider.family<
    PatientSearchNotifier, PatientSearchState, String>(
  (ref, doctorCIN) => PatientSearchNotifier(
    ref.watch(patientSearchRepositoryProvider),
    doctorCIN,
  ),
);
