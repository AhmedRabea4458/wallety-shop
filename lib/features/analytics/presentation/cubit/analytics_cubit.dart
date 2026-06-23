import 'package:bloc/bloc.dart';
import 'package:smart_expense/core/errors/error_mapper.dart';
import 'package:smart_expense/features/analytics/domain/entities/analytics_period.dart';
import 'package:smart_expense/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:smart_expense/features/analytics/presentation/cubit/analytics_state.dart';

class AnalyticsCubit extends Cubit<AnalyticsState> {
  final AnalyticsRepository repository;

  AnalyticsPeriod _selectedPeriod = AnalyticsPeriod.month;

  AnalyticsCubit(this.repository) : super(AnalyticsInitial());

  Future<void> loadAnalytics() async {
    emit(AnalyticsLoading());
    await _fetchAndEmit();
  }

  /// Background refresh without showing loading spinner.
  Future<void> silentReload() async {
    await _fetchAndEmit();
  }

  Future<void> changePeriod(AnalyticsPeriod period) async {
    _selectedPeriod = period;
    emit(AnalyticsLoading());
    await _fetchAndEmit();
  }

  DateTime? _getStartDate() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case AnalyticsPeriod.week:
        return now.subtract(const Duration(days: 7));
      case AnalyticsPeriod.month:
        return DateTime(now.year, now.month, 1);
      case AnalyticsPeriod.threeMonths:
        return now.subtract(const Duration(days: 90));
      case AnalyticsPeriod.all:
        return null;
    }
  }

  DateTime? _getEndDate() {
    if (_selectedPeriod == AnalyticsPeriod.all) {
      return null;
    }
    return DateTime.now();
  }

  Future<void> _fetchAndEmit() async {
    try {
      final startDate = _getStartDate();
      final endDate = _getEndDate();

      final summary = await repository.getSummary(startDate: startDate, endDate: endDate);
      final categoryBreakdown = await repository.getCategoryBreakdown(startDate: startDate, endDate: endDate);
      final monthlySpending = await repository.getSpendingTrend(startDate: startDate, endDate: endDate);

      // Calculate period comparison from spending trend
      double comparisonPercentage = 0;
      bool isIncrease = false;
      if (monthlySpending.length >= 2) {
        final last = monthlySpending.last.amount;
        final previous = monthlySpending[monthlySpending.length - 2].amount;
        if (previous > 0) {
          comparisonPercentage = ((last - previous) / previous) * 100;
          isIncrease = last > previous;
        }
      }

      emit(AnalyticsLoaded(
        summaryResult: summary,
        categoryBreakdown: categoryBreakdown,
        periodSpending: monthlySpending,
        comparisonPercentage: comparisonPercentage,
        isIncrease: isIncrease,
        selectedPeriod: _selectedPeriod,
      ));
    } catch (e) {
      emit(AnalyticsError('فشل تحميل التحليلات: ${ErrorMapper.map(e)}'));
    }
  }
}