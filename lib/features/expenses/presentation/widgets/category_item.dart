import 'package:flutter/material.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';

/// Reusable category item for the category grid.
class CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryItem({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? color : AppColors.border50,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? AppColors.primaryForeground : color,
            ),
            const SizedBox(height: AppSpacing.space2),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isSelected ? AppColors.primaryForeground : AppColors.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
