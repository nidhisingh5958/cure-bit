import 'package:flutter/material.dart';

Widget _buildHealthSummaryCard(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Theme.of(context).colorScheme.primary,
          Theme.of(context).colorScheme.primary.withValues(alpha: .8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: .2),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Health Summary',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_horiz, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildHealthMetric(
              icon: Icons.favorite_border,
              value: '72',
              label: 'Heart Rate',
              unit: 'bpm',
            ),
            _buildHealthMetric(
              icon: Icons.local_fire_department_outlined,
              value: '1,248',
              label: 'Calories',
              unit: 'kcal',
            ),
            _buildHealthMetric(
              icon: Icons.directions_walk_outlined,
              value: '8,546',
              label: 'Steps',
              unit: 'steps',
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildHealthMetric({
  required IconData icon,
  required String value,
  required String label,
  required String unit,
}) {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
      const SizedBox(height: 12),
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        '$label\n($unit)',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withValues(alpha: .8),
          fontSize: 12,
          height: 1.2,
        ),
      ),
    ],
  );
}
