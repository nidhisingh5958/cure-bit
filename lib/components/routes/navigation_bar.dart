import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

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
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: NavigationBar(
            height: 70,
            elevation: 0,
            backgroundColor: Colors.transparent,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: isSelected
          ? BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            )
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            defaultIcon.icon,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade600,
            size: 24,
          ),
          if (isSelected) ...[
            const SizedBox(height: 4),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Destination class remains the same
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
    icon: Icon(Icons.home_outlined),
    label: 'Home',
  ),
  Destination(
    icon: Icon(MdiIcons.robot),
    label: 'Chatbot',
  ),
  Destination(
    icon: Icon(Icons.add_circle_outline),
    label: 'Add',
  ),
  const Destination(
    icon: Icon(Icons.document_scanner_outlined),
    label: 'Documents',
  ),
  const Destination(
    icon: Icon(Icons.person_outline),
    label: 'Profile',
  ),
];
