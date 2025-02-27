import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

final Color color1 = Colors.black;
final Color color2 = Colors.black.withOpacity(0.8);
final Color color3 = Colors.grey.shade600;

class MyTimelineTile extends StatelessWidget {
  const MyTimelineTile({
    required this.isFirst,
    required this.isLast,
    required this.isPast,
    required this.eventCard,
    super.key,
  });

  final bool isFirst;
  final bool isLast;
  final bool isPast;
  final Widget eventCard;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: TimelineTile(
        isFirst: isFirst,
        isLast: isLast,
        alignment: TimelineAlign.manual,
        lineXY: 0.15, // Position line closer to the left

        // Line styling
        beforeLineStyle: LineStyle(
          color: isPast ? color1 : color3,
          thickness: 2,
        ),
        afterLineStyle: LineStyle(
          color: isPast ? color1 : color3,
          thickness: 2,
        ),

        // Indicator styling
        indicatorStyle: IndicatorStyle(
          width: 20,
          height: 20,
          indicator: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: color1,
                width: 2,
              ),
            ),
            child: Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color1,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),

        // Content
        startChild: const SizedBox(width: 20),
        endChild: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: eventCard,
        ),
      ),
    );
  }
}
