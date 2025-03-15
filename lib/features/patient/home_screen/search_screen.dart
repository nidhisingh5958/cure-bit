import 'package:CuraDocs/components/colors.dart';
import 'package:CuraDocs/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// This is the search screen for the patient where he/she can search doctors
class DoctorSearchScreen extends StatefulWidget {
  final Map<String, dynamic> map;
  const DoctorSearchScreen({Key? key, required this.map}) : super(key: key);

  @override
  State<DoctorSearchScreen> createState() => _DoctorSearchScreenState();
}

class _DoctorSearchScreenState extends State<DoctorSearchScreen> {
  String searchString = '';
  List<dynamic> filteredDoctors = [];
  List<String> selectedSpecializations = [];

  @override
  void initState() {
    super.initState();
    // Initialize filtered doctors with all doctors
    filteredDoctors = List.from(widget.map['doctors'] ?? []);
  }

  // Filter doctors based on search string and selected specializations
  void _filterDoctors() {
    setState(() {
      if (searchString.isEmpty && selectedSpecializations.isEmpty) {
        // If no filters, show all doctors
        filteredDoctors = List.from(widget.map['doctors'] ?? []);
      } else {
        filteredDoctors =
            (widget.map['doctors'] as List<dynamic>).where((doctor) {
          bool matchesSearch = searchString.isEmpty ||
              (doctor['name'] as String)
                  .toLowerCase()
                  .contains(searchString.toLowerCase()) ||
              (doctor['specialization'] as String)
                  .toLowerCase()
                  .contains(searchString.toLowerCase());

          bool matchesSpecialization = selectedSpecializations.isEmpty ||
              selectedSpecializations.contains(doctor['specialization']);

          return matchesSearch && matchesSpecialization;
        }).toList();
      }
    });
  }

  // Show filter dialog
  void _showFilterDialog() {
    // Get all unique specializations
    final allSpecializations = (widget.map['doctors'] as List<dynamic>)
        .map((doctor) => doctor['specialization'] as String)
        .toSet()
        .toList();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Filter by Specialization'),
            content: Container(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: allSpecializations.length,
                itemBuilder: (context, index) {
                  final specialization = allSpecializations[index];
                  return CheckboxListTile(
                    title: Text(specialization),
                    value: selectedSpecializations.contains(specialization),
                    onChanged: (selected) {
                      setDialogState(() {
                        if (selected!) {
                          selectedSpecializations.add(specialization);
                        } else {
                          selectedSpecializations.remove(specialization);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _filterDoctors();
                },
                child: Text('Apply'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: color5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_outlined),
          onPressed: () {
            context.pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: filteredDoctors.isEmpty
                ? Center(child: Text('No doctors found'))
                : _buildDoctorList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for doctors',
                border: InputBorder.none,
              ),
              onChanged: (value) {
                searchString = value;
                _filterDoctors();
              },
            ),
          ),
          if (searchString.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  searchString = '';
                  _filterDoctors();
                });
              },
            ),
        ],
      ),
    );
  }

  // Get category/specialization with null safety
  String getCategory(String? specialization) {
    return specialization ?? 'General Physician';
  }

  Widget _buildDoctorList() {
    return ListView.builder(
      itemCount: filteredDoctors.length,
      itemBuilder: (context, index) {
        final doctor = filteredDoctors[index];
        return Card(
          margin: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
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
                      backgroundImage: NetworkImage(doctor['image'] ??
                          'https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png'),
                      radius: 30,
                    ),
                  ),
                  title: Text(
                    doctor['name'] ?? 'Unknown Doctor',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color2,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getCategory(doctor['specialization']),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: color2,
                        ),
                      ),
                      if (doctor['location'] != null)
                        Text(
                          'Location: ${doctor['location']}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: color2,
                          ),
                        ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.arrow_forward_ios, size: 16),
                    onPressed: () {
                      // Navigate to doctor details
                      // context.push('/doctor-details', extra: doctor);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// filter logic
// body: FutureBuilder(
//   future: futureProduct,
//   builder: (context, snapshot) {
//     if (snapshot.hasData) {
//       print(snapshot.hasData);
//       final datas = snapshot.data; // data preprocessing
//       Map<String, dynamic> map = datas.getData();
//       int length = 10; // In this example, I only show 10 data at most
//       if (searchString == '') {
//         if (map['products'].length < 10) {
//           length = map['products'].length;
//         }
//       } else { // do search
//         final filteredMap = <String, dynamic>{};
//         final List<dynamic> filteredList = [];
//         filteredMap['products'] = filteredList;
//         for (int i = 0; i < map['products'].length; i++) {
//           if (map['products'][i]['name']
//               .toLowerCase()
//               .contains(searchString.toLowerCase())) //search name {
//             filteredMap['products'].add(map['products'][i]);
//           } else {
//             for (int j = 0;
//             j < map['products'][i]['category'].length;
//             j++) {
//               if (map['products'][i]['category'][j]
//                   .toLowerCase()
//                   .contains(searchString.toLowerCase())) //search category {
//                 filteredMap['products'].add(map['products'][i]);
//               }
//             }
//           }
//         }
