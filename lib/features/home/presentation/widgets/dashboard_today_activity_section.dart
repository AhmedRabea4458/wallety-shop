import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';

String _formatAmount(double amount) {
  return NumberFormat('#,##0.##', 'ar').format(amount);
}

/// Dashboard Today's Activity Section
/// Displays Deposits, Withdrawals, Debt Collections, Payable Settlements, and Total Commissions.
class DashboardTodayActivitySection extends StatelessWidget {
  final double todayDeposits;
  final double todayWithdrawals;
  final double todayCollections;
  final double todaySettlements;
  final double totalCommissions;

  const DashboardTodayActivitySection({
    super.key,
    required this.todayDeposits,
    required this.todayWithdrawals,
    required this.todayCollections,
    required this.todaySettlements,
    required this.totalCommissions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.space5),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border50, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space2),
                    Text(
                      'نشاط اليوم',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.foreground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                // Total Commissions pill tag
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space3,
                    vertical: AppSpacing.space1,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.monetization_on_outlined,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'العمولات: ${_formatAmount(totalCommissions)} ج.م',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space4),

            // Operations Row: Deposits & Withdrawals
            Row(
              children: [
                Expanded(
                  child: _ActivityItem(
                    label: 'إيداعات اليوم',
                    amount: todayDeposits,
                    icon: Icons.north_east_rounded,
                    color: AppColors.destructive,
                  ),
                ),
                Container(width: 1, height: 36, color: AppColors.border50),
                const SizedBox(width: AppSpacing.space3),
                Expanded(
                  child: _ActivityItem(
                    label: 'سحوبات اليوم',
                    amount: todayWithdrawals,
                    icon: Icons.south_west_rounded,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space3),
            Divider(color: AppColors.border50, height: 1, thickness: 1),
            const SizedBox(height: AppSpacing.space3),

            // Debts Row: Debt Collections & Payable Settlements
            Row(
              children: [
                Expanded(
                  child: _ActivityItem(
                    label: 'تحصيل آجل اليوم',
                    amount: todayCollections,
                    icon: Icons.price_check_rounded,
                    color: const Color(0xFF0284C7),
                  ),
                ),
                Container(width: 1, height: 36, color: AppColors.border50),
                const SizedBox(width: AppSpacing.space3),
                Expanded(
                  child: _ActivityItem(
                    label: 'سداد مستحقات اليوم',
                    amount: todaySettlements,
                    icon: Icons.handshake_outlined,
                    color: const Color(0xFF8B5CF6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;

  const _ActivityItem({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.mutedForeground,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space1),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: Text(
            '${_formatAmount(amount)} ج.م',
            style: AppTextStyles.body.copyWith(
              color: AppColors.foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
