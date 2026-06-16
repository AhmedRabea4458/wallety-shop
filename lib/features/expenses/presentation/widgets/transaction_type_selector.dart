import 'package:flutter/material.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';

/// Segmented control for selecting transaction type (expense vs income).
class TransactionTypeSelector extends StatelessWidget {
  final bool isExpense;
  final ValueChanged<bool> onChanged;

  const TransactionTypeSelector({
    super.key,
    required this.isExpense,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space2),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TypeButton(
              label: 'مصروف',
              isActive: isExpense,
              onTap: () => onChanged(true),
            ),
          ),
          Expanded(
            child: _TypeButton(
              label: 'دخل',
              isActive: !isExpense,
              onTap: () => onChanged(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.space3,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: isActive ? AppColors.primaryForeground : AppColors.mutedForeground,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
