class DebtPaymentEntity {
  final int id;
  final int debtId;
  final double amount;
  final String? notes;
  final String paymentMethod;
  final DateTime createdAt;

  const DebtPaymentEntity({
    required this.id,
    required this.debtId,
    required this.amount,
    this.notes,
    this.paymentMethod = 'cash',
    required this.createdAt,
  });
}
