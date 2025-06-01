import 'package:flutter/material.dart';
import 'package:CureBit/common/components/colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AnimatedFloatingActionButtonRecords extends StatefulWidget {
  final VoidCallback? onUploadDocument;
  final VoidCallback? onAddDocument;
  final EdgeInsetsGeometry? margin;

  const AnimatedFloatingActionButtonRecords({
    super.key,
    this.onUploadDocument,
    this.onAddDocument,
    this.margin,
  });

  @override
  State<AnimatedFloatingActionButtonRecords> createState() =>
      _AnimatedFloatingActionButtonRecordsState();
}

class _AnimatedFloatingActionButtonRecordsState
    extends State<AnimatedFloatingActionButtonRecords>
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
                  heroTag: 'addDocument',
                  onPressed: () {
                    _toggle();
                    if (widget.onAddDocument != null) {
                      widget.onAddDocument!();
                    }
                  },
                  backgroundColor: grey800,
                  icon: const Icon(LucideIcons.camera, color: white),
                  label: const Text('Add Document',
                      style: TextStyle(color: white)),
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
                  heroTag: 'uploadDocument',
                  onPressed: () {
                    _toggle();
                    if (widget.onUploadDocument != null) {
                      widget.onUploadDocument!();
                    }
                  },
                  backgroundColor: grey800,
                  icon: const Icon(
                    LucideIcons.uploadCloud,
                    color: white,
                  ),
                  label: const Text('Upload Document',
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
