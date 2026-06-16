import 'package:flutter/material.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';

class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const FilterChipWidget({
    super.key,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space2,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: isActive
              ? null
              : Border.all(
                  color: AppColors.border50,
                  width: 1,
                ),
        ),
        child: Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: isActive ? AppColors.primaryForeground : AppColors.mutedForeground,
          ),
        ),
      ),
    );
  }
}
