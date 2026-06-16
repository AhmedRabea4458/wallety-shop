abstract class BudgetLocalDataSource {
  Future<double> getMonthlyBudget();
  Future<void> setMonthlyBudget(double value);
}
