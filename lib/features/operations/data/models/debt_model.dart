import 'package:smart_expense/core/database/app_database.dart';
import 'package:smart_expense/features/operations/domain/entities/debt_entity.dart';

class DebtModel {
  final int id;
  final int debtorId;
  final int? operationId;
  final String operationType;
  final String? providerType;
  final double amount;
  final bool isPaid;
  final DateTime? paidAt;
  final DateTime createdAt;

  DebtModel({
    required this.id,
    required this.debtorId,
    this.operationId,
    required this.operationType,
    this.providerType,
    required this.amount,
    required this.isPaid,
    this.paidAt,
    required this.createdAt,
  });

  DebtEntity toEntity() {
    return DebtEntity(
      id: id,
      debtorId: debtorId,
      operationId: operationId,
      operationType: operationType,
      providerType: providerType,
      amount: amount,
      isPaid: isPaid,
      paidAt: paidAt,
      createdAt: createdAt,
    );
  }

  factory DebtModel.fromEntity(DebtEntity entity) {
    return DebtModel(
      id: entity.id,
      debtorId: entity.debtorId,
      operationId: entity.operationId,
      operationType: entity.operationType,
      providerType: entity.providerType,
      amount: entity.amount,
      isPaid: entity.isPaid,
      paidAt: entity.paidAt,
      createdAt: entity.createdAt,
    );
  }

  factory DebtModel.fromDrift(DebtsTableData data) {
    return DebtModel(
      id: data.id,
      debtorId: data.debtorId,
      operationId: data.operationId,
      operationType: data.operationType,
      providerType: data.providerType,
      amount: data.amount,
      isPaid: data.isPaid,
      paidAt: data.paidAt,
      createdAt: data.createdAt,
    );
  }

  DebtModel copyWith({
    int? id,
  }) {
    return DebtModel(
      id: id ?? this.id,
      debtorId: debtorId,
      operationId: operationId,
      operationType: operationType,
      providerType: providerType,
      amount: amount,
      isPaid: isPaid,
      paidAt: paidAt,
      createdAt: createdAt,
    );
  }
}