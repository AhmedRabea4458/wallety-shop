import 'package:smart_expense/features/analytics/data/datasources/local/analytics_local_datasource.dart';
import 'package:smart_expense/features/analytics/domain/entities/category_breakdown.dart';
import 'package:smart_expense/features/analytics/domain/entities/period_spending.dart';
import 'package:smart_expense/features/analytics/domain/entities/summary_result.dart';
import 'package:smart_expense/features/analytics/domain/repositories/analytics_repository.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsLocalDataSource localDataSource;

  AnalyticsRepositoryImpl(this.localDataSource);

  @override
  Future<List<CategoryBreakdown>> getCategoryBreakdown({DateTime? startDate, DateTime? endDate}) {
    return localDataSource.getCategoryBreakdown(startDate: startDate, endDate: endDate);
  }

  @override
  Future<List<PeriodSpending>> getSpendingTrend({DateTime? startDate, DateTime? endDate}) {
    return localDataSource.getSpendingTrend(startDate: startDate, endDate: endDate);
  }

  @override
  Future<SummaryResult> getSummary({DateTime? startDate, DateTime? endDate}) {
    return localDataSource.getSummary(startDate: startDate, endDate: endDate).then((result) {
      return SummaryResult(
        totalIncome: result.totalIncome,
        totalExpense: result.totalExpense,
        balance: result.balance,
      );
    });
  }
}