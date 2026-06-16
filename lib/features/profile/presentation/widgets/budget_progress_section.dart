import 'package:flutter/material.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';

class BudgetProgressSection extends StatelessWidget {
  final String budgetLabel;
  final String spentLabel;
  final String budgetAmount;
  final String spentAmount;
  final double progress; // 0.0 to 1.0
  final String daysLeft;

  const BudgetProgressSection({
    super.key,
    required this.budgetLabel,
    required this.spentLabel,
    required this.budgetAmount,
    required this.spentAmount,
    required this.progress,
    required this.daysLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      padding: const EdgeInsets.all(AppSpacing.space6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.border50,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                budgetLabel,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
              Text(
                spentLabel,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space3),
          // Amounts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                budgetAmount,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                spentAmount,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space4),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.withAlpha(
                AppColors.foreground,
                0.1,
              ),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          // Days left
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                daysLeft,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}٪',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
