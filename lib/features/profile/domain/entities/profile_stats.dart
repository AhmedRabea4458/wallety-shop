class ProviderStats {
  final int operationCount;
  final double totalAmount;
  final double totalCommission;
  final double totalNetworkFee;

  const ProviderStats({
    required this.operationCount,
    required this.totalAmount,
    required this.totalCommission,
    required this.totalNetworkFee,
  });

  const ProviderStats.empty()
      : operationCount = 0,
        totalAmount = 0,
        totalCommission = 0,
        totalNetworkFee = 0;
}

class ProfileStats {
  final int totalTransactions;
  final double totalIncome;
  final double totalExpense;
  final double commission;
  final double networkFee;
  final ProviderStats vodafoneCash;
  final ProviderStats instaPay;

  const ProfileStats({
    required this.totalTransactions,
    required this.totalIncome,
    required this.totalExpense,
    required this.commission,
    required this.networkFee,
    required this.vodafoneCash,
    required this.instaPay,
  });

  const ProfileStats.empty()
      : totalTransactions = 0,
        totalIncome = 0,
        totalExpense = 0,
        commission = 0,
        networkFee = 0,
        vodafoneCash = const ProviderStats.empty(),
        instaPay = const ProviderStats.empty();
}
