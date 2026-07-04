import 'package:smart_expense/features/operations/domain/entities/debt_type.dart';

class DebtEntity {
  final int id;
  final int debtorId;
  final int? operationId;
  final String operationType;
  final String? providerType;
  final double amount;
  final bool isPaid;
  final bool isCashLoan;
  final DebtType debtType;
  final String? notes;
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
    this.debtType = DebtType.customerDebt,
    this.notes,
    this.paidAt,
    required this.createdAt,
  });
}