import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';


class LineChartWidget extends StatelessWidget {
  final List<FlSpot> spots;
  final List<String>? labels;

  const LineChartWidget({
    super.key,
    required this.spots,
    this.labels,
  });

  List<String> get _labels =>
      labels ??
      const [
        'يناير',
        'فبراير',
        'مارس',
        'أبريل',
        'مايو',
        'يونيو',
      ];

  @override
  Widget build(BuildContext context) {
    if (spots.isEmpty) {
      return Center(
        child: Text(
          'لا توجد بيانات',
          style: AppTextStyles.body.copyWith(
            color: AppColors.mutedForeground,
          ),
        ),
      );
    }

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: spots.length - 1.0,
        minY: 0,
        maxY: _calculateMaxY() * 1.2,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _calculateHorizontalInterval(),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.withAlpha(AppColors.foreground, 0.05),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= _labels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.space2),
                  child: Text(
                    _labels[index],
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => AppColors.card,
            tooltipBorderRadius: AppRadius.mdAll,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(0)} ج.م',
                  AppTextStyles.body.copyWith(
                    color: AppColors.foreground,
                  ),
                );
              }).toList();
            },
          ),
          getTouchedSpotIndicator: (barData, spotIndexes) {
            return spotIndexes.map((index) {
              return TouchedSpotIndicatorData(
                FlLine(
                  color: AppColors.withAlpha(AppColors.primary, 0.2),
                  strokeWidth: 1,
                ),
                FlDotData(
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 6,
                      color: AppColors.background,
                      strokeWidth: 3,
                      strokeColor: AppColors.primary,
                    );
                  },
                ),
              );
            }).toList();
          },
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.background,
                  strokeWidth: 2,
                  strokeColor: AppColors.primary,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.withAlpha(AppColors.primary, 0.3),
                  AppColors.withAlpha(AppColors.primary, 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateMaxY() {
    if (spots.isEmpty) return 100;
    return spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
  }

  double _calculateHorizontalInterval() {
    final maxY = _calculateMaxY();
    if (maxY <= 0) return 100;
    return maxY / 4;
  }
}
