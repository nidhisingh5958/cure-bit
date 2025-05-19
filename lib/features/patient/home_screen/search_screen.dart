import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:CuraDocs/features/features_api_repository/search/external_search/doctor_search_provider.dart';

class DoctorSearchScreen extends StatefulWidget {
  const DoctorSearchScreen({super.key});

  @override
  State<DoctorSearchScreen> createState() => _DoctorSearchScreenState();
}

class _DoctorSearchScreenState extends State<DoctorSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    // Initialize the provider with some default doctors when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DoctorSearchProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DoctorSearchProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Find a Doctor'),
            elevation: 0,
          ),
          body: Column(
            children: [
              _buildSearchBar(provider),
              if (_showFilters) _buildFilterOptions(provider),
              _buildFilterChips(provider),
              Expanded(
                child: _buildDoctorList(provider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(DoctorSearchProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search doctors by name or specialty',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onSubmitted: (value) {
                provider.searchDoctors(value);
              },
            ),
          ),
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
              color: _showFilters ? Theme.of(context).primaryColor : null,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOptions(DoctorSearchProvider provider) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Options',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          // Specialty filter
          TextField(
            decoration: InputDecoration(
              hintText: 'Specialty (e.g., Dentist, Cardiologist)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            onChanged: (value) {
              provider.setSpecialtyFilter(value);
            },
          ),
          const SizedBox(height: 8),
          // Location filter
          TextField(
            decoration: InputDecoration(
              hintText: 'Location (e.g., Delhi, Mumbai)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            onChanged: (value) {
              provider.setLocationFilter(value);
            },
          ),
          const SizedBox(height: 8),
          // Rating filter
          Row(
            children: [
              const Text('Minimum Rating: '),
              Expanded(
                child: Slider(
                  value: provider.selectedRating.toDouble(),
                  min: 0,
                  max: 5,
                  divisions: 5,
                  label: provider.selectedRating.toString(),
                  onChanged: (value) {
                    provider.setRatingFilter(value.toInt());
                  },
                ),
              ),
              Text('${provider.selectedRating}'),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: ElevatedButton(
              onPressed: () {
                provider.clearFilters();
              },
              child: const Text('Clear All Filters'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFilterChips(DoctorSearchProvider provider) {
    // Only show the active filters
    List<Widget> chips = [];

    if (provider.selectedSpecialty.isNotEmpty) {
      chips.add(
        Chip(
          label: Text('Specialty: ${provider.selectedSpecialty}'),
          onDeleted: () {
            provider.setSpecialtyFilter('');
          },
        ),
      );
    }

    if (provider.selectedLocation.isNotEmpty) {
      chips.add(
        Chip(
          label: Text('Location: ${provider.selectedLocation}'),
          onDeleted: () {
            provider.setLocationFilter('');
          },
        ),
      );
    }

    if (provider.selectedRating > 0) {
      chips.add(
        Chip(
          label: Text('Rating: ${provider.selectedRating}+'),
          onDeleted: () {
            provider.setRatingFilter(0);
          },
        ),
      );
    }

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        spacing: 8.0,
        children: chips,
      ),
    );
  }

  Widget _buildDoctorList(DoctorSearchProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: ${provider.error}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                provider.initialize();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final doctors =
        provider.filteredDoctors.isEmpty && provider.searchQuery.isEmpty
            ? provider.doctors
            : provider.filteredDoctors;

    if (doctors.isEmpty) {
      return const Center(
        child: Text('No doctors found. Try a different search.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: doctors.length,
      itemBuilder: (context, index) {
        final doctor = doctors[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          elevation: 2,
          child: InkWell(
            onTap: () {
              // Navigate to doctor details screen
              // You can implement this later
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Selected ${doctor.name}')),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doctor image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      doctor.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.person, size: 40),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Doctor info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(doctor.specialty),
                        const SizedBox(height: 4),
                        Text(doctor.location),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${doctor.rating}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 16),
                            Text('₹${doctor.fee.toStringAsFixed(0)}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
