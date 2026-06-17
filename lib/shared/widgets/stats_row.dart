import 'package:flutter/material.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';

class StatsRow extends StatelessWidget {
  final List<StatItem> stats;

  const StatsRow({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: stats.asMap().entries.map((entry) {
        final index = entry.key;
        final stat = entry.value;
        return Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.space2,
            ),
            decoration: index < stats.length - 1
                ? BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: AppColors.withAlpha(
                          AppColors.primaryForeground,
                          0.1,
                        ),
                        width: 1,
                      ),
                    ),
                  )
                : null,
            child: Column(
              children: [
                Text(
                  stat.value,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.primaryForeground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.space1),
                Text(
                  stat.label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.withAlpha(
                      AppColors.primaryForeground,
                      0.6,
                    ),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class StatItem {
  final String label;
  final String value;

  const StatItem({
    required this.label,
    required this.value,
  });
}
