import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  void _onTap(BuildContext context, int index) {
    // Check if we're selecting the same tab
    if (index != navigationShell.currentIndex) {
      navigationShell.goBranch(
        index,
        // Set initial location to true only when we're on the same branch
        initialLocation: false,
      );
    }
  }

  void _onTapWithLogging(BuildContext context, int index) {
    debugPrint('Current index: ${navigationShell.currentIndex}');
    debugPrint('Tapped index: $index');

    if (index != navigationShell.currentIndex) {
      debugPrint('Navigating to branch $index');
      navigationShell.goBranch(
        index,
        initialLocation: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        // Use the _onTap method instead of direct goBranch
        onDestinationSelected: (index) {
          _onTap(context, index);
          _onTapWithLogging(context, index);
        },
        destinations: destinations
            .map((destination) => NavigationDestination(
                  icon: destination.icon,
                  selectedIcon: Icon(destination.icon.icon, color: Colors.blue),
                  label: destination.label,
                ))
            .toList(),
      ),
    );
  }
}

//

class Destination {
  const Destination({
    required this.icon,
    required this.label,
  });

  final Icon icon;

  final String label;
}

const destinations = <Destination>[
  Destination(
    icon: Icon(Icons.home_outlined),
    label: 'Home',
  ),
  Destination(
    icon: Icon(Icons.chat_outlined),
    label: 'Chat',
  ),
  Destination(
    icon: Icon(Icons.rocket_outlined),
    label: 'Chatbot',
  ),
  Destination(
    icon: Icon(Icons.receipt_outlined),
    label: 'Documents',
  ),
  Destination(
    icon: Icon(Icons.person_outline),
    label: 'Profile',
  ),
];
