import 'package:flutter/material.dart';

class BookAnAppointment extends StatefulWidget {
  @override
  _BookAnAppointmentState createState() => _BookAnAppointmentState();
}

class _BookAnAppointmentState extends State<BookAnAppointment> {
  int selectedDate = 2;
  int? selectedTimeSlot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.share, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDoctorProfile(),
              SizedBox(height: 24),
              _buildStatsSection(),
              SizedBox(height: 32),
              _buildDateSection(),
              SizedBox(height: 32),
              _buildTimeSection(),
              SizedBox(height: 32),
              _buildBookButton(),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorProfile() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: Colors.blue.shade100, width: 2),
                      image: DecorationImage(
                        image: NetworkImage(
                            'https://example.com/doctor-image.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child:
                          Icon(Icons.verified, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cardiologist',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Dr. Thomas Michael',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text(
                          '4.8',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          ' (2456 reviews)',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Text(
                '\$84',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              Text(
                '/session',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    final stats = [
      {
        'icon': Icons.medical_services,
        'value': '8+',
        'label': 'Years Experience'
      },
      {'icon': Icons.people, 'value': '2000+', 'label': 'Patients'},
      {'icon': Icons.star, 'value': '4.8', 'label': 'Rating'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: stats.map((stat) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 4),
            padding: EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(stat['icon'] as IconData, color: Colors.blue),
                SizedBox(height: 8),
                Text(
                  stat['value']!.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  stat['label']!.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Date',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Container(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 7,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => setState(() => selectedDate = index),
                child: Container(
                  width: 70,
                  margin: EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: selectedDate == index ? Colors.blue : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selectedDate == index
                          ? Colors.transparent
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${21 + index}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: selectedDate == index
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        [
                          'Sun',
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat'
                        ][index],
                        style: TextStyle(
                          color: selectedDate == index
                              ? Colors.white.withOpacity(0.8)
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSection() {
    final times = [
      '12:30 PM',
      '12:45 PM',
      '1:00 PM',
      '1:30 PM',
      '2:00 PM',
      '2:30 PM'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Available Time Slots',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(Icons.access_time, color: Colors.grey),
          ],
        ),
        SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2.2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: times.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => setState(() => selectedTimeSlot = index),
              child: Container(
                decoration: BoxDecoration(
                  color: selectedTimeSlot == index ? Colors.blue : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selectedTimeSlot == index
                        ? Colors.transparent
                        : Colors.grey.shade300,
                  ),
                ),
                child: Center(
                  child: Text(
                    times[index],
                    style: TextStyle(
                      color: selectedTimeSlot == index
                          ? Colors.white
                          : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBookButton() {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        child: Text(
          'Book Appointment',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
