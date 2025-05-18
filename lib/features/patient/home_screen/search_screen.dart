import 'package:CuraDocs/common/components/app_header.dart';
import 'package:CuraDocs/common/components/colors.dart';
import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:CuraDocs/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// This is the search screen for the patient where they can search doctors
class DoctorSearchScreen extends StatefulWidget {
  final Map<String, dynamic> map;

  const DoctorSearchScreen({super.key, required this.map});

  @override
  State<DoctorSearchScreen> createState() => _DoctorSearchScreenState();
}

class _DoctorSearchScreenState extends State<DoctorSearchScreen> {
  final FocusNode _focusNode = FocusNode();
  bool isExpanded = false;
  String query = '';
  String activeFilter = 'All'; // Default filter option
  List<Map<String, dynamic>> filteredDoctors = [];

  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the filtered doctors list with all doctors
    filteredDoctors =
        List<Map<String, dynamic>>.from(widget.map['doctors'] ?? []);

    // Listen for changes to update the isExpanded state
    _textController.addListener(() {
      setState(() {
        isExpanded = _textController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    // Clean up resources
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void onQueryChanged(String newQuery) {
    setState(() {
      query = newQuery;
      _filterDoctors();
    });
  }

  // Filter doctors based on query and active filter
  void _filterDoctors() {
    if (widget.map['doctors'] == null || widget.map['doctors'].isEmpty) {
      filteredDoctors = [];
      return;
    }

    if (query.isEmpty) {
      filteredDoctors = List<Map<String, dynamic>>.from(widget.map['doctors']);
      return;
    }

    String lowerQuery = query.toLowerCase();
    filteredDoctors = widget.map['doctors'].where((doctor) {
      // Search by name
      bool nameMatch =
          doctor['name']?.toString().toLowerCase().contains(lowerQuery) ??
              false;

      // Search by location
      bool locationMatch =
          doctor['location']?.toString().toLowerCase().contains(lowerQuery) ??
              false;

      // Search by CIN (Case Identification Number)
      bool cinMatch =
          doctor['cin']?.toString().toLowerCase().contains(lowerQuery) ?? false;

      // Apply filter if selected
      if (activeFilter == 'Name') {
        return nameMatch;
      } else if (activeFilter == 'Location') {
        return locationMatch;
      } else if (activeFilter == 'CIN') {
        return cinMatch;
      }

      // Default: search in all fields
      return nameMatch || locationMatch || cinMatch;
    }).toList();
  }

  // Delete items function to clear the text
  void _deleteItems() {
    setState(() {
      _textController.clear();
      query = '';
      isExpanded = false;
      // Reset filtered doctors to show all
      filteredDoctors =
          List<Map<String, dynamic>>.from(widget.map['doctors'] ?? []);
    });
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
              _buildFilterOption('CIN'),
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
          _filterDoctors(); // Apply filter immediately
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
            _buildDoctorList(),
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
                _filterDoctors();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(context) {
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
          hintText: "Search doctors by name, location or CIN",
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
            // Apply search
            onQueryChanged(value);
          }
        },
      ),
    );
  }

  // Get doctor's specialization
  String getCategory(String? specialization) {
    return specialization ?? 'General Physician';
  }

  Widget _buildDoctorList() {
    if (filteredDoctors.isEmpty) {
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

    return Expanded(
      child: ListView.builder(
        itemCount: filteredDoctors.length,
        padding: EdgeInsets.symmetric(horizontal: 10),
        itemBuilder: (context, index) {
          final doctor = filteredDoctors[index];

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
                        backgroundImage: NetworkImage(doctor['imageUrl'] ??
                            'https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png'),
                        radius: 30,
                      ),
                    ),
                    title: Text(
                      doctor['name'] ?? 'Unknown Doctor',
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
                          getCategory(doctor['specialization']),
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
                                doctor['location'] ?? 'Location not specified',
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
                        if (doctor['cin'] != null) SizedBox(height: 4),
                        if (doctor['cin'] != null)
                          Row(
                            children: [
                              Icon(Icons.badge, size: 16, color: Colors.grey),
                              SizedBox(width: 4),
                              Text(
                                'CIN: ${doctor['cin']}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
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
