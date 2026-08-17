import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/features/operations/presentation/cubit/cash_drawer_cubit.dart';
import 'package:smart_expense/features/operations/presentation/widgets/dialogs/edit_cash_drawer_dialog.dart';

/// The main hero balance card displayed on the home page.
///
/// Shows total balance, cash drawer, receivables, payables, and today's breakdown
/// (deposits, withdrawals, debt collections, payable settlements).
class HeroBalanceCard extends StatelessWidget {
  final double totalWalletBalance;
  final double cashDrawerBalance;
  final double customerReceivables;
  final double payables;
  final double todayDeposits;
  final double todayWithdrawals;
  final double todayCollections;
  final double todaySettlements;

  const HeroBalanceCard({
    super.key,
    required this.totalWalletBalance,
    required this.cashDrawerBalance,
    required this.customerReceivables,
    required this.payables,
    required this.todayDeposits,
    required this.todayWithdrawals,
    required this.todayCollections,
    required this.todaySettlements,
  });

  static String _formatAmount(double amount) {
    return NumberFormat('#,##0.##', 'ar').format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      padding: const EdgeInsets.all(AppSpacing.space6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF4F46E5),
            Color(0xFF7C3AED),
            Color(0xFF9333EA),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Primary Balances (Wallets & Cash Drawer)
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'رصيد المحافظ',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space1),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              _formatAmount(totalWalletBalance),
                              style: AppTextStyles.headline.copyWith(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'ج.م',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 48,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: InkWell(
                  onTap: () {
                    showEditCashDrawerDialog(
                      parentContext: context,
                      cashDrawerCubit: context.read<CashDrawerCubit>(),
                      currentDrawerBalance: cashDrawerBalance,
                    );
                  },
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space1,
                      vertical: AppSpacing.space1,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'الدرج النقدي',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.edit_rounded,
                              size: 14,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.space1),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  _formatAmount(cashDrawerBalance),
                                  style: AppTextStyles.headline.copyWith(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'ج.م',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space4),
          Divider(
            color: Colors.white.withValues(alpha: 0.15),
            thickness: 1,
            height: 1,
          ),
          const SizedBox(height: AppSpacing.space4),
          // Row 2: Receivables & Payables
          Row(
            children: [
              Expanded(
                child: _HeroStat(
                  label: 'آجل العملاء (لنا)',
                  value: '${_formatAmount(customerReceivables)} ج.م',
                  icon: Icons.arrow_downward_rounded,
                  iconColor: const Color(0xFFFBBF24), // Amber
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.15),
              ),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: _HeroStat(
                  label: 'مستحقات علينا',
                  value: '${_formatAmount(payables)} ج.م',
                  icon: Icons.arrow_upward_rounded,
                  iconColor: const Color(0xFFFB923C), // Orange
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space4),
          Divider(
            color: Colors.white.withValues(alpha: 0.15),
            thickness: 1,
            height: 1,
          ),
          const SizedBox(height: AppSpacing.space4),
          // Section Title: نشاط اليوم
          Text(
            'نشاط اليوم',
            style: AppTextStyles.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.75),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          // Row 3: Today's Operations (Deposits & Withdrawals)
          Row(
            children: [
              Expanded(
                child: _HeroStat(
                  label: 'إيداعات اليوم',
                  value: '${_formatAmount(todayDeposits)} ج.م',
                  icon: Icons.north_east_rounded,
                  iconColor: const Color(0xFFF87171), // Red/Deposit
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.15),
              ),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: _HeroStat(
                  label: 'سحوبات اليوم',
                  value: '${_formatAmount(todayWithdrawals)} ج.م',
                  icon: Icons.south_west_rounded,
                  iconColor: const Color(0xFF4ADE80), // Green/Withdrawal
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space3),
          // Row 4: Today's Debt Collections & Payable Settlements
          Row(
            children: [
              Expanded(
                child: _HeroStat(
                  label: 'تحصيلات الآجل اليوم',
                  value: '${_formatAmount(todayCollections)} ج.م',
                  icon: Icons.price_check_rounded,
                  iconColor: const Color(0xFF38BDF8), // Light Blue
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.15),
              ),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: _HeroStat(
                  label: 'سداد المستحقات اليوم',
                  value: '${_formatAmount(todaySettlements)} ج.م',
                  icon: Icons.handshake_outlined,
                  iconColor: const Color(0xFFA78BFA), // Purple
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;

  const _HeroStat({
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: AppSpacing.space1),
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: iconColor ?? Colors.white.withValues(alpha: 0.8),
            ),
            const SizedBox(width: AppSpacing.space2),
            Flexible(
              child: Text(
                value,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
