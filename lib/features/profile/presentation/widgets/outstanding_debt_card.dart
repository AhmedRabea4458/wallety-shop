import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/features/operations/presentation/cubit/debt_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/debt_state.dart';

class OutstandingDebtCard extends StatelessWidget {
  const OutstandingDebtCard({super.key});

  String _formatAmount(double amount) {
    return NumberFormat('#,##0.##', 'ar').format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DebtCubit, DebtState>(
      builder: (context, debtState) {
        final debtCubit = context.read<DebtCubit>();
        final totalOutstanding = debtCubit.totalOutstanding;
        final totalCustomerDebt = debtCubit.totalOutstandingCustomerDebt;
        final totalSettlementDebt = debtCubit.totalOutstandingSettlementDebt;
        final unpaidDebts = debtCubit.unpaidDebts;
        
        if (totalOutstanding > 0) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.space4),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: const Icon(Icons.credit_card_off_rounded, color: AppColors.warning, size: 20),
                      ),
                      const SizedBox(width: AppSpacing.space3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إجمالي الآجل',
                              style: AppTextStyles.caption.copyWith(color: AppColors.mutedForeground),
                            ),
                            Text(
                              '${_formatAmount(totalOutstanding)} ج.م',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.foreground,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${unpaidDebts.length} دين',
                        style: AppTextStyles.caption.copyWith(color: AppColors.mutedForeground),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  const Divider(),
                  const SizedBox(height: AppSpacing.space2),
                  _debtTypeRow('ديون العملاء', totalCustomerDebt, AppColors.warning),
                  const SizedBox(height: AppSpacing.space2),
                  _debtTypeRow('ديون التسوية', totalSettlementDebt, AppColors.primary),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _debtTypeRow(String label, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.mutedForeground)),
        Text('${_formatAmount(amount)} ج.م',
            style: AppTextStyles.body.copyWith(color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
