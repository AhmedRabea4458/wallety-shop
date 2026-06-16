import 'package:smart_expense/core/database/app_database.dart';
import 'package:smart_expense/features/analytics/data/datasources/local/analytics_local_datasource.dart';
import 'package:smart_expense/features/analytics/domain/entities/category_breakdown.dart';
import 'package:smart_expense/features/analytics/domain/entities/period_spending.dart';
import 'package:smart_expense/features/analytics/domain/entities/summary_result.dart';

class AnalyticsLocalDataSourceImpl implements AnalyticsLocalDataSource {
  final AppDatabase database;

  AnalyticsLocalDataSourceImpl(this.database);

  @override
  Future<SummaryResult> getSummary({DateTime? startDate, DateTime? endDate}) {
    return database.getSummary(startDate: startDate, endDate: endDate);
  }

  @override
  Future<List<CategoryBreakdown>> getCategoryBreakdown({DateTime? startDate, DateTime? endDate}) {
    return database.getCategoryBreakdown(startDate: startDate, endDate: endDate);
  }

  @override
  Future<List<PeriodSpending>> getSpendingTrend({DateTime? startDate, DateTime? endDate}) {
    return database.getSpendingTrend(startDate: startDate, endDate: endDate);
  }
}
