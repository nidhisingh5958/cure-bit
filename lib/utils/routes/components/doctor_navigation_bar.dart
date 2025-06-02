import 'package:CureBit/common/components/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DoctorBottomNavigation extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  void _onTap(BuildContext context, int index) {
    if (index != navigationShell.currentIndex) {
      navigationShell.goBranch(
        index,
        initialLocation: false,
      );
    }
  }

  const DoctorBottomNavigation({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: white,
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withValues(0.05),
          //     blurRadius: 10,
          //     offset: const Offset(0, -5),
          //   ),
          // ],
        ),
        child: SafeArea(
          child: NavigationBar(
            height: 65,
            elevation: 0,
            backgroundColor: white,
            indicatorColor: transparent,
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
    return Container(
      height: 48,
      width: 48,
      margin: const EdgeInsets.only(top: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: isSelected
            ? BoxDecoration(
                color: Colors.grey.shade800,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              )
            : null,
        padding: const EdgeInsets.all(12),
        child: Icon(
          defaultIcon.icon,
          color: isSelected ? white : Colors.grey.shade400,
          size: 24,
        ),
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
  const Destination(
    icon: Icon(LucideIcons.users),
    label: 'My Patients',
  ),
  const Destination(
    icon: Icon(LucideIcons.calendarCheck),
    label: 'Bookings',
  ),
  const Destination(
    icon: Icon(LucideIcons.user),
    label: 'Profile',
  ),
];
