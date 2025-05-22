import 'package:CuraDocs/common/components/colors.dart';
import 'package:CuraDocs/common/components/app_header.dart';
import 'package:CuraDocs/app/features_api_repository/search/internal_search/patient_search_provider.dart';
import 'package:CuraDocs/app/features_api_repository/appointment/doctor/previous_patients_provider.dart';
import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyPatientsScreen extends ConsumerStatefulWidget {
  const MyPatientsScreen({super.key});

  @override
  ConsumerState<MyPatientsScreen> createState() => _MyPatientsScreenState();
}

class _MyPatientsScreenState extends ConsumerState<MyPatientsScreen> {
  String docName = "John Doe";
  String specialization = "Cardiologist";
  String doctorCIN =
      "DOC123456"; // Add your doctor CIN here or get it from a provider
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  final int _maxPatientsToShow = 10; // Maximum patients to show on main screen

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    // Load patient data on widget initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(previousPatientsProvider(doctorCIN).notifier).loadPatients();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      setState(() {
        _isSearching = true;
      });
      ref.read(patientSearchProvider(doctorCIN).notifier).searchPatients(query);
    } else {
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(patientSearchProvider(doctorCIN));
    final patientsState = ref.watch(previousPatientsProvider(doctorCIN));
    final isLoading = patientsState.isLoading;
    final patients = patientsState.patients;
    final hasError = patientsState.errorMessage.isNotEmpty;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFF8F9FB),
        appBar: AppHeader(
          title: 'My Patients',
          actions: [
            IconButton(
              icon: Icon(LucideIcons.heart),
              style: IconButton.styleFrom(
                backgroundColor: transparent,
                foregroundColor: black.withValues(alpha: .7),
                padding: const EdgeInsets.all(12),
              ),
              onPressed: () {
                context.goNamed(RouteConstants.favouritePatients);
              },
            ),
            IconButton(
              icon: Icon(LucideIcons.bell),
              style: IconButton.styleFrom(
                backgroundColor: transparent,
                foregroundColor: black.withValues(alpha: .7),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onPressed: () {
                // Navigate to notifications
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(previousPatientsProvider(doctorCIN).notifier)
                .refreshPatients();
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfile(context),
                _buildSearchBar(context),
                SizedBox(height: 24),
                _isSearching
                    ? _buildSearchResults(context, searchState)
                    : _buildPatientList(context, patients, isLoading, hasError),
              ],
            ),
          ),
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     context.goNamed(RouteConstants.addPatient);
        //   },
        //   backgroundColor: Theme.of(context).colorScheme.primary,
        //   child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildProfile(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: .08),
            transparent,
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: black.withValues(alpha: .12),
                  blurRadius: 12,
                  spreadRadius: 0,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 42,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage("images/doctor.jpg"),
              ),
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dr. $docName',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: black.withValues(alpha: .9),
                  ),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
                SizedBox(height: 6),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    specialization,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: .7),
                        size: 18),
                    SizedBox(width: 5),
                    Text(
                      'Delhi, India',
                      style: TextStyle(
                        color: grey600,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down,
                        size: 16, color: Colors.grey[600]),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: black.withValues(alpha: .06),
              blurRadius: 12,
              spreadRadius: 0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search patients...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                  hintStyle: TextStyle(
                    color: grey400,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: grey600,
                    size: 20,
                  ),
                ),
                style: TextStyle(fontSize: 15),
              ),
            ),
            if (_isSearching)
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _isSearching = false;
                  });
                },
                color: grey600,
                iconSize: 20,
              ),
            SizedBox(width: 10),
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color:
                    Theme.of(context).colorScheme.primary.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(
                  LucideIcons.sliders,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                onPressed: () {
                  _showFilterDialog(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, PatientSearchState state) {
    if (state.isLoading) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.errorMessage.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            children: [
              Text(
                'Error',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              SizedBox(height: 8),
              Text(
                state.errorMessage,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(patientSearchProvider(doctorCIN).notifier)
                      .refreshSearchIndex();
                },
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.searchResults.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.search_off,
                size: 48,
                color: grey600,
              ),
              SizedBox(height: 16),
              Text(
                'No patients found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: grey600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Try adjusting your search terms',
                style: TextStyle(
                  color: grey600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Search Results',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: black.withValues(alpha: .9),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      '${state.searchResults.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  ref
                      .read(patientSearchProvider(doctorCIN).notifier)
                      .refreshSearchIndex();
                },
                tooltip: 'Refresh results',
              ),
            ],
          ),
          SizedBox(height: 16),
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: state.searchResults.length,
            itemBuilder: (context, index) {
              final patient = state.searchResults[index];
              // Adapt this to match your actual data structure
              return _buildPatientListItem(
                context,
                'images/doctor.jpg', // Default image or extract from patient data
                patient['name'] ?? 'Unknown',
                patient['symptoms'] ?? 'No symptoms',
                patient['age']?.toString() ?? 'Unknown',
                patient['gender'] ?? 'Unknown',
                patient['lastVisit'] ?? 'Unknown',
                onPressed: () {
                  context.goNamed('patientProfile', extra: patient);
                },
              );
            },
          ),
          SizedBox(height: 80),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 12,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter Patients',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: grey600.withValues(alpha: .1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Divider(height: 32),
                Text(
                  'Condition',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: black.withValues(alpha: .8),
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: grey600.withValues(alpha: .05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: InputBorder.none,
                      hintText: 'E.g. Fever, Headache',
                      hintStyle:
                          TextStyle(fontSize: 15, color: Colors.grey[400]),
                    ),
                    style: TextStyle(
                      fontSize: 15,
                      color: grey600,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: black.withValues(alpha: .8),
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: grey600.withValues(alpha: .05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: InputBorder.none,
                      hintText: 'E.g. Delhi, Mumbai',
                      hintStyle: TextStyle(fontSize: 15, color: grey400),
                    ),
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Reset filters
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: BorderSide(
                            color: grey600.withValues(alpha: .3),
                          ),
                        ),
                        child: Text(
                          'Reset',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Apply Filter',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPatientList(BuildContext context, List<PatientData> patients,
      bool isLoading, bool hasError) {
    if (isLoading && patients.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (hasError && patients.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
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
                ref.read(previousPatientsProvider(doctorCIN)).errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(previousPatientsProvider(doctorCIN).notifier)
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
        ),
      );
    }

    if (patients.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
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
        ),
      );
    }

    // Display only first 10 patients on the main screen
    final displayedPatients = patients.length > _maxPatientsToShow
        ? patients.sublist(0, _maxPatientsToShow)
        : patients;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'My Patients',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: black.withValues(alpha: .9),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      '${patients.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  // Navigate to All Patients screen
                  context.pushNamed(RouteConstants.doctorAllPatients);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                child: Row(
                  children: [
                    Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, size: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 24),
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: displayedPatients.length,
          itemBuilder: (context, index) {
            final patient = displayedPatients[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildPatientListItem(
                context,
                patient.image,
                patient.name,
                patient.symptoms,
                patient.age,
                patient.gender,
                patient.lastVisit,
                onPressed: () {
                  context.goNamed('patientProfile', extra: {
                    'id': patient.id,
                    'name': patient.name,
                    'symptoms': patient.symptoms,
                    'age': patient.age,
                    'gender': patient.gender,
                    'lastVisit': patient.lastVisit,
                  });
                },
                isFavorite: patient.isFavorite,
                patientId: patient.id,
              ),
            );
          },
        ),
        SizedBox(height: 80), // Space for FAB
      ],
    );
  }

  Widget _buildPatientListItem(
      BuildContext context,
      String image,
      String patientName,
      String symptoms,
      String age,
      String gender,
      String lastVisit,
      {void Function()? onPressed,
      bool isFavorite = false,
      String patientId = ''}) {
    return GestureDetector(
      onTap: onPressed,
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
                tag: patientId.isNotEmpty ? patientId : patientName,
                child: Container(
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: AssetImage(image),
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
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            patientName,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: black.withValues(alpha: .9),
                            ),
                          ),
                        ),
                        if (isFavorite)
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
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            symptoms,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '$age • $gender',
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
                          'Last visit: $lastVisit',
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
              patientId.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : grey600,
                        size: 24,
                      ),
                      onPressed: () {
                        ref
                            .read(previousPatientsProvider(doctorCIN).notifier)
                            .toggleFavorite(patientId);
                      },
                    )
                  : Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.arrow_forward,
                        color: Theme.of(context).colorScheme.primary,
                        size: 18,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
