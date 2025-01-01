import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/components/routes/route_constants.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
        switch (index) {
          case 0:
            context.push(RouteConstants.home);
            break;
          case 1:
            context.push(RouteConstants.chat);
            break;
          case 2:
            context.push(RouteConstants.chatBot);
            break;
          case 3:
            context.push(RouteConstants.documents);
            break;
          case 4:
            context.push(RouteConstants.profile);
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.rocket),
          label: 'Chatbot',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt),
          label: 'Document',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
// import 'package:google_nav_bar/google_nav_bar.dart';

// class CustomGNav extends StatelessWidget {
//   const CustomGNav({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.white,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
//         child: GNav(
//           tabBackgroundColor: Colors.blue,
//           // color: const Color.fromARGB(255, 34, 107, 191),
//           activeColor: Colors.white,
//           gap: 8,
//           onTabChange: (index) {
//             print(index);
//           },
//           padding: EdgeInsets.all(16),
//           tabs: const [
//             GButton(
//               icon: Icons.home,
//               text: 'Home',
//             ),
//             GButton(
//               icon: Icons.description_outlined,
//               text: "Docs",
//             ),
//             GButton(
//               icon: Icons.rocket,
//               text: "Bot",
//             ),
//             GButton(
//               icon: Icons.chat_rounded,
//               text: "Chats",
//             ),
//             GButton(
//               icon: Icons.person,
//               text: 'Profile',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
