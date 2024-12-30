import 'package:cure_bit/components/navigation_bar.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 24, 97, 181),
      body: IndexedStack(
        index: currentPage,
        children: [
          MainBody(),
          // Add other pages here
        ],
      ),

      // BottomNavigationBar widget

      bottomNavigationBar: CustomGNav(),
    );
  }
}

class MainBody extends StatefulWidget {
  const MainBody({super.key});

  @override
  State<MainBody> createState() => _MainBodyState();
}

const EdgeInsets horizontalPadding = EdgeInsets.symmetric(horizontal: 16.0);

class _MainBodyState extends State<MainBody> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // user profile
                    Text(
                      "Hi, Aiden!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3),
                    // current date and time
                    Text(
                      "26 December 2024",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),

              // user profile image (make it dynamic)
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                    "https://www.shutterstock.com/image-vector/aiden-name-text-word-love-600nw-1638585565.jpg"),
              ),
            ],
          ),
        ),

        // search bar
        Padding(
          padding: const EdgeInsets.all(9.0),
          child: searchBar(),
        ),

        SizedBox(height: 3),

        // actionbuttons
        Padding(
          padding: horizontalPadding,
          child: ListView(
            shrinkWrap: true,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ActionButton(
                    icon: "assets/icons/prescription.png",
                    label: 'PRESCRIPTION',
                    onTap: () {
                      // Add your code here
                    },
                  ),
                  ActionButton(
                    icon: "assets/icons/journal.png",
                    label: 'TEST RECORDS',
                    onTap: () {
                      // Add your code here
                    },
                  ),
                  ActionButton(
                    icon: "assets/icons/appointment.png",
                    label: 'APPOINTMENTS',
                    onTap: () {
                      // Add your code here
                    },
                  ),
                  // ActionButton (
                  //   icon: ,
                  //   label: 'MEDICINES',
                  //   onTap: () {
                  //     // Add your code here
                  //   },
                  // ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: 8),

        // recent activities
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  // Header row
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'See all',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Appointment Cards
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.all(16),
                      children: [
                        AppointmentCard(
                          doctorName: 'Jean Grey',
                          rating: 4.8,
                          reviews: 220,
                          date: '30 April',
                          time: '15:00',
                          backgroundColor: Colors.blue.shade300,
                        ),
                        SizedBox(height: 10),
                        AppointmentCard(
                          isScheduled: true,
                          date: '23 Mar',
                          backgroundColor: Color.fromRGBO(66, 188, 229, 1),
                        ),
                        SizedBox(height: 10),
                        AppointmentCard(
                          isScheduled: true,
                          date: '23 Mar',
                          backgroundColor:
                              const Color.fromARGB(255, 164, 115, 229),
                        ),
                        SizedBox(height: 10),
                        AppointmentCard(
                          isScheduled: true,
                          date: '23 Mar',
                          backgroundColor: Colors.red.shade300,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  searchBar() {
    return SizedBox(
      height: 50,
      child: TextFormField(
        decoration: InputDecoration(
          hintText: "Search",
          hintStyle: TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white70,
            size: 20,
          ),
        ),
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              // color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(
              icon,
              width: 30,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final String? doctorName;
  final double? rating;
  final int? reviews;
  final String date;
  final String? time;
  final Color backgroundColor;
  final bool isScheduled;

  const AppointmentCard({
    this.doctorName,
    this.rating,
    this.reviews,
    required this.date,
    this.time,
    required this.backgroundColor,
    this.isScheduled = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isScheduled) ...[
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: backgroundColor),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctorName!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '${reviews} reviews',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.star,
                          color: Colors.yellow,
                          size: 16,
                        ),
                        Text(
                          rating.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
          ],
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: Colors.white,
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                date,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              if (time != null) ...[
                SizedBox(width: 16),
                Icon(
                  Icons.access_time,
                  color: Colors.white,
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  time!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
