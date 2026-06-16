class ProfileStats {
  final int totalTransactions;
  final double totalIncome;
  final double totalExpense;
  final double savingsRate;

  const ProfileStats({
    required this.totalTransactions,
    required this.totalIncome,
    required this.totalExpense,
    required this.savingsRate,
  });

  const ProfileStats.empty()
      : totalTransactions = 0,
        totalIncome = 0,
        totalExpense = 0,
        savingsRate = 0;
}