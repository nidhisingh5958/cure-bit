import 'package:CuraDocs/components/colors.dart';
import 'package:flutter/material.dart';

class SearchWithFilter extends StatelessWidget {
  const SearchWithFilter(
      {super.key,
      required void Function(String query) onChanged,
      required TextEditingController controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search and filter bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Search bar
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: GestureDetector(
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        Icon(Icons.search, color: black.withValues(alpha: .8)),
                        const SizedBox(width: 8),
                        Text(
                          "Search Medical Records",
                          style: TextStyle(
                            color: black.withValues(alpha: .8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Filters button
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: GestureDetector(
                  child: Row(
                    children: [
                      Text(
                        "Filters",
                        style: TextStyle(
                          color: black.withValues(alpha: .8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down,
                        size: 20,
                        color: black.withValues(alpha: .8),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
