import 'package:flutter/material.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';

class TransactionRow extends StatelessWidget {
  final String name;
  final String category;
  final String? date;
  final String amount;
  final Color iconBackgroundColor;
  final Color iconColor;
  final IconData icon;
  final bool isExpense;
  final VoidCallback? onTap;

  const TransactionRow({
    super.key,
    required this.name,
    required this.category,
    this.date,
    required this.amount,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.icon,
    this.isExpense = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space5,
          vertical: AppSpacing.space3,
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconColor,
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            // Name + category + date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.foreground,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: AppSpacing.space1),
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.space2,
                            vertical: AppSpacing.space1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.withAlpha(iconBackgroundColor, 0.15),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            category,
                            style: AppTextStyles.caption.copyWith(
                              color: iconColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                      if (date != null) ...[
                        const SizedBox(width: AppSpacing.space2),
                        Text(
                          '•',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.mutedForeground,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.space2),
                        Flexible(
                          child: Text(
                            date!,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.mutedForeground,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Amount (RTL: leading edge)
            Text(
              isExpense ? '- $amount' : amount,
              style: AppTextStyles.transactionAmount.copyWith(
                color: AppColors.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
