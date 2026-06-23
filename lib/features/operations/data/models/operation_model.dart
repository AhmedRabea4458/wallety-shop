import 'package:smart_expense/core/database/app_database.dart';
import 'package:smart_expense/features/operations/domain/entities/operation_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/provider_type.dart';

class OperationModel {
  final int id;
  final int walletId;
  final OperationType operationType;
  final ProviderType providerType;
  final double amount;
  final double commission;
  final double networkFee;
  final int? shiftId;
  final int? instaPayAccountId;
  final String? phoneNumber;
  final String? notes;
  final DateTime createdAt;

  OperationModel({
    required this.id,
    required this.walletId,
    required this.operationType,
    this.providerType = ProviderType.vodafoneCash,
    required this.amount,
    this.commission = 0.0,
    this.networkFee = 0.0,
    this.shiftId,
    this.instaPayAccountId,
    this.phoneNumber,
    this.notes,
    required this.createdAt,
  });

  OperationEntity toEntity() {
    return OperationEntity(
      id: id,
      walletId: walletId,
      operationType: operationType,
      providerType: providerType,
      amount: amount,
      commission: commission,
      networkFee: networkFee,
      shiftId: shiftId,
      instaPayAccountId: instaPayAccountId,
      phoneNumber: phoneNumber,
      notes: notes,
      createdAt: createdAt,
    );
  }

  factory OperationModel.fromEntity(OperationEntity entity) {
    return OperationModel(
      id: entity.id,
      walletId: entity.walletId,
      operationType: entity.operationType,
      providerType: entity.providerType,
      amount: entity.amount,
      commission: entity.commission,
      networkFee: entity.networkFee,
      shiftId: entity.shiftId,
      instaPayAccountId: entity.instaPayAccountId,
      phoneNumber: entity.phoneNumber,
      notes: entity.notes,
      createdAt: entity.createdAt,
    );
  }

  factory OperationModel.fromDrift(OperationsTableData data) {
    return OperationModel(
      id: data.id,
      walletId: data.walletId,
      operationType: _typeFromString(data.operationType),
      providerType: _providerFromString(data.providerType),
      amount: data.amount,
      commission: data.commission,
      networkFee: data.networkFee,
      shiftId: data.shiftId,
      instaPayAccountId: data.instaPayAccountId,
      phoneNumber: data.phoneNumber,
      notes: data.notes,
      createdAt: data.createdAt,
    );
  }

  static OperationType _typeFromString(String value) {
    switch (value) {
      case 'deposit':
      case 'إيداع':
        return OperationType.deposit;
      case 'withdrawal':
      case 'سحب':
        return OperationType.withdrawal;
      default:
        return OperationType.deposit;
    }
  }

  static ProviderType _providerFromString(String? value) {
    switch (value) {
      case 'instaPay':
        return ProviderType.instaPay;
      case 'vodafoneCash':
      default:
        return ProviderType.vodafoneCash;
    }
  }
}
