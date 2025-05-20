import 'package:CuraDocs/common/components/colors.dart';
import 'package:CuraDocs/common/components/app_header.dart';
import 'package:CuraDocs/features/features_api_repository/search/internal_search/patient_search_provider.dart';
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

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
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
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfile(context),
              _buildSearchBar(context),
              SizedBox(height: 24),
              _isSearching
                  ? _buildSearchResults(context, searchState)
                  : _buildPatientList(context),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Add new patient
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Icon(Icons.add),
        ),
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
          color: Colors.transparent,
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

  Widget _buildPatientList(BuildContext context) {
    final items = [
      {
        'image': 'images/doctor.jpg',
        'patientName': 'Mathur Saab',
        'symptoms': 'Fever',
        'age': '42',
        'gender': 'Male',
        'lastVisit': '2 days ago',
        'onPressed': () {
          context.goNamed('patientProfile');
        }
      },
      {
        'image': 'images/doctor.jpg',
        'patientName': 'Hema Kumari',
        'symptoms': 'Headache',
        'age': '35',
        'gender': 'Female',
        'lastVisit': '1 week ago',
        'onPressed': () {
          context.goNamed('patientProfile');
        }
      },
      {
        'image': 'images/doctor.jpg',
        'patientName': 'Rajesh Kumar',
        'symptoms': 'Cold',
        'age': '28',
        'gender': 'Male',
        'lastVisit': 'Today',
        'onPressed': () {
          context.goNamed('patientProfile');
        }
      },
    ];

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
                      '${items.length}',
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
                onPressed: () {},
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
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildPatientListItem(
                context,
                item['image'] as String,
                item['patientName'] as String,
                item['symptoms'] as String,
                item['age'] as String,
                item['gender'] as String,
                item['lastVisit'] as String,
                onPressed: item['onPressed'] as void Function()?,
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
      {void Function()? onPressed}) {
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
                tag: patientName,
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
                    Text(
                      patientName,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: black.withValues(alpha: .9),
                      ),
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
              Container(
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
