import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  void _onTap(BuildContext context, int index) {
    if (index != navigationShell.currentIndex) {
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(0.05),
          //     blurRadius: 10,
          //     offset: const Offset(0, -5),
          //   ),
          // ],
        ),
        child: SafeArea(
          child: NavigationBar(
            height: 65,
            elevation: 0,
            backgroundColor: Colors.white,
            indicatorColor: Colors.transparent,
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) => _onTap(context, index),
            destinations: destinations.map((destination) {
              final isSelected = destinations.indexOf(destination) ==
                  navigationShell.currentIndex;
              return NavigationDestination(
                icon: _buildNavItem(
                    context, destination.icon, destination.label, isSelected),
                label: '',
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, Icon defaultIcon, String label, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: isSelected
          ? BoxDecoration(
              color: Colors.grey.shade800,
              // circular border
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            )
          : null,
      padding: isSelected ? const EdgeInsets.all(12) : EdgeInsets.zero,
      margin: isSelected
          ? const EdgeInsets.only(top: 0)
          : const EdgeInsets.only(top: 12),
      child: Icon(
        defaultIcon.icon,
        color: isSelected ? Colors.white : Colors.grey.shade400,
        size: 24,
      ),
    );
  }
}

class Destination {
  const Destination({
    required this.icon,
    required this.label,
  });

  final Icon icon;
  final String label;
}

var destinations = <Destination>[
  const Destination(
    icon: Icon(LucideIcons.home),
    label: 'Home',
  ),
  Destination(
    icon: Icon(LucideIcons.bot),
    label: 'Chatbot',
  ),
  Destination(
    icon: Icon(LucideIcons.plus),
    label: 'Add',
  ),
  const Destination(
    icon: Icon(LucideIcons.database),
    label: 'Documents',
  ),
  const Destination(
    icon: Icon(LucideIcons.user),
    label: 'Profile',
  ),
];
