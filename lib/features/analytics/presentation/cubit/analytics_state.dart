import 'package:smart_expense/features/analytics/domain/entities/analytics_period.dart';
import 'package:smart_expense/features/analytics/domain/entities/category_breakdown.dart';
import 'package:smart_expense/features/analytics/domain/entities/period_spending.dart';
import 'package:smart_expense/features/analytics/domain/entities/summary_result.dart';

abstract class AnalyticsState {}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {}

class AnalyticsLoaded extends AnalyticsState {
  final List<CategoryBreakdown> categoryBreakdown;
  final List<PeriodSpending> periodSpending;
  final SummaryResult summaryResult;
  final double comparisonPercentage;
  final bool isIncrease;
  final AnalyticsPeriod selectedPeriod;

  AnalyticsLoaded({
    required this.categoryBreakdown,
    required this.periodSpending,
    required this.summaryResult,
    this.comparisonPercentage = 0,
    this.isIncrease = false,
    this.selectedPeriod = AnalyticsPeriod.month,
  });
}

class AnalyticsError extends AnalyticsState {
  final String message;

  AnalyticsError(this.message);
}
  