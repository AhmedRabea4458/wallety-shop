import 'package:smart_expense/features/analytics/domain/entities/category_breakdown.dart';
import 'package:smart_expense/features/analytics/domain/entities/period_spending.dart';
import 'package:smart_expense/features/analytics/domain/entities/summary_result.dart';

abstract class AnalyticsRepository {
  Future<SummaryResult> getSummary({DateTime? startDate, DateTime? endDate});

  Future<List<PeriodSpending>> getSpendingTrend({DateTime? startDate, DateTime? endDate});

  Future<List<CategoryBreakdown>> getCategoryBreakdown({DateTime? startDate, DateTime? endDate});
}