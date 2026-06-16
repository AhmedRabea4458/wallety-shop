import 'package:flutter/material.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.headline.copyWith(
              color: AppColors.foreground,
            ),
          ),
          if (actionLabel != null)
  InkWell(
    borderRadius: BorderRadius.circular(20),
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space3,
        vertical: AppSpacing.space1,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary10,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AppColors.primary25,
        ),
      ),
      child: Text(
        actionLabel!,
        style: AppTextStyles.body.copyWith(
          color: AppColors.primary,
        ),
      ),
    ),
  ),
        ],
      ),
    );
  }
}