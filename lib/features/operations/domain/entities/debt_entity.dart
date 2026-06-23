class DebtEntity {
  final int id;
  final int debtorId;
  final int? operationId;
  final String operationType;
  final String? providerType;
  final double amount;
  final bool isPaid;
  final bool isCashLoan;
  final DateTime? paidAt;
  final DateTime createdAt;

  const DebtEntity({
    required this.id,
    required this.debtorId,
    this.operationId,
    required this.operationType,
    this.providerType,
    required this.amount,
    required this.isPaid,
    this.isCashLoan = false,
    this.paidAt,
    required this.createdAt,
  });
}