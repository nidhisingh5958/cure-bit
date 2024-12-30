import 'package:cure_bit/components/routes/route_constants.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter/material.dart';

class CustomGNav extends StatefulWidget {
  const CustomGNav({super.key});
  @override
  _CustomGNavState createState() => _CustomGNavState();
}

class _CustomGNavState extends State<CustomGNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _colorAnimation = ColorTween(
      begin: const Color.fromARGB(255, 33, 58, 243),
      end: const Color.fromARGB(255, 118, 170, 235),
    ).animate(_controller);

    _controller.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            child: GNav(
              backgroundColor: Colors.transparent,
              color: Colors.grey[600],
              activeColor: const Color.fromRGBO(253, 253, 253, 1),
              tabBackgroundGradient: LinearGradient(
                colors: [_colorAnimation.value!, Colors.blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),

              gap: 6,

              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              // Reduce icon size
              iconSize: 20,
              textSize: 12,
              // tab animation duration
              duration: Duration(milliseconds: 800),

              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
                _handleNavigation(context, index);
              },
              tabs: [
                GButton(
                  icon: Icons.home,
                  text: 'Home',
                ),
                GButton(
                  icon: Icons.description_outlined,
                  text: "Docs",
                ),
                GButton(
                  icon: Icons.rocket,
                  text: "Bot",
                ),
                GButton(
                  icon: Icons.chat_rounded,
                  text: "Chats",
                ),
                GButton(
                  icon: Icons.person,
                  text: 'Profile',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.pushNamed(RouteConstants.home);
        break;
      case 1:
        context.pushNamed(RouteConstants.documents);
        break;
      case 2:
        context.pushNamed(RouteConstants.chatBot);
        break;
      case 3:
        context.pushNamed(RouteConstants.chat);
        break;
      case 4:
        context.pushNamed(RouteConstants.profile);
        break;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
