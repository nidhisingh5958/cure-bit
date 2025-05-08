import 'package:CuraDocs/features/patient/documents/components/search.dart';
import 'package:flutter/material.dart';
import 'package:CuraDocs/components/colors.dart';
import 'dart:math';
import 'package:CuraDocs/features/patient/documents/data/sample.dart'
    show Patient;

class PatientManagementScreen extends StatefulWidget {
  final List<Patient> patientData;

  const PatientManagementScreen({required this.patientData, Key? key})
      : super(key: key);

  @override
  State<PatientManagementScreen> createState() =>
      _PatientManagementScreenState();
}

class _PatientManagementScreenState extends State<PatientManagementScreen> {
  int _currentPage = 1;
  int _rowsPerPage = 10;
  int _selectedCount = 0;
  List<Patient> _filteredPatients = [];
  TextEditingController _searchController = TextEditingController();
  ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _filteredPatients = widget.patientData;
    // Count initially selected patients
    _selectedCount =
        _filteredPatients.where((patient) => patient.isSelected).length;
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterPatients(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPatients = widget.patientData;
      } else {
        _filteredPatients = widget.patientData
            .where((patient) =>
                patient.name.toLowerCase().contains(query.toLowerCase()) ||
                patient.patientId.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _togglePatientSelection(int index, bool? value) {
    setState(() {
      _filteredPatients[index].isSelected = value ?? false;
      _selectedCount =
          _filteredPatients.where((patient) => patient.isSelected).length;
    });
  }

  void _toggleAllSelection(bool? value) {
    setState(() {
      for (var patient in _filteredPatients) {
        patient.isSelected = value ?? false;
      }
      _selectedCount = value == true ? _filteredPatients.length : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width to adjust layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top filter and action bar - Make this responsive
            _buildTopActionBar(isMobile),

            SizedBox(height: 24),

            // Horizontal scrollable section for the table
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _horizontalScrollController,
                child: Container(
                  // Set a minimum width to ensure horizontal scroll on small screens
                  width: max(950, screenWidth - 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Table header
                      _buildTableHeader(),

                      // Patient rows in a vertical scroll
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: List.generate(
                              _filteredPatients.length,
                              (index) => _buildPatientRow(index),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Pagination controls
            _buildPaginationControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopActionBar(bool isMobile) {
    if (isMobile) {
      // Stack filters vertically on mobile
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchFilter(),
          // Search bar
          // Container(
          //   height: 48,
          //   decoration: BoxDecoration(
          //     color: black.withValues(alpha: 0.05),
          //     borderRadius: BorderRadius.circular(8.0),
          //   ),
          //   child: TextField(
          //     controller: _searchController,
          //     onChanged: _filterPatients,
          //     decoration: InputDecoration(
          //       hintText: 'Filter by name or ID...',
          //       prefixIcon: Icon(Icons.search, color: Colors.grey),
          //       border: InputBorder.none,
          //       contentPadding: EdgeInsets.symmetric(vertical: 12.0),
          //     ),
          //   ),
          // ),
          SizedBox(height: 12),

          // Filter buttons row
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      underline: SizedBox(),
                      icon: Icon(Icons.filter_list),
                      hint: Text('Status', style: TextStyle(fontSize: 16)),
                      items: ['All', 'Active', 'Inactive', 'Critical']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        // Status filtering logic
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      underline: SizedBox(),
                      icon: Icon(Icons.grid_view),
                      hint: Text('View', style: TextStyle(fontSize: 16)),
                      items: ['Table', 'Card'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        // View option logic
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Action buttons row
          Row(
            children: [
              // Delete button
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_outline, size: 20),
                        SizedBox(width: 4),
                        Text('Delete', style: TextStyle(fontSize: 14)),
                        if (_selectedCount > 0)
                          Container(
                            margin: EdgeInsets.only(left: 4),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text('$_selectedCount',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),

              // Add patient button
              Expanded(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.add, size: 20),
                  label: Text('Add patient'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: () {
                    // Add user logic
                  },
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      // Desktop layout
      return Row(
        children: [
          // Search filter
          Expanded(
            flex: 3,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterPatients,
                decoration: InputDecoration(
                  hintText: 'Filter by name or patient ID...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),

          // Status dropdown
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: DropdownButton<String>(
                underline: SizedBox(),
                icon: Icon(Icons.filter_list),
                hint: Row(
                  children: [
                    SizedBox(width: 8),
                    Text('Status', style: TextStyle(fontSize: 16)),
                  ],
                ),
                items: ['All', 'Active', 'Inactive', 'Critical']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  // Status filtering logic
                },
              ),
            ),
          ),
          SizedBox(width: 12),

          // View options
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: DropdownButton<String>(
                underline: SizedBox(),
                icon: Icon(Icons.grid_view),
                hint: Row(
                  children: [
                    SizedBox(width: 8),
                    Text('View', style: TextStyle(fontSize: 16)),
                  ],
                ),
                items: ['Table', 'Card'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  // View option logic
                },
              ),
            ),
          ),

          Spacer(),

          // Delete button
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Icon(Icons.delete_outline),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 8),
                  if (_selectedCount > 0)
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text('$_selectedCount',
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12),

          // Add patient button
          ElevatedButton.icon(
            icon: Icon(Icons.add),
            label: Text('Add patient'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              minimumSize: Size(140, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onPressed: () {
              // Add user logic
            },
          ),
        ],
      );
    }
  }

  Widget _buildTableHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 12),
          Checkbox(
            value: _selectedCount == _filteredPatients.length &&
                _filteredPatients.isNotEmpty,
            onChanged: _toggleAllSelection,
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Text(
                  'Name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Icon(Icons.arrow_downward, size: 16),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Patient ID',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Location',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Status',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Condition',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Last Payment',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Next Appointment',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientRow(int index) {
    final patient = _filteredPatients[index];
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1.0),
        ),
        color: patient.isSelected ? Colors.grey.shade100 : Colors.transparent,
      ),
      child: Row(
        children: [
          SizedBox(width: 12),
          Checkbox(
            value: patient.isSelected,
            onChanged: (bool? value) => _togglePatientSelection(index, value),
          ),
          Expanded(
            flex: 3,
            child: Text(
              patient.name,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(patient.patientId),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                _countryFlag(patient.country),
                SizedBox(width: 8),
                Text(patient.location),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(patient.status),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getStatusBorderColor(patient.status),
                ),
              ),
              child: Text(
                patient.status,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              patient.condition,
              style: TextStyle(
                color: _getConditionColor(patient.condition),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '\$${patient.lastPayment.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              patient.nextAppointment,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Text('Rows per page:'),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: DropdownButton<int>(
              value: _rowsPerPage,
              underline: SizedBox(),
              icon: Icon(Icons.arrow_drop_down),
              items: [5, 10, 25, 50].map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value'),
                );
              }).toList(),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  setState(() {
                    _rowsPerPage = newValue;
                  });
                }
              },
            ),
          ),
          Spacer(),
          Text('1-10 of 30'),
          SizedBox(width: 16),
          IconButton(
            icon: Icon(Icons.first_page),
            onPressed: () {
              // First page logic
            },
          ),
          IconButton(
            icon: Icon(Icons.navigate_before),
            onPressed: () {
              // Previous page logic
            },
          ),
          IconButton(
            icon: Icon(Icons.navigate_next),
            onPressed: () {
              // Next page logic
            },
          ),
          IconButton(
            icon: Icon(Icons.last_page),
            onPressed: () {
              // Last page logic
            },
          ),
        ],
      ),
    );
  }

  Widget _countryFlag(String countryCode) {
    // This is a simplified version - in production, you'd use a proper flag library
    Map<String, Color> flagColors = {
      'BR': Colors.green,
      'US': Colors.blue,
      'IT': Colors.green,
      'NO': Colors.red,
      'CN': Colors.red,
      'FR': Colors.blue,
      'MX': Colors.green,
      'DE': Colors.black,
      'KR': Colors.blue,
      'EG': Colors.red,
    };

    return Container(
      width: 24,
      height: 16,
      color: flagColors[countryCode] ?? Colors.grey,
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.white;
      case 'Inactive':
        return Colors.grey.shade300;
      case 'Critical':
        return Colors.red.shade50;
      default:
        return Colors.white;
    }
  }

  Color _getStatusBorderColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.grey.shade300;
      case 'Inactive':
        return Colors.grey.shade400;
      case 'Critical':
        return Colors.red.shade200;
      default:
        return Colors.grey.shade300;
    }
  }

  Color _getConditionColor(String condition) {
    switch (condition) {
      case 'Stable':
        return Colors.green;
      case 'Improving':
        return Colors.green;
      case 'Monitoring':
        return Colors.orange;
      case 'Critical':
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}
