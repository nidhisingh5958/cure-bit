import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class DoctorScheduleScreen extends StatefulWidget {
  const DoctorScheduleScreen({super.key});

  @override
  State<DoctorScheduleScreen> createState() => _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState extends State<DoctorScheduleScreen> {
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
              size: 20,
            ),
            onPressed: () {
              context.goNamed('home');
            },
          ),
        ),
        body: SingleChildScrollView(
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
    );
  }

  Widget _buildProfile(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Center(
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage("images/doctor.jpg"),
            ),
            SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.blue, size: 16),
                    SizedBox(width: 5),
                    Text(
                      'Delhi, India',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
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
              padding: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search doctors...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
          SizedBox(width: 10),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(Icons.filter_list, color: Colors.white),
          ),
        ],
      ),
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
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
            Icon(icon, color: Theme.of(context).primaryColor, size: 24),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
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
          context.goNamed('bookAppointment');
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
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(image),
                ),
                SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctorName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.access_time, color: Colors.blue, size: 16),
                        SizedBox(width: 5),
                        Text(
                          category,
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
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
