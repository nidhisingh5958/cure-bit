import 'package:CuraDocs/common/components/app_header.dart';
import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:CuraDocs/common/components/pop_up.dart';

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({super.key});

  @override
  State<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: 'Favourites',
        onBackPressed: () => context.pop(),
        actions: [
          PopupMenuHelper.buildPopupMenu(
            context,
            onSelected: (value) {
              if (value == 'add') {
                // context.goNamed(RouteConstants.bookAppointment);
              } else if (value == 'help') {
                context.goNamed(RouteConstants.helpAndSupport);
              }
            },
            optionsList: [
              {'add': 'Add a Doctor'},
              {'help': 'Help'},
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Your Favourite Doctors',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLikedDoctorCategory(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLikedDoctorCategory(BuildContext context) {
    final items = [
      {
        'image': 'images/doctor.jpg',
        'doctorName': 'Dr. John Doe',
        'category': 'Dentist',
        'rating': '4.9',
        'location': 'Delhi, India',
        'onPressed': () {
          context.goNamed('doctorProfile');
        }
      },
      {
        'image': 'images/doctor.jpg',
        'doctorName': 'Dr. Jane Doe',
        'category': 'Cardiologist',
        'rating': '5.0',
        'location': 'Mumbai, India',
        'onPressed': () {
          context.goNamed('appointments');
        }
      },
      {
        'image': 'images/doctor.jpg',
        'doctorName': 'Dr. Ravi Sharma',
        'category': 'Ophthalmologist',
        'rating': '4.8',
        'location': 'Bangalore, India',
        'onPressed': () {
          context.goNamed('test-records');
        }
      },
    ];

    // build the top doctors section
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20),
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildTopDoctorItem(
                context,
                item['image'] as String,
                item['doctorName'] as String,
                item['category'] as String,
                item['rating'] as String,
                item['location'] as String,
                onPressed: item['onPressed'] as void Function()?,
              ),
            );
          },
        ),
        SizedBox(height: 20),
      ],
    );
  }

  // build the doctor item
  Widget _buildTopDoctorItem(BuildContext context, String image,
      String doctorName, String category, String rating, String location,
      {void Function()? onPressed}) {
    return GestureDetector(
      onTap: onPressed,
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
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.primary,
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
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: .1),
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
}
