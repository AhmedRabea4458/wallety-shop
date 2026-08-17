import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/features/operations/presentation/cubit/cash_drawer_cubit.dart';
import 'package:smart_expense/features/operations/presentation/widgets/dialogs/edit_cash_drawer_dialog.dart';

class CashDrawerCard extends StatelessWidget {
  final double balance;
  final double initialBalance;
  final DateTime? updatedAt;

  const CashDrawerCard({
    super.key,
    required this.balance,
    required this.initialBalance,
    this.updatedAt,
  });

  static String _formatAmount(double amount) {
    return NumberFormat('#,##0.##', 'ar').format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space5),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border50, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: const Icon(
              Icons.point_of_sale_rounded,
              color: Color(0xFFF59E0B),
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الدرج النقدي',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: AppSpacing.space1),
                Text(
                  '${_formatAmount(balance)} ج.م',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              showEditCashDrawerDialog(
                parentContext: context,
                cashDrawerCubit: context.read<CashDrawerCubit>(),
                currentDrawerBalance: balance,
              );
            },
            icon: const Icon(
              Icons.edit_rounded,
              color: AppColors.mutedForeground,
              size: 18,
            ),
            tooltip: 'تعديل رصيد الدرج',
          ),
        ],
      ),
    );
  }
}
