import 'package:flutter/material.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';

class TransactionGroupHeader extends StatelessWidget {
  final String label;

  const TransactionGroupHeader({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.space2,
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: AppColors.mutedForeground,
          ),
        ),
      ),
    );
  }
}
