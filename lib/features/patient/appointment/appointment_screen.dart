import 'package:CuraDocs/components/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  int _selectedRating = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text('Appointments'),
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              context.goNamed('home');
            },
          ),
          actions: [
            IconButton(
              icon: Icon(
                MdiIcons.heart,
                color: color2,
              ),
              style: IconButton.styleFrom(
                backgroundColor: color5,
                padding: const EdgeInsets.all(12),
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(
                MdiIcons.history,
                color: color1,
              ),
              style: IconButton.styleFrom(
                backgroundColor: color5,
                padding: const EdgeInsets.all(12),
              ),
              onPressed: () {},
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                _buildProfile(context),
                SizedBox(height: 14),
                _searchbar(context),
                SizedBox(height: 14),
                _buildCategoriesSection(context),
                SizedBox(height: 14),
                _buildTopDoctorCategory(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfile(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundImage: AssetImage("images/doctor.jpg"),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Akshay Kumar Singh',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.blue, size: 18),
                      SizedBox(width: 5),
                      Text(
                        'Delhi, India',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchbar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search doctors...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
          SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              _showFilterDialog(context);
            },
            child: Container(
              padding: EdgeInsets.all(12),
              child: Icon(
                MdiIcons.filter,
                color: color1,
                size: 28,
              ),
            ),
          ),
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
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter doctors by',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Specialisation',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Rating',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(
                    5,
                    (index) => GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedRating = index + 1;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.star,
                          color: index < _selectedRating
                              ? Colors.amber
                              : Colors.grey.shade300,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Apply'),
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

  Widget _buildCategoriesSection(BuildContext context) {
    // labels for categories
    final categories = [
      {
        'icon': MdiIcons.toothOutline,
        'label': 'Dentist',
        'onPressed': () {
          context.goNamed('prescriptions');
        }
      },
      {
        'icon': MdiIcons.heartPulse,
        'label': 'Cardiologist',
        'onPressed': () {
          context.goNamed('appointments');
        }
      },
      {
        'icon': MdiIcons.eye,
        'label': 'Opthomologist',
        'onPressed': () {
          context.goNamed('test-records');
        }
      },
      {
        'icon': MdiIcons.brain,
        'label': 'Neurologist',
        'onPressed': () {
          context.goNamed('medicines');
        }
      },
      {
        'icon': MdiIcons.earHearing,
        'label': 'ENT',
        'onPressed': () {
          context.goNamed('hearing');
        }
      },
    ];

    // build the categories section
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Row(
                  children: const [
                    Text('See All'),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: categories
                .map((category) => _buildCategoryItem(
                      context,
                      category['icon'] as IconData,
                      category['label'] as String,
                      onPressed: category['onPressed'] as void Function()?,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  // build the category item
  Widget _buildCategoryItem(BuildContext context, IconData icon, String label,
      {void Function()? onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 70,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color1, size: 24),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
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

  Widget _buildTopDoctorCategory(BuildContext context) {
    final items = [
      {
        'image': 'images/doctor.jpg',
        'doctorName': 'Dr. John Doe',
        'category': 'Dentist',
        'location': 'Delhi, India',
        'onPressed': () {
          context.goNamed('doctorProfile');
        }
      },
      {
        'image': 'images/doctor.jpg',
        'doctorName': 'Dr. Jane Doe',
        'category': 'Cardiologist',
        'location': 'Mumbai, India',
        'onPressed': () {
          context.goNamed('appointments');
        }
      },
      {
        'image': 'images/doctor.jpg',
        'doctorName': 'Dr. Ravi Sharma',
        'category': 'Opthomologist',
        'location': 'Bangalore, India',
        'onPressed': () {
          context.goNamed('test-records');
        }
      },
      {
        'image': 'images/doctor.jpg',
        'doctorName': 'Dr. Anil Kumar',
        'category': 'Neurologist',
        'location': 'Chennai, India',
        'onPressed': () {
          context.goNamed('medicines');
        }
      },
      {
        'image': 'images/doctor.jpg',
        'doctorName': 'Dr. Sunita Singh',
        'category': 'ENT',
        'location': 'Kolkata, India',
        'onPressed': () {
          context.goNamed('hearing');
        }
      },
    ];
    // build the top doctors section
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Doctors',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Row(
                  children: const [
                    Text('See All'),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: items
                .map((item) => _buildTopDoctorItem(
                      context,
                      item['image'] as String,
                      item['doctorName'] as String,
                      item['category'] as String,
                      item['location'] as String,
                      onPressed: item['onPressed'] as void Function()?,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  // build the category item
  Widget _buildTopDoctorItem(BuildContext context, String image,
      String doctorName, String category, String location,
      {void Function()? onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundImage: AssetImage(image),
                  ),
                  SizedBox(width: 30),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctorName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                            category,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text('|',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              )),
                          SizedBox(width: 5),
                          Icon(
                            Icons.star,
                            color: Colors.yellow,
                            size: 16,
                          ),
                          SizedBox(width: 5),
                          Text(
                            '4.5',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.blue, size: 16),
                          SizedBox(width: 5),
                          Text(
                            location,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
