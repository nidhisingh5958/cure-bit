import 'package:CuraDocs/features/patient/documents/components/search.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:CuraDocs/features/patient/documents/data/sample.dart'
    show Patient;

class PatientManagementScreen extends StatefulWidget {
  final List<Patient> patientData;

  const PatientManagementScreen({required this.patientData, super.key});

  @override
  State<PatientManagementScreen> createState() =>
      _PatientManagementScreenState();
}

class _PatientManagementScreenState extends State<PatientManagementScreen> {
  final int _currentPage = 1;
  final int _rowsPerPage = 10;
  int _selectedCount = 0;
  List<Patient> _filteredPatients = [];
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _horizontalScrollController = ScrollController();

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

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchWithFilter(),

            // Horizontal scrollable section for the table
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _horizontalScrollController,
                child: SizedBox(
                  // Set a minimum width to ensure horizontal scroll on small screens
                  width: max(200, screenWidth - 32),
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
          ],
        ),
      ),
    );
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
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1.0),
        ),
        color: patient.isSelected ? Colors.grey.shade100 : Colors.transparent,
      ),
      child: Row(
        children: [
          SizedBox(width: 12),
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
            child: Text(
              patient.nextAppointment,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
