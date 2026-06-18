import 'package:flutter/material.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/shared/widgets/stats_row.dart';

class ProfileCard extends StatelessWidget {
  final List<StatItem> stats;

  const ProfileCard({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      padding: const EdgeInsets.all(AppSpacing.space6),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradientLinear,
        borderRadius: BorderRadius.circular(AppRadius.heroCard),
      ),
      child: Column(
        children: [
          // Icon + Title
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.withAlpha(
                    AppColors.primaryForeground,
                    0.2,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: const Center(
                  child: Icon(
                    Icons.account_balance_wallet,
                    color: AppColors.primaryForeground,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.space4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ملخص المحل',
                      style: AppTextStyles.headline.copyWith(
                        color: AppColors.primaryForeground,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space1),
                    Text(
                      'إحصائيات عمليات Vodafone Cash و InstaPay',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.withAlpha(
                          AppColors.primaryForeground,
                          0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space6),
          // Divider
          Divider(
            color: AppColors.withAlpha(
              AppColors.primaryForeground,
              0.1,
            ),
            thickness: 1,
            height: 1,
          ),
          const SizedBox(height: AppSpacing.space4),
          // Stats
          StatsRow(stats: stats),
        ],
      ),
    );
  }
}
