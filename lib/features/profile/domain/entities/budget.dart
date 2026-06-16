class Budget {
  final double monthlyBudget;

  const Budget({
    required this.monthlyBudget,
  });

  Budget.empty() : monthlyBudget = 0;
}
