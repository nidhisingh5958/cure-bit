import 'package:CureBit/common/components/app_header.dart';
import 'package:CureBit/common/components/colors.dart';
import 'package:CureBit/app/features_api_repository/search/external_search/doctor_search_provider.dart';
import 'package:CureBit/utils/routes/route_constants.dart';
import 'package:CureBit/utils/size_config.dart';
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
      try {
        if (mounted) {
          ref.read(doctorSearchProvider.notifier).initialize();
        }
      } catch (e) {
        debugPrint('Error initializing doctor search: $e');
      }
    });

    // Listen for changes to update the isExpanded state
    _textController.addListener(() {
      if (mounted) {
        setState(() {
          isExpanded = _textController.text.isNotEmpty;
        });
      }
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
    try {
      if (newQuery.isEmpty) {
        ref.read(doctorSearchProvider.notifier).clearFilters();
      }
      if (mounted) {
        setState(() {
          isExpanded = newQuery.isNotEmpty;
        });
      }
    } catch (e) {
      debugPrint('Error in onQueryChanged: $e');
    }
  }

  // Method to apply filter based on selected filter type
  void applyFilter(String query) {
    if (query.isEmpty) return;

    try {
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
    } catch (e) {
      debugPrint('Error applying filter: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error applying filter: $e')),
        );
      }
    }
  }

  // Delete items function to clear the text
  void _deleteItems() {
    try {
      if (mounted) {
        setState(() {
          _textController.clear();
          isExpanded = false;
        });
      }
      ref.read(doctorSearchProvider.notifier).clearFilters();
    } catch (e) {
      debugPrint('Error clearing items: $e');
    }
  }

  // Show filter options dialog
  void _showFilterOptions() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Search By'),
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
        try {
          if (mounted) {
            setState(() {
              activeFilter = filterName;
              // Apply the current search with the new filter
              if (_textController.text.isNotEmpty) {
                applyFilter(_textController.text);
              }
            });
          }
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        } catch (e) {
          debugPrint('Error selecting filter option: $e');
        }
      },
      trailing: activeFilter == filterName
          ? const Icon(Icons.check, color: Colors.blue)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch the doctor search state with error handling
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
            icon: const Icon(Icons.filter_list),
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
    if (activeFilter == 'All') return const SizedBox(height: 8);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Chip(
            label: Text('Filter: $activeFilter'),
            deleteIcon: const Icon(Icons.close, size: 16),
            onDeleted: () {
              try {
                if (mounted) {
                  setState(() {
                    // Store the current filter to clear the appropriate one
                    final currentFilter = activeFilter;
                    activeFilter = 'All';

                    // Clear specific filter based on the previous active filter
                    if (currentFilter == 'Location') {
                      ref
                          .read(doctorSearchProvider.notifier)
                          .clearLocationFilter();
                    } else if (currentFilter == 'Specialty') {
                      ref
                          .read(doctorSearchProvider.notifier)
                          .clearSpecialtyFilter();
                    } else if (currentFilter == 'Rating') {
                      ref
                          .read(doctorSearchProvider.notifier)
                          .clearRatingFilter();
                    }
                  });
                }
              } catch (e) {
                debugPrint('Error clearing filter chip: $e');
              }
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
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isExpanded)
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  onPressed: _deleteItems,
                )
              else
                Icon(
                  Icons.mic,
                  color: Theme.of(context).primaryColor,
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
        style: const TextStyle(fontSize: 14),
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
      return const Expanded(
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
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Error loading doctors',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(doctorSearchProvider.notifier).initialize();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Get the list of doctors to display
    final displayDoctors =
        filteredDoctors.isNotEmpty ? filteredDoctors : doctors;

    // Show empty state if no doctors found
    if (displayDoctors.isEmpty) {
      return const Expanded(
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
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemBuilder: (context, index) {
          if (index >= displayDoctors.length) {
            return const SizedBox.shrink();
          }

          final doctor = displayDoctors[index];

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenHeight(16),
                vertical: getProportionateScreenHeight(8),
              ),
              child: ListTile(
                leading: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 64,
                    minHeight: 64,
                    maxWidth: 64,
                    maxHeight: 64,
                  ),
                  child: CircleAvatar(
                    backgroundImage: doctor.imageUrl.isNotEmpty
                        ? NetworkImage(doctor.imageUrl)
                        : null,
                    radius: 30,
                    child: doctor.imageUrl.isEmpty
                        ? const Icon(Icons.person, size: 30)
                        : null,
                  ),
                ),
                title: Text(
                  doctor?.name ?? 'Unknown Name',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      doctor?.specialty ?? 'Unknown Specialty',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            doctor.location ?? 'Unknown Location',
                            style: TextStyle(
                              fontSize: 13,
                              color: grey600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${doctor?.rating ?? '0.0'}',
                          style: TextStyle(
                            fontSize: 13,
                            color: grey600,
                          ),
                        ),
                        if (doctor.reviews > 0) ...[
                          const SizedBox(width: 4),
                          Text(
                            '(${doctor?.reviews ?? '4.5'} reviews',
                            style: TextStyle(
                              fontSize: 13,
                              color: grey600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                onTap: () {
                  try {
                    // Check if doctor.cin is not null or empty before navigation
                    if (doctor.cin.isNotEmpty) {
                      debugPrint(
                        'Navigating to doctor details with ID: ${doctor.cin}',
                      );
                      context.pushNamed(
                        RouteConstants.doctorDetails,
                        pathParameters: {
                          'doctorId':
                              doctor.cin.isEmpty ? doctor.cin : 'GAJB8522',
                        },
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Doctor ID not available')),
                      );
                    }
                  } catch (e) {
                    debugPrint('Error navigating to doctor details: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                trailing: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                  onPressed: () {
                    try {
                      // Check if doctor.cin is not null or empty before navigation
                      if (doctor.cin.isNotEmpty) {
                        context.pushNamed(
                          RouteConstants.doctorDetails,
                          pathParameters: {
                            'doctorId':
                                doctor.cin.isEmpty ? doctor.cin : 'GAJB8522'
                          },
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Doctor ID not available')),
                        );
                      }
                    } catch (e) {
                      debugPrint('Error navigating to doctor details: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
