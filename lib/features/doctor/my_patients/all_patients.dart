import 'package:CureBit/common/components/colors.dart';
import 'package:CureBit/common/components/app_header.dart';
import 'package:CureBit/app/features_api_repository/appointment/doctor/previous_patients_provider.dart';
import 'package:CureBit/features/doctor/patient_navigation_utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AllPatientsScreen extends ConsumerStatefulWidget {
  final String doctorCIN;

  const AllPatientsScreen({
    super.key,
    required this.doctorCIN,
  });

  @override
  ConsumerState<AllPatientsScreen> createState() => _AllPatientsScreenState();
}

class _AllPatientsScreenState extends ConsumerState<AllPatientsScreen> {
  final _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Load data on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(previousPatientsProvider(widget.doctorCIN).notifier)
          .loadPatients();
    });

    // Add scroll listener for pagination
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  // Scroll listener for pagination
  void _scrollListener() {
    if (_scrollController.position.extentAfter < 200 && !_isLoadingMore) {
      _loadMorePatients();
    }
  }

  // Load more patients when scrolled to bottom
  Future<void> _loadMorePatients() async {
    final hasMore = ref.read(hasMorePatientsProvider(widget.doctorCIN));

    if (hasMore && !_isLoadingMore) {
      setState(() {
        _isLoadingMore = true;
      });

      await ref
          .read(previousPatientsProvider(widget.doctorCIN).notifier)
          .loadMorePatients();

      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final patientsState = ref.watch(previousPatientsProvider(widget.doctorCIN));
    final patients = patientsState.patients;
    final isLoading = patientsState.isLoading;
    final hasMoreData = patientsState.hasMoreData;
    final errorMessage = patientsState.errorMessage;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFF8F9FB),
        appBar: AppHeader(
          title: 'All Patients',
          onBackPressed: () => context.pop(),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(previousPatientsProvider(widget.doctorCIN).notifier)
                .refreshPatients();
          },
          child: errorMessage.isNotEmpty && patients.isEmpty
              ? _buildErrorView(errorMessage)
              : _buildPatientListView(patients, isLoading, hasMoreData),
        ),
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red.shade300,
          ),
          SizedBox(height: 16),
          Text(
            'Error Loading Patients',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(previousPatientsProvider(widget.doctorCIN).notifier)
                  .loadPatients();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientListView(
      List<PatientData> patients, bool isLoading, bool hasMoreData) {
    if (patients.isEmpty && isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (patients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 60,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16),
            Text(
              'No Patients Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'You don\'t have any patients in your history yet',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24),
      itemCount: patients.length + (hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        // Show loading indicator at the bottom for pagination
        if (index == patients.length) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Regular patient item
        final patient = patients[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildPatientCard(context, patient),
        );
      },
    );
  }

  Widget _buildPatientCard(BuildContext context, PatientData patient) {
    return GestureDetector(
      onTap: () {
        // Use the utility function for navigation
        PatientNavigationUtils.navigateFromPatientData(context, patient);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .04),
              blurRadius: 16,
              spreadRadius: 0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Hero(
                tag: patient.id,
                child: GestureDetector(
                  onTap: () {
                    // Direct navigation when tapping on avatar
                    PatientNavigationUtils.navigateToPatientProfile(
                      context,
                      patientCin: patient.id,
                      patientName: patient.name,
                    );
                  },
                  child: Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: AssetImage(patient.image),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .12),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Navigation when tapping on patient details
                    PatientNavigationUtils.navigateToPatientProfile(
                      context,
                      patientCin: patient.id,
                      patientName: patient.name,
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              patient.name,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: black.withValues(alpha: .9),
                              ),
                            ),
                          ),
                          if (patient.isFavorite)
                            Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 18,
                            ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: .1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              patient.symptoms,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '${patient.age} • ${patient.gender}',
                            style: TextStyle(
                              fontSize: 13,
                              color: grey600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: grey600,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Last visit: ${patient.lastVisit}',
                            style: TextStyle(
                              fontSize: 13,
                              color: grey600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  patient.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: patient.isFavorite ? Colors.red : grey600,
                  size: 24,
                ),
                onPressed: () {
                  ref
                      .read(previousPatientsProvider(widget.doctorCIN).notifier)
                      .toggleFavorite(patient.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
