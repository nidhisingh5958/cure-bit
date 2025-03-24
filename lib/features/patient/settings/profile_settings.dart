import 'package:CuraDocs/components/colors.dart';
import 'package:flutter/material.dart';

class ProfileSettings extends StatelessWidget {
  const ProfileSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: color3,
        title: const Text(
          'Profile Details',
          style: TextStyle(
            fontSize: 28,
            color: Colors.white,
          ),
        ),
      ),
      backgroundColor: const Color.fromRGBO(244, 246, 245, 1),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  height: 380,
                  padding: const EdgeInsets.all(16.0),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(35),
                      bottomRight: Radius.circular(35),
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      border: Border.all(
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 90,
                    ),
                  ),
                ),
                const Positioned(
                  top: 180,
                  child: Text(
                    'Jhon Doe',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Positioned(
                  top: 215,
                  child: Text(
                    'P0123A43',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xBBFAFAFA),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  top: 265,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          debugPrint('Button Pressed1');
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10), // Padding
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                20), // Adjust the radius as needed
                          ),
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.mail, size: 40),
                            SizedBox(height: 8),
                            Text('Email'),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          debugPrint('Button Pressed2');
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10), // Padding
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                20), // Adjust the radius as needed
                          ),
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.phone, size: 40),
                            SizedBox(height: 8),
                            Text('Call'),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          debugPrint('Button Pressed3');
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10), // Padding
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                20), // Adjust the radius as needed
                          ),
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.wechat_sharp, size: 40),
                            SizedBox(height: 8),
                            Text('Whatsapp'),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          debugPrint('Button Pressed4');
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10), // Padding
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                20), // Adjust the radius as needed
                          ),
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_border, size: 40),
                            SizedBox(height: 8),
                            Text('Favorite'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              height: 800,
              width: 380,
              decoration: const BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(25)),
              ),
              margin: const EdgeInsets.all(20),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 25,
                      ),
                      Icon(
                        Icons.mail,
                        size: 30,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'example@gmail.com',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.black, // Line color
                    thickness: 1, // Line thickness
                    indent: 20, // Space from the left
                    endIndent: 20, // Space from the right
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 25,
                      ),
                      Icon(
                        Icons.phone,
                        size: 30,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Phone Number',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Mobile',
                            style: TextStyle(fontSize: 15, color: Colors.grey),
                          ),
                          Text(
                            '+91 70426 94112',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.black, // Line color
                    thickness: 1, // Line thickness
                    indent: 20, // Space from the left
                    endIndent: 20, // Space from the right
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 25,
                      ),
                      Icon(
                        Icons.bloodtype_rounded,
                        size: 30,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Blood Group',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            'O+',
                            style: TextStyle(
                              fontSize: 25,
                              color: Color.fromRGBO(97, 97, 97, 1),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.black, // Line color
                    thickness: 1, // Line thickness
                    indent: 20, // Space from the left
                    endIndent: 20, // Space from the right
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 25,
                      ),
                      Icon(
                        Icons.height_rounded,
                        size: 30,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Height',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            '157.3 cm',
                            style: TextStyle(
                              fontSize: 25,
                              color: Color.fromRGBO(97, 97, 97, 1),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.black, // Line color
                    thickness: 1, // Line thickness
                    indent: 20, // Space from the left
                    endIndent: 20, // Space from the right
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 25,
                      ),
                      Icon(
                        Icons.monitor_weight_rounded,
                        size: 30,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Weight',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            '78.5 Kg',
                            style: TextStyle(
                              fontSize: 25,
                              color: Color.fromRGBO(97, 97, 97, 1),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.black, // Line color
                    thickness: 1, // Line thickness
                    indent: 20, // Space from the left
                    endIndent: 20, // Space from the right
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 25,
                      ),
                      Icon(
                        Icons.medical_services_rounded,
                        size: 30,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Diabetic',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(
                            width: 150,
                          ),
                          Icon(
                            Icons.check_box_outlined,
                            size: 30,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.black, // Line color
                    thickness: 1, // Line thickness
                    indent: 20, // Space from the left
                    endIndent: 20, // Space from the right
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 25,
                      ),
                      Icon(
                        Icons.error_rounded,
                        size: 30,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Allergires',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(
                            width: 135,
                          ),
                          Icon(
                            Icons.check_box_outlined,
                            size: 30,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.black, // Line color
                    thickness: 1, // Line thickness
                    indent: 20, // Space from the left
                    endIndent: 20, // Space from the right
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 25,
                      ),
                      Icon(
                        Icons.sentiment_neutral_sharp,
                        size: 30,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Psychological Disorders',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(
                            width: 25,
                          ),
                          Icon(
                            Icons.check_box_outlined,
                            size: 30,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.black, // Line color
                    thickness: 1, // Line thickness
                    indent: 20, // Space from the left
                    endIndent: 20, // Space from the right
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 25,
                      ),
                      Icon(
                        Icons.contact_emergency_rounded,
                        size: 30,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Emergency Contact',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'Name : ',
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Jhon doe',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'Phone : ',
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                '1234567890',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'Email : ',
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'johndoe@gmail.com',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
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
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                debugPrint('Edit Profile');
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 120, vertical: 15),
                backgroundColor: Colors.white,
              ),
              child: const Text(
                'Edit Profile',
                style: TextStyle(fontSize: 25),
              ),
            ),
            const SizedBox(height: 70),
          ],
        ),
      ),
    );
  }
}
