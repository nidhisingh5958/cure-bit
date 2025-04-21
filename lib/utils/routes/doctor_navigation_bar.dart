import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DoctorBottomNavigation extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const DoctorBottomNavigation({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            backgroundColor: Colors.black26,
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            backgroundColor: Colors.black26,
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            backgroundColor: Colors.black26,
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            backgroundColor: Colors.black26,
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
