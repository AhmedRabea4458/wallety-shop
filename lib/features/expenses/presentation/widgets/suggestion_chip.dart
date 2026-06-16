import 'package:flutter/material.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';

/// Smart suggestion chip showing AI/category suggestions.
class SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback? onApply;

  const SuggestionChip({
    super.key,
    required this.label,
    this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space3,
      ),
      decoration: BoxDecoration(
        color: AppColors.withAlpha(AppColors.primary, 0.15),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.space2),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          InkWell(
            onTap: onApply,
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space3,
                vertical: AppSpacing.space1,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                'تطبيق',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primaryForeground,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
