import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromRGBO(244, 246, 245, 1),
        body: SingleChildScrollView(
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center, // Align children to the center
                children: <Widget>[
                  Container(
                    height: 300,
                    padding: const EdgeInsets.all(16.0),
                    decoration: const BoxDecoration(
                      // color: Color(0xA20B3B71),
                      color: Color(0xA20B3B71),
                      borderRadius: BorderRadius.only(
                        // bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(35),
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 50,
                    left: 20,
                    child: Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 55,
                    right: 20,
                    child: Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      height: 150,
                      width: 350,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.rectangle,
                        border: Border.all(
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.person_2_rounded,
                        size: 90,
                      ),
                    ),
                  ),
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    height: 150,
                    padding: const EdgeInsets.all(16.0),
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(244, 246, 245, 1),
                      borderRadius: BorderRadius.only(
                        // bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(35),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    child: Container(
                      height: 150,
                      width: 350,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 20,
                    child: Text(
                      'P0123A43',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 55,
                    child: Text(
                      'Jhon Doe',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 83,
                    child: Text(
                      '+ 91 12345 67890',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 110,
                    child: Text(
                      'Dummymail@gmail.com',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              const SizedBox(
                height: 30,
                width: 350,
                child: Text(
                  "General",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(
                height: 13,
              ),
              Container(
                height: 80,
                width: 350,
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                child: GestureDetector(
                  onTap: () {
                    debugPrint("Row Tapped Profile");
                    Navigator.pushNamed(context, '/profile_settings');
                    // Navigator.pushNamed(context, '/signup_profile');
                    // Navigator.pushReplacement(
                    //   context,
                    //   MaterialScreeProfileScreenRoute(builder: (context) => const ProfileSettingsScreeProfileScreen()),
                    // );
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.settings),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Profile Settings",
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text("Update and modify your profile"),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Icon(Icons.arrow_forward_ios_outlined),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                height: 80,
                width: 350,
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.privacy_tip_rounded),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Privacy",
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text("Change your privacy settings"),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Icon(Icons.arrow_forward_ios_outlined),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                height: 80,
                width: 350,
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.notifications),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Notifications",
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text("Change your notification settings"),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Icon(Icons.arrow_forward_ios_outlined),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const SizedBox(
                height: 30,
                width: 350,
                child: Text(
                  "Appearance Settings",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(
                height: 13,
              ),
              Container(
                height: 80,
                width: 350,
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.message_rounded),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Messages Settings",
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text("Change your message settings"),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 18),
                      child: Icon(Icons.arrow_forward_ios_outlined),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                height: 80,
                width: 350,
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.phone_android_rounded),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Apprearance Settings",
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text("Customize the apprearance"),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 27),
                      child: Icon(Icons.arrow_forward_ios_outlined),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                height: 80,
                width: 350,
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock_outline_rounded),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Permissions",
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text("Change your permissions settings"),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 0),
                      child: Icon(Icons.arrow_forward_ios_outlined),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const SizedBox(
                height: 30,
                width: 350,
                child: Text(
                  "Help/ Support",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(
                height: 13,
              ),
              Container(
                height: 80,
                width: 350,
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                child: GestureDetector(
                  onTap: () {
                    debugPrint("Row Tapped Help");
                    Navigator.pushNamed(context, '/help');
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.help),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Help",
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text("Contact us for any help"),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 70),
                        child: Icon(Icons.arrow_forward_ios_outlined),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                height: 80,
                width: 350,
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.power_settings_new_sharp,
                      color: Colors.red,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Text(
                        "Log Out",
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 140),
                      child: Icon(
                        Icons.arrow_forward_ios_outlined,
                        color: Colors.red,
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                height: 80,
                width: 350,
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.delete_forever_rounded,
                      color: Colors.red,
                      size: 30,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Text(
                        "Delete My Account",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Icon(
                        Icons.arrow_forward_ios_outlined,
                        color: Colors.red,
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              const SizedBox(
                height: 50,
              ),
            ],
          ),
        ));
  }
}





// class ProfileScreen2 extends StatelessWidget {
//   const ProfileScreen2({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blue,
//         title: const Text('Profile'),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           // Profile Section
//           Container(
//             padding: const EdgeInsets.all(16.0),
//             decoration: const BoxDecoration(
//               color: Colors.blue,
//               borderRadius: BorderRadius.only(
//                 bottomLeft: Radius.circular(24),
//                 bottomRight: Radius.circular(24),
//               ),
//             ),
//             child:const Column(
//               children: [
//                 CircleAvatar(
//                   radius: 50,
//                   backgroundImage: AssetImage('assets/profile.jpg'), // Add a profile image
//                 ),
//                 SizedBox(height: 10),
//                 Text(
//                   'Ricardo Joseph',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   'ricardojoseph@gmail.com',
//                   style: TextStyle(
//                     color: Colors.white70,
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children:  [
//                     Icon(Icons.emoji_events, color: Colors.yellow, size: 30),
//                     SizedBox(width: 10),
//                     Icon(Icons.star, color: Colors.purple, size: 30),
//                     SizedBox(width: 10),
//                     Icon(Icons.shield, color: Colors.blue, size: 30),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 20),
//           // Settings Section
//           Expanded(
//             child: ListView(
//               children: [
//                 SettingsTile(
//                   icon: Icons.settings,
//                   title: 'Profile Settings',
//                   subtitle: 'Update and modify your profile',
//                   onTap: () {
//                     // Handle Profile Settings
//                   },
//                 ),
//                 SettingsTile(
//                   icon: Icons.privacy_tip,
//                   title: 'Privacy',
//                   subtitle: 'Change your password',
//                   onTap: () {
//                     // Handle Privacy
//                   },
//                 ),
//                 SettingsTile(
//                   icon: Icons.notifications,
//                   title: 'Notifications',
//                   subtitle: 'Change your notification settings',
//                   onTap: () {
//                     // Handle Notifications
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       // bottomNavigationBar: BottomNavigationBar(
//       //   currentIndex: 3,
//       //   items: const [
//       //     BottomNavigationBarItem(
//       //       icon: Icon(Icons.home),
//       //       label: 'Home',
//       //     ),
//       //     BottomNavigationBarItem(
//       //       icon: Icon(Icons.bar_chart),
//       //       label: 'Expenses',
//       //     ),
//       //     BottomNavigationBarItem(
//       //       icon: Icon(Icons.add_circle, size: 40),
//       //       label: '',
//       //     ),
//       //     BottomNavigationBarItem(
//       //       icon: Icon(Icons.account_balance_wallet),
//       //       label: 'Wallet',
//       //     ),
//       //     BottomNavigationBarItem(
//       //       icon: Icon(Icons.person),
//       //       label: 'Profile',
//       //     ),
//       //   ],
//       // ),
//     );
//   }
// }

// class SettingsTile extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String subtitle;
//   final VoidCallback onTap;

//   const SettingsTile({super.key, 
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       leading: Icon(icon, color: Colors.blue),
//       title: Text(title),
//       subtitle: Text(subtitle),
//       trailing: const Icon(Icons.arrow_forward_ios),
//       onTap: onTap,
//     );
//   }
// }