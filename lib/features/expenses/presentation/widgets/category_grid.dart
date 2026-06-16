import 'package:flutter/material.dart';
import 'package:smart_expense/core/constants/category_colors.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/features/expenses/presentation/widgets/category_item.dart';

/// Grid of category items for transaction selection.
class CategoryGrid extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String>? onCategorySelected;

  const CategoryGrid({
    super.key,
    this.selectedCategory,
    this.onCategorySelected,
  });

  final List<Map<String, dynamic>> _categories = const [
    {'name': 'طعام', 'icon': Icons.restaurant_rounded, 'color': CategoryColors.food},
    {'name': 'مواصلات', 'icon': Icons.directions_car_rounded, 'color': CategoryColors.transport},
    {'name': 'فواتير', 'icon': Icons.receipt_long_rounded, 'color': CategoryColors.bills},
    {'name': 'ترفيه', 'icon': Icons.movie_rounded, 'color': CategoryColors.entertainment},
    {'name': 'صحة', 'icon': Icons.favorite_rounded, 'color': CategoryColors.health},
    {'name': 'تسوق', 'icon': Icons.shopping_bag_rounded, 'color': CategoryColors.shopping},
    {'name': 'أخرى', 'icon': Icons.more_horiz_rounded, 'color': CategoryColors.other},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الفئة',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.mutedForeground,
          ),
        ),
        const SizedBox(height: AppSpacing.space4),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.2,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            return CategoryItem(
              icon: category['icon'] as IconData,
              label: category['name'] as String,
              color: category['color'] as Color,
              isSelected: selectedCategory == category['name'],
              onTap: () => onCategorySelected?.call(category['name'] as String),
            );
          },
        ),
      ],
    );
  }
}
