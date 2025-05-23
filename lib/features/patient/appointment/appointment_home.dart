import 'package:CuraDocs/common/components/colors.dart';
import 'package:CuraDocs/common/components/app_header.dart';
import 'package:CuraDocs/app/features_api_repository/search/external_search/doctor_search_provider.dart';
import 'package:CuraDocs/features/patient/doctor_navigation_utility.dart';
import 'package:CuraDocs/features/patient/home_screen/search_screen.dart';
import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'dart:async';

class AppointmentHome extends ConsumerStatefulWidget {
  const AppointmentHome({super.key});

  @override
  ConsumerState<AppointmentHome> createState() => _AppointmentHomeState();
}

class _AppointmentHomeState extends ConsumerState<AppointmentHome> {
  int _selectedRating = 0;
  int _selectedCategoryIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    // Initialize the doctor search provider with Riverpod
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(doctorSearchProvider.notifier).initialize();
    });

    // Add listener to search controller for real-time searching
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Method to handle search changes with debounce
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isNotEmpty) {
        ref
            .read(doctorSearchProvider.notifier)
            .searchDoctors(_searchController.text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppHeader(
          title: 'Find Doctors',
          onBackPressed: () => context.goNamed('home'),
          actions: [
            IconButton(
              icon: Icon(MdiIcons.heart),
              style: IconButton.styleFrom(
                backgroundColor: transparent,
                foregroundColor: black.withValues(alpha: .8),
                padding: const EdgeInsets.all(8),
              ),
              onPressed: () {
                context.goNamed(RouteConstants.favouriteDoctors);
              },
            ),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(MdiIcons.history),
              style: IconButton.styleFrom(
                backgroundColor: transparent,
                foregroundColor: black,
                padding: const EdgeInsets.all(8),
              ),
              onPressed: () {
                context.goNamed(RouteConstants.bookedAppointments);
              },
            ),
            SizedBox(width: 16),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfile(context),
              _buildSearchBar(context),
              SizedBox(height: 20),
              _buildCategoriesSection(context),
              SizedBox(height: 20),
              _buildTopDoctorSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfile(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: .05),
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
                  color: black.withValues(alpha: .1),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 36,
              backgroundImage: AssetImage("images/doctor.jpg"),
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, Akshay',
                  style: TextStyle(
                    fontSize: 14,
                    color: grey600,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Find Your Doctor',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.location_on, color: grey600, size: 16),
                    SizedBox(width: 5),
                    Text(
                      'Delhi, India',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
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
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: grey200),
          boxShadow: [
            BoxShadow(
              color: black.withValues(alpha: .03),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search doctors, specialties...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: black.withValues(alpha: .5),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                  hintStyle: TextStyle(
                    color: grey400,
                    fontSize: 14,
                  ),
                ),
                style: TextStyle(fontSize: 14),
                onSubmitted: (value) {
                  // Navigate to search screen with the query
                  if (value.isNotEmpty) {
                    ref
                        .read(doctorSearchProvider.notifier)
                        .searchDoctors(value, context: context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DoctorSearchScreen(),
                      ),
                    );
                  }
                },
                onTap: () {
                  // When search bar is tapped, navigate to full search screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DoctorSearchScreen(),
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: 10),
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: grey600.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(
                  MdiIcons.filter,
                  color: grey600,
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

  // Show filter dialog
  void _showFilterDialog(BuildContext context) {
    final notifier = ref.read(doctorSearchProvider.notifier);
    final state = ref.read(doctorSearchProvider);

    String specialtyFilter = state.selectedSpecialty;
    String locationFilter = state.selectedLocation;
    int ratingFilter = state.selectedRating;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Doctors',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  Divider(),
                  SizedBox(height: 8),
                  Text(
                    'Specialization',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    initialValue: specialtyFilter,
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: grey200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: grey200),
                      ),
                      hintText: 'E.g. Cardiologist',
                      hintStyle:
                          TextStyle(fontSize: 14, color: Colors.grey[400]),
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      color: grey600,
                    ),
                    onChanged: (value) {
                      specialtyFilter = value;
                    },
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    initialValue: locationFilter,
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: grey200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: grey200),
                      ),
                      hintText: 'E.g. Delhi',
                      hintStyle: TextStyle(fontSize: 14, color: grey400),
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    onChanged: (value) {
                      locationFilter = value;
                    },
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Rating',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(
                      5,
                      (index) => GestureDetector(
                        onTap: () {
                          setState(() {
                            ratingFilter = index + 1;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(
                            Icons.star,
                            color: index < ratingFilter
                                ? Colors.amber
                                : Colors.grey.shade300,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              specialtyFilter = '';
                              locationFilter = '';
                              ratingFilter = 0;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('Reset'),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            notifier.setSpecialtyFilter(specialtyFilter);
                            notifier.setLocationFilter(locationFilter);
                            notifier.setRatingFilter(ratingFilter);

                            // Navigate to search results after applying filters
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DoctorSearchScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('Apply Filter'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    // labels for categories
    final categories = [
      {
        'icon': MdiIcons.toothOutline,
        'label': 'Dentist',
        'onPressed': () {
          setState(() {
            _selectedCategoryIndex = 0;
          });

          // Set the specialty filter and navigate to search results
          final notifier = ref.read(doctorSearchProvider.notifier);
          notifier.setSpecialtyFilter('Dentist');
          notifier.clearLocationFilter();
          notifier.clearRatingFilter();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorSearchScreen(),
            ),
          );
        }
      },
      {
        'icon': MdiIcons.heartPulse,
        'label': 'Cardiologist',
        'onPressed': () {
          setState(() {
            _selectedCategoryIndex = 1;
          });

          // Set the specialty filter and navigate to search results
          final notifier = ref.read(doctorSearchProvider.notifier);
          notifier.setSpecialtyFilter('Cardiologist');
          notifier.clearLocationFilter();
          notifier.clearRatingFilter();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorSearchScreen(),
            ),
          );
        }
      },
      {
        'icon': MdiIcons.eye,
        'label': 'Ophthalmologist',
        'onPressed': () {
          setState(() {
            _selectedCategoryIndex = 2;
          });

          // Set the specialty filter and navigate to search results
          final notifier = ref.read(doctorSearchProvider.notifier);
          notifier.setSpecialtyFilter('Ophthalmologist');
          notifier.clearLocationFilter();
          notifier.clearRatingFilter();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorSearchScreen(),
            ),
          );
        }
      },
      {
        'icon': MdiIcons.brain,
        'label': 'Neurologist',
        'onPressed': () {
          setState(() {
            _selectedCategoryIndex = 3;
          });

          // Set the specialty filter and navigate to search results
          final notifier = ref.read(doctorSearchProvider.notifier);
          notifier.setSpecialtyFilter('Neurologist');
          notifier.clearLocationFilter();
          notifier.clearRatingFilter();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorSearchScreen(),
            ),
          );
        }
      },
      {
        'icon': MdiIcons.earHearing,
        'label': 'ENT',
        'onPressed': () {
          setState(() {
            _selectedCategoryIndex = 4;
          });

          // Set the specialty filter and navigate to search results
          final notifier = ref.read(doctorSearchProvider.notifier);
          notifier.setSpecialtyFilter('ENT');
          notifier.clearLocationFilter();
          notifier.clearRatingFilter();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorSearchScreen(),
            ),
          );
        }
      },
    ];

    // build the categories section
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader('Categories'),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _buildCategoryItem(
                  context,
                  categories[index]['icon'] as IconData,
                  categories[index]['label'] as String,
                  isSelected: _selectedCategoryIndex == index,
                  onPressed: categories[index]['onPressed'] as void Function()?,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // build the category item
  Widget _buildCategoryItem(
    BuildContext context,
    IconData icon,
    String label, {
    bool isSelected = false,
    void Function()? onPressed,
  }) {
    final primaryColor = black.withValues(alpha: .8);

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 80,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withValues(alpha: .1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? transparent : grey200,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .03),
              blurRadius: 8,
              spreadRadius: 0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor.withValues(alpha: .2)
                    : Colors.grey.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  color: isSelected ? primaryColor : black, size: 24),
            ),
            SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? primaryColor : grey800,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopDoctorSection(BuildContext context) {
    // Watch the doctor search state
    final state = ref.watch(doctorSearchProvider);

    final doctors =
        state.filteredDoctors.isEmpty ? state.doctors : state.filteredDoctors;

    // Only show top 3 doctors on home screen
    final displayDoctors = doctors.length > 3 ? doctors.sublist(0, 3) : doctors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader('Top Doctors'),
        const SizedBox(height: 16),
        state.isLoading
            ? Center(child: CircularProgressIndicator())
            : displayDoctors.isEmpty
                ? Center(
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        Icon(MdiIcons.stethoscope, size: 48, color: grey400),
                        SizedBox(height: 16),
                        Text(
                          'No doctors found',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: grey600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: displayDoctors.length,
                    itemBuilder: (context, index) {
                      final doctor = displayDoctors[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildTopDoctorItem(
                          context,
                          doctor.imageUrl,
                          doctor.name,
                          doctor.specialty,
                          doctor.rating.toString(),
                          doctor.location,
                          doctorModel: doctor, // Pass the entire doctor model
                          doctorCin: doctor.cin, // Pass the doctor cin
                        ),
                      );
                    },
                  ),
        SizedBox(height: 20),
        if (doctors.length > 3)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to see all doctors
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DoctorSearchScreen(),
                  ),
                );
              },
              child: Text('See All Doctors'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        SizedBox(height: 20),
      ],
    );
  }

  // build the doctor item
  Widget _buildTopDoctorItem(BuildContext context, String image,
      String doctorName, String category, String rating, String location,
      {void Function()? onPressed, String? doctorCin, dynamic doctorModel}) {
    return GestureDetector(
      onTap: onPressed ??
          () {
            // Use the navigation utility based on available data
            if (doctorModel != null) {
              // If you have the full doctor model/object
              context.goToDoctorProfileFromModel(doctorModel);
            } else if (doctorCin != null && doctorCin.isNotEmpty) {
              // If you have the doctor CIN/ID
              context.goToDoctorProfileWithInfo(
                doctorCin,
                doctorName: doctorName,
                specialty: category,
              );
            } else {
              // Fallback - try to extract CIN from the doctor model or show error
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Doctor profile information not available'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .05),
              blurRadius: 10,
              spreadRadius: 0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Hero(
                tag: doctorName,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    image: DecorationImage(
                      image: AssetImage(image),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .1),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: Offset(0, 2),
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
                      doctorName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: grey400.withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: grey800,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 14,
                            ),
                            SizedBox(width: 2),
                            Text(
                              rating,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            color: Colors.grey[400], size: 14),
                        SizedBox(width: 2),
                        Text(
                          location,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: black.withValues(alpha: .1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.primary,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: () {
              // Navigate to see all
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DoctorSearchScreen(),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: Row(
              children: [
                Text(
                  'See All',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: grey800),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, size: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
