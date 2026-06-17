class CashDrawerEntity {
  final int id;
  final double balance;
  final double initialBalance;
  final DateTime updatedAt;

  CashDrawerEntity({
    required this.id,
    required this.balance,
    required this.initialBalance,
    required this.updatedAt,
  });
}
