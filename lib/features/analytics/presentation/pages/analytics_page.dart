import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/features/analytics/domain/entities/analytics_period.dart';
import 'package:smart_expense/features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:smart_expense/features/analytics/presentation/cubit/analytics_state.dart';
import 'package:smart_expense/features/analytics/presentation/widgets/analytics_chart_card.dart';
import 'package:smart_expense/features/analytics/presentation/widgets/line_chart_card.dart';
import 'package:smart_expense/features/analytics/presentation/widgets/period_segmented_control.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  static const List<String> _arabicMonths = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  static String _periodToString(AnalyticsPeriod period) {
    switch (period) {
      case AnalyticsPeriod.week:
        return 'أسبوع';
      case AnalyticsPeriod.month:
        return 'شهر';
      case AnalyticsPeriod.threeMonths:
        return '٣ أشهر';
      case AnalyticsPeriod.all:
        return 'الكل';
    }
  }

  static AnalyticsPeriod _stringToPeriod(String period) {
    switch (period) {
      case 'أسبوع':
        return AnalyticsPeriod.week;
      case 'شهر':
        return AnalyticsPeriod.month;
      case '٣ أشهر':
        return AnalyticsPeriod.threeMonths;
      case 'الكل':
        return AnalyticsPeriod.all;
      default:
        return AnalyticsPeriod.month;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<AnalyticsCubit, AnalyticsState>(
          builder: (context, state) {
            if (state is AnalyticsLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (state is AnalyticsError) {
              return Center(
                child: Text(
                  state.message,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.destructive,
                  ),
                ),
              );
            }
            if (state is AnalyticsLoaded) {
              return _buildContent(context, state);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AnalyticsLoaded state) {
    // Map spending trend to FlSpot and Arabic labels
    final spots = state.periodSpending.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.amount);
    }).toList();

    final labels = state.periodSpending.map((ps) {
      final parts = ps.label.split('-');
      if (parts.length == 2) {
        final month = int.tryParse(parts[1]);
        if (month != null && month >= 1 && month <= 12) {
          return _arabicMonths[month - 1];
        }
      }
      return ps.label;
    }).toList();

    final totalExpense = NumberFormat('#,##0', 'ar')
        .format(state.summaryResult.totalExpense);
    final comparisonPercentage = state.comparisonPercentage.abs().toStringAsFixed(1);

    return CustomScrollView(
      slivers: [
        // Top breathing room
        SliverToBoxAdapter(
          child: SizedBox(height: AppSpacing.space6),
        ),
        // Title
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
              vertical: AppSpacing.space4,
            ),
            child: Text(
              'التحليلات',
              style: AppTextStyles.display.copyWith(
                color: AppColors.foreground,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),
            child: PeriodSegmentedControl(
              selectedPeriod: _periodToString(state.selectedPeriod),
              onChanged: (period) {
                final analyticsPeriod = _stringToPeriod(period);
                context.read<AnalyticsCubit>().changePeriod(analyticsPeriod);
              },
            ),
          ),
        ),
        // Line Chart Card
        SliverToBoxAdapter(
          child: LineChartCard(
            spots: spots,
            labels: labels,
            totalAmount: totalExpense,
            comparisonLabel: 'مقارنة بالشهر الماضي',
            comparisonPercentage: comparisonPercentage,
            isIncrease: state.isIncrease,
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: AppSpacing.space6)),
        // Expense Breakdown Card
        SliverToBoxAdapter(
          child: AnalyticsChartCard(
            categories: state.categoryBreakdown,
            totalAmount: state.summaryResult.totalExpense,
          ),
        ),
        // Bottom padding
        SliverToBoxAdapter(child: SizedBox(height: AppSpacing.space8)),
      ],
    );
  }
}
