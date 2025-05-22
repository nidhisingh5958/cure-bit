import 'package:CuraDocs/common/components/app_header.dart';
import 'package:CuraDocs/common/components/colors.dart';
import 'package:CuraDocs/app/features_api_repository/search/external_search/doctor_search_provider.dart';
import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:CuraDocs/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DoctorSearchScreen extends ConsumerStatefulWidget {
  const DoctorSearchScreen({super.key});

  @override
  ConsumerState<DoctorSearchScreen> createState() => _DoctorSearchScreenState();
}

class _DoctorSearchScreenState extends ConsumerState<DoctorSearchScreen> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textController = TextEditingController();

  bool isExpanded = false;
  String activeFilter = 'All'; // Default filter option

  @override
  void initState() {
    super.initState();

    // Initialize the doctor search provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(doctorSearchProvider.notifier).initialize();
    });

    // Listen for changes to update the isExpanded state
    _textController.addListener(() {
      setState(() {
        isExpanded = _textController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Update query and filter when text changes
  void onQueryChanged(String newQuery) {
    if (newQuery.isEmpty) {
      ref.read(doctorSearchProvider.notifier).clearFilters();
    }
    setState(() {
      isExpanded = newQuery.isNotEmpty;
    });
  }

  // Method to apply filter based on selected filter type
  void applyFilter(String query) {
    if (query.isEmpty) return;

    // Search doctors using the provider
    ref
        .read(doctorSearchProvider.notifier)
        .searchDoctors(query, context: context);

    // Apply filters based on the active filter
    if (activeFilter == 'Name') {
      // No specific API filter for name, as it's included in general search
    } else if (activeFilter == 'Location') {
      ref.read(doctorSearchProvider.notifier).setLocationFilter(query);
    } else if (activeFilter == 'Specialty') {
      ref.read(doctorSearchProvider.notifier).setSpecialtyFilter(query);
    }
  }

  // Delete items function to clear the text
  void _deleteItems() {
    setState(() {
      _textController.clear();
      isExpanded = false;
    });
    ref.read(doctorSearchProvider.notifier).clearFilters();
  }

  // Show filter options dialog
  void _showFilterOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filter Search By'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterOption('All'),
              _buildFilterOption('Name'),
              _buildFilterOption('Location'),
              _buildFilterOption('Specialty'),
            ],
          ),
        );
      },
    );
  }

  // Build individual filter option
  Widget _buildFilterOption(String filterName) {
    return ListTile(
      title: Text(filterName),
      selected: activeFilter == filterName,
      onTap: () {
        setState(() {
          activeFilter = filterName;
          // Apply the current search with the new filter
          if (_textController.text.isNotEmpty) {
            applyFilter(_textController.text);
          }
        });
        Navigator.pop(context);
      },
      trailing: activeFilter == filterName
          ? Icon(Icons.check, color: Colors.blue)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch the doctor search state
    final doctorSearchState = ref.watch(doctorSearchProvider);
    final isLoading = doctorSearchState.isLoading;
    final error = doctorSearchState.error;
    final doctors = doctorSearchState.doctors;
    final filteredDoctors = doctorSearchState.filteredDoctors;

    return Scaffold(
      appBar: AppHeader(
        backgroundColor: transparent,
        onBackPressed: () {
          context.goNamed(RouteConstants.home);
        },
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(context),
            _buildActiveFilterChip(),
            _buildDoctorList(
              isLoading: isLoading,
              error: error,
              doctors: doctors,
              filteredDoctors: filteredDoctors,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFilterChip() {
    // Only show filter chip if not set to 'All'
    if (activeFilter == 'All') return SizedBox(height: 8);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Chip(
            label: Text('Filter: $activeFilter'),
            deleteIcon: Icon(Icons.close, size: 16),
            onDeleted: () {
              setState(() {
                activeFilter = 'All';
                // Clear specific filter based on the active filter
                if (activeFilter == 'Location') {
                  ref.read(doctorSearchProvider.notifier).clearLocationFilter();
                } else if (activeFilter == 'Specialty') {
                  ref
                      .read(doctorSearchProvider.notifier)
                      .clearSpecialtyFilter();
                } else if (activeFilter == 'Rating') {
                  ref.read(doctorSearchProvider.notifier).clearRatingFilter();
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextField(
        focusNode: _focusNode,
        controller: _textController,
        onChanged: onQueryChanged,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          prefixIcon: Icon(
            Icons.search,
            color: black,
            size: 20,
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isExpanded)
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: black,
                    size: 20,
                  ),
                  onPressed: _deleteItems,
                )
              else
                Icon(
                  Icons.mic,
                  color: black,
                  size: 20,
                ),
            ],
          ),
          hintText: "Search doctors by name, location or specialty",
          hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        style: TextStyle(fontSize: 14),
        minLines: 1,
        maxLines: 1,
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            applyFilter(value);
          }
        },
      ),
    );
  }

  Widget _buildDoctorList({
    required bool isLoading,
    required String error,
    required List<Doctor> doctors,
    required List<Doctor> filteredDoctors,
  }) {
    // Show loading state
    if (isLoading) {
      return Expanded(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show error state if there's an error
    if (error.isNotEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Error loading doctors',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
              SizedBox(height: 8),
              Text(
                error,
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Get the list of doctors to display
    final displayDoctors = filteredDoctors.isEmpty ? doctors : filteredDoctors;

    // Show empty state if no doctors found
    if (displayDoctors.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No doctors found',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'Try adjusting your search or filter',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // Build the list of doctors
    return Expanded(
      child: ListView.builder(
        itemCount: displayDoctors.length,
        padding: EdgeInsets.symmetric(horizontal: 10),
        itemBuilder: (context, index) {
          final doctor = displayDoctors[index];

          return Card(
            margin: EdgeInsets.symmetric(vertical: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenHeight(16),
                vertical: getProportionateScreenHeight(8),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 64,
                        minHeight: 64,
                        maxWidth: 64,
                        maxHeight: 64,
                      ),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(doctor.imageUrl),
                        radius: 30,
                      ),
                    ),
                    title: Text(
                      doctor.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: black.withValues(alpha: .8),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text(
                          doctor.specialty,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: black.withValues(alpha: .8),
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 16, color: Colors.grey),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                doctor.location,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star, size: 16, color: Colors.amber),
                            SizedBox(width: 4),
                            Text(
                              '${doctor.rating}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (doctor.reviews > 0) ...[
                              SizedBox(width: 4),
                              Text(
                                '(${doctor.reviews} reviews)',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      // Navigate to doctor's details page
                      context.pushNamed(
                        RouteConstants.doctorDetails,
                        extra: doctor,
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
