import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/features/analytics/presentation/widgets/line_chart_widget.dart';

class LineChartCard extends StatelessWidget {
  final List<FlSpot> spots;
  final List<String>? labels;
  final String totalAmount;
  final String comparisonLabel;
  final String comparisonPercentage;
  final bool isIncrease;

  const LineChartCard({
    super.key,
    required this.spots,
    this.labels,
    required this.totalAmount,
    this.comparisonLabel = 'مقارنة بالشهر الماضي',
    this.comparisonPercentage = '٨.٥',
    this.isIncrease = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      padding: const EdgeInsets.all(AppSpacing.space6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.heroCard),
        border: Border.all(
          color: AppColors.border50,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'اتجاه الإنفاق الشهري',
                style: AppTextStyles.headline.copyWith(
                  color: AppColors.foreground,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space3,
                  vertical: AppSpacing.space1,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  totalAmount,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primaryForeground,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space6),
          // Chart
          if (spots.length < 2)
            SizedBox(
              height: 210,
              child: Center(
                child: Text(
                  'أضف معاملات أكثر لرؤية الاتجاه',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 210,
              child: LineChartWidget(spots: spots, labels: labels),
            ),
          const SizedBox(height: AppSpacing.space4),
          // Comparison indicator
          if (spots.length >= 2)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isIncrease ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                  size: 14,
                  color: isIncrease ? AppColors.destructive : AppColors.success,
                ),
                const SizedBox(width: AppSpacing.space1),
                Text(
                  comparisonPercentage,
                  style: AppTextStyles.caption.copyWith(
                    color: isIncrease ? AppColors.destructive : AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: AppSpacing.space2),
                Text(
                  comparisonLabel,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
