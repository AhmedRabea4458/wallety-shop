import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_expense/features/profile/data/datasources/local/budget_local_datasource.dart';

class BudgetLocalDataSourceImpl implements BudgetLocalDataSource {
  final SharedPreferences _prefs;

  static const String _budgetKey = 'monthly_budget';

  BudgetLocalDataSourceImpl(this._prefs);

  @override
  Future<double> getMonthlyBudget() async {
    return _prefs.getDouble(_budgetKey) ?? 3500.0;
  }

  @override
  Future<void> setMonthlyBudget(double value) async {
    await _prefs.setDouble(_budgetKey, value);
  }
}
