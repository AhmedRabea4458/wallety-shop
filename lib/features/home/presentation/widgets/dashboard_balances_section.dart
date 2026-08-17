import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';

String _formatAmount(double amount) {
  return NumberFormat('#,##0.##', 'ar').format(amount);
}

/// Dashboard Current Balances Component
/// Displays Cash Drawer, Total Wallet Balance, Customer Receivables, and Payables
/// as clean, separated, responsive cards.
class DashboardBalancesSection extends StatelessWidget {
  final double totalWalletBalance;
  final double cashDrawerBalance;
  final double customerReceivables;
  final double payables;
  final VoidCallback? onEditCashDrawer;

  const DashboardBalancesSection({
    super.key,
    required this.totalWalletBalance,
    required this.cashDrawerBalance,
    required this.customerReceivables,
    required this.payables,
    this.onEditCashDrawer,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الأرصدة الحالية',
            style: AppTextStyles.headline.copyWith(
              color: AppColors.foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.space3),

          // Primary Balance Cards: Cash Drawer & Total Wallets
          Row(
            children: [
              // Cash Drawer Card
              Expanded(
                child: _BalanceCard(
                  title: 'الدرج النقدي',
                  amount: cashDrawerBalance,
                  icon: Icons.point_of_sale_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  iconBgColor: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                  actionIcon: Icons.edit_rounded,
                  onAction: onEditCashDrawer,
                  actionTooltip: 'تعديل رصيد الدرج',
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
              // Total Wallets Card
              Expanded(
                child: _BalanceCard(
                  title: 'إجمالي المحافظ',
                  amount: totalWalletBalance,
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: AppColors.primary,
                  iconBgColor: AppColors.primary.withValues(alpha: 0.12),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space3),

          // Secondary Liabilities Cards: Receivables & Payables (Separated)
          Row(
            children: [
              // Customer Receivables (لنا)
              Expanded(
                child: _BalanceCard(
                  title: 'آجل العملاء (لنا)',
                  amount: customerReceivables,
                  icon: Icons.arrow_downward_rounded,
                  iconColor: const Color(0xFF10B981),
                  iconBgColor: const Color(0xFF10B981).withValues(alpha: 0.12),
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
              // Payables (علينا)
              Expanded(
                child: _BalanceCard(
                  title: 'مستحقات (علينا)',
                  amount: payables,
                  icon: Icons.arrow_upward_rounded,
                  iconColor: const Color(0xFFF97316),
                  iconBgColor: const Color(0xFFF97316).withValues(alpha: 0.12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final IconData? actionIcon;
  final VoidCallback? onAction;
  final String? actionTooltip;

  const _BalanceCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    this.actionIcon,
    this.onAction,
    this.actionTooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space4),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 18,
                ),
              ),
              if (actionIcon != null && onAction != null)
                IconButton(
                  onPressed: onAction,
                  icon: Icon(
                    actionIcon,
                    color: AppColors.mutedForeground,
                    size: 16,
                  ),
                  tooltip: actionTooltip,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.space3),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.mutedForeground,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.space1),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Row(
              children: [
                Text(
                  _formatAmount(amount),
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.foreground,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'ج.م',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
