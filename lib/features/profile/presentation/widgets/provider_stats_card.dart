import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/features/profile/domain/entities/profile_stats.dart';

class ProviderStatsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final ProviderStats stats;

  const ProviderStatsCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.stats,
  });

  static String _format(double amount) {
    return NumberFormat('#,##0.##', 'ar').format(amount);
  }

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
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space4),
          _StatRow(label: 'عدد العمليات', value: stats.operationCount.toString()),
          const SizedBox(height: AppSpacing.space2),
          _StatRow(label: 'إجمالي المبالغ', value: '${_format(stats.totalAmount)} ج.م'),
          const SizedBox(height: AppSpacing.space2),
          _StatRow(label: 'إجمالي العمولات', value: '${_format(stats.totalCommission)} ج.م'),
          const SizedBox(height: AppSpacing.space2),
          _StatRow(label: 'رسوم الشبكة', value: '${_format(stats.totalNetworkFee)} ج.م'),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: AppColors.mutedForeground,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            color: AppColors.foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
