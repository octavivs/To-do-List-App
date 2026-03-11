// ---
// WIDGET: category_filter_chips.dart
// ---
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list_app/features/tasks/logic/providers/task_provider.dart';
import 'package:to_do_list_app/core/constants/app_colors.dart';
import 'package:to_do_list_app/core/utils/color_utils.dart';

// OOP CONCEPT: Specialized UI Component
// This widget is dedicated solely to rendering the horizontal list of filter chips.
class CategoryFilterChips extends StatelessWidget {
  const CategoryFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final categories = provider.categories;
    final selectedId = provider.selectedFilterCategoryId;

    return SingleChildScrollView(
      // Allows the user to swipe left/right if there are many categories
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          // 1. The "All Categories" Chip (Static)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: const Text('All'),
              selected: selectedId == null,
              selectedColor: AppColors.primary.withOpacity(0.2),
              onSelected: (bool selected) {
                // If tapped, clear the category filter (set to null)
                if (selected) provider.setFilterCategory(null);
              },
            ),
          ),

          // 2. Dynamic Category Chips (Generated from the provider)
          // The spread operator (...) unpacks the mapped list into the Row's children
          ...categories.map((category) {
            final isSelected = selectedId == category.id;
            final catColor = ColorUtils.fromHex(category.colorHex);

            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(category.name),
                selected: isSelected,
                selectedColor: catColor.withOpacity(0.3),
                // Visual detail: A tiny color dot inside the chip
                avatar: CircleAvatar(backgroundColor: catColor, radius: 10),
                onSelected: (bool selected) {
                  // Toggle logic: If tapping the already selected chip, deselect it (null)
                  // Otherwise, select its category ID.
                  provider.setFilterCategory(selected ? category.id : null);
                },
              ),
            );
          }).toList(), // Don't forget to convert the Iterable back to a List!
        ],
      ),
    );
  }
}
