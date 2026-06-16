import 'package:flutter/material.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';

class LegendItem extends StatelessWidget {
  final String label;
  final String amount;
  final double percentage;
  final Color color;

  const LegendItem({
    super.key,
    required this.label,
    required this.amount,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
              textDirection: TextDirection.rtl,

      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Label + Dot
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
              Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            
            const SizedBox(width: AppSpacing.space2),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: AppColors.foreground,
              ),
            ),
          
          ],
        ),
        // Amount + Percentage
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              amount,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.foreground,
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            Text(
              '${percentage.toStringAsFixed(0)}٪',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
