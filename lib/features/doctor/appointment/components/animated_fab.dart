import 'package:flutter/material.dart';
import 'package:CureBit/common/components/colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AnimatedFloatingActionButton extends StatefulWidget {
  final VoidCallback? onNewAppointment;
  final VoidCallback? onReschedule;
  final EdgeInsetsGeometry? margin;

  const AnimatedFloatingActionButton({
    super.key,
    this.onNewAppointment,
    this.onReschedule,
    this.margin,
  });

  @override
  State<AnimatedFloatingActionButton> createState() =>
      _AnimatedFloatingActionButtonState();
}

class _AnimatedFloatingActionButtonState
    extends State<AnimatedFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      alignment: Alignment.bottomRight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Reschedule Appointment Option
          ScaleTransition(
            scale: _animationController,
            child: FadeTransition(
              opacity: _animationController,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: FloatingActionButton.extended(
                  heroTag: 'reschedule',
                  onPressed: () {
                    _toggle();
                    if (widget.onReschedule != null) {
                      widget.onReschedule!();
                    }
                  },
                  backgroundColor: grey800,
                  icon: const Icon(LucideIcons.calendar, color: white),
                  label:
                      const Text('Reschedule', style: TextStyle(color: white)),
                ),
              ),
            ),
          ),

          // Add New Appointment Option
          ScaleTransition(
            scale: _animationController,
            child: FadeTransition(
              opacity: _animationController,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: FloatingActionButton.extended(
                  heroTag: 'newAppointment',
                  onPressed: () {
                    _toggle();
                    if (widget.onNewAppointment != null) {
                      widget.onNewAppointment!();
                    }
                  },
                  backgroundColor: grey800,
                  icon: const Icon(
                    LucideIcons.userPlus,
                    color: white,
                  ),
                  label: const Text('New Appointment',
                      style: TextStyle(color: white)),
                ),
              ),
            ),
          ),

          // Main FAB - Plus/Cross
          FloatingActionButton(
            onPressed: _toggle,
            backgroundColor: black,
            child: AnimatedIcon(
              icon: AnimatedIcons.add_event,
              progress: _animationController,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
