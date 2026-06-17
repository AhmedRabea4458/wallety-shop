import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/features/analytics/domain/entities/category_breakdown.dart';
import 'package:smart_expense/features/analytics/presentation/widgets/donut_chart_widget.dart';
import 'package:smart_expense/features/analytics/presentation/widgets/legend_item.dart';

class AnalyticsChartCard extends StatelessWidget {
  final List<CategoryBreakdown> categories;
  final double totalAmount;
  final EdgeInsets? padding;

  const AnalyticsChartCard({
    super.key,
    required this.categories,
    required this.totalAmount,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      padding: padding ?? const EdgeInsets.all(AppSpacing.space6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.heroCard),
        border: Border.all(color: AppColors.border50, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'تفصيل الإنفاق',
            style: AppTextStyles.headline.copyWith(color: AppColors.foreground),
          ),
          const SizedBox(height: AppSpacing.space6),
          if (categories.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.space6),
                child: Text(
                  'لا توجد مصروفات مسجلة',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ),
            )
          else
            // Row: Donut Chart + Legend
            Row(
              children: [
                // Legend
                Expanded(
                  child: Column(
                    children: categories.map((category) {
                      return Column(
                        children: [
                          LegendItem(
                            label: category.category,
                            amount: NumberFormat('#,##0', 'ar').format(category.amount),
                            percentage: category.percentage,
                            color: category.color,
                          ),
                          if (category != categories.last)
                            const SizedBox(height: AppSpacing.space3),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: AppSpacing.space4),
                // Donut Chart
                DonutChartWidget(
                  categories: categories,
                  totalAmount: NumberFormat('#,##0', 'ar').format(totalAmount),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
