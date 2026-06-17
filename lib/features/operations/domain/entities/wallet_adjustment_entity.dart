class WalletAdjustmentEntity {
  final int id;
  final int walletId;
  final String periodType; // 'daily' or 'monthly'
  final double amount;
  final String? reason;
  final DateTime createdAt;

  WalletAdjustmentEntity({
    required this.id,
    required this.walletId,
    required this.periodType,
    required this.amount,
    this.reason,
    required this.createdAt,
  });
}
