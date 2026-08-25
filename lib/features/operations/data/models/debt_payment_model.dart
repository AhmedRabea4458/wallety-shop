
import 'package:smart_expense/core/database/app_database.dart';
import 'package:smart_expense/features/operations/domain/entities/debt_payment_entity.dart';

class DebtPaymentModel {
  final int id;
  final int debtId;
  final int? walletId;
  final double amount;
  final String? notes;
  final String paymentMethod;
  final DateTime createdAt;

  DebtPaymentModel({
    required this.id,
    required this.debtId,
    this.walletId,
    required this.amount,
    this.notes,
    required this.paymentMethod,
    required this.createdAt,
  });

  DebtPaymentEntity toEntity() {
    return DebtPaymentEntity(
      id: id,
      debtId: debtId,
      walletId: walletId,
      amount: amount,
      notes: notes,
      paymentMethod: paymentMethod,
      createdAt: createdAt,
    );
  }

  factory DebtPaymentModel.fromEntity(DebtPaymentEntity entity) {
    return DebtPaymentModel(
      id: entity.id,
      debtId: entity.debtId,
      walletId: entity.walletId,
      amount: entity.amount,
      notes: entity.notes,
      paymentMethod: entity.paymentMethod,
      createdAt: entity.createdAt,
    );
  }

  factory DebtPaymentModel.fromDrift(DebtPaymentsTableData data) {
    return DebtPaymentModel(
      id: data.id,
      debtId: data.debtId,
      walletId: data.walletId,
      amount: data.amount,
      notes: data.notes,
      paymentMethod: data.paymentMethod,
      createdAt: data.createdAt,
    );
  }
}
