import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/features/operations/domain/entities/wallet_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/wallet_usage.dart';
import 'package:smart_expense/features/operations/presentation/widgets/wallet_limit_indicator.dart';

/// A compact card showing a wallet's balance and usage limits.
///
/// Used in the horizontal wallet list on the home page.
class HomeWalletCard extends StatelessWidget {
  final WalletEntity wallet;
  final WalletUsage usage;

  const HomeWalletCard({
    super.key,
    required this.wallet,
    required this.usage,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: wallet.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.space2),
              Expanded(
                child: Text(
                  wallet.name,
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
              '${NumberFormat('#,##0.##', 'ar').format(wallet.balance)} ج.م',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          WalletLimitIndicator(
            label: 'يومي',
            used: usage.dailyUsed,
            limit: usage.dailyLimit,
          ),
          const SizedBox(height: AppSpacing.space2),
          WalletLimitIndicator(
            label: 'شهري',
            used: usage.monthlyUsed,
            limit: usage.monthlyLimit,
          ),
        ],
      ),
    );
  }
}
