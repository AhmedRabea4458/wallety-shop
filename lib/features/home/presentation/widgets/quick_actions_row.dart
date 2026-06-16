import 'package:flutter/material.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/shared/widgets/quick_action_button.dart';

class QuickActionsRow extends StatelessWidget {
  final VoidCallback? onAddIncome;
  final VoidCallback? onAddExpense;

  const QuickActionsRow({
    super.key,
    this.onAddIncome,
    this.onAddExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Row(
        children: [
          Expanded(
            child: QuickActionButton(
              label: 'إضافة دخل',
              icon: Icons.arrow_downward_rounded,
              backgroundColor: AppColors.withAlpha(
                AppColors.success,
                0.15,
              ),
              textColor: AppColors.success,
              iconColor: AppColors.success,
              onTap: onAddIncome,
            ),
          ),
          const SizedBox(width: AppSpacing.space2),
          Expanded(
            child: QuickActionButton(
              label: 'إضافة مصروف',
              icon: Icons.add_rounded,
              gradient: AppColors.ctaGradientLinear,
              textColor: AppColors.primaryForeground,
              iconColor: AppColors.primaryForeground,
              onTap: onAddExpense,
            ),
          ),
        ],
      ),
    );
  }
}

