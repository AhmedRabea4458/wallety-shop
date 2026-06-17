import 'package:smart_expense/core/database/app_database.dart';
import 'package:smart_expense/features/operations/domain/entities/wallet_adjustment_entity.dart';

class WalletAdjustmentModel {
  final int id;
  final int walletId;
  final String periodType;
  final double amount;
  final String? reason;
  final DateTime createdAt;

  WalletAdjustmentModel({
    required this.id,
    required this.walletId,
    required this.periodType,
    required this.amount,
    this.reason,
    required this.createdAt,
  });

  WalletAdjustmentEntity toEntity() {
    return WalletAdjustmentEntity(
      id: id,
      walletId: walletId,
      periodType: periodType,
      amount: amount,
      reason: reason,
      createdAt: createdAt,
    );
  }

  factory WalletAdjustmentModel.fromEntity(WalletAdjustmentEntity entity) {
    return WalletAdjustmentModel(
      id: entity.id,
      walletId: entity.walletId,
      periodType: entity.periodType,
      amount: entity.amount,
      reason: entity.reason,
      createdAt: entity.createdAt,
    );
  }

  factory WalletAdjustmentModel.fromDrift(WalletAdjustmentsTableData data) {
    return WalletAdjustmentModel(
      id: data.id,
      walletId: data.walletId,
      periodType: data.periodType,
      amount: data.amount,
      reason: data.reason,
      createdAt: data.createdAt,
    );
  }
}
