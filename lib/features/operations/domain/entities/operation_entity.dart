import 'package:smart_expense/features/operations/domain/entities/provider_type.dart';

enum OperationType {
  deposit,
  withdrawal,
}

class OperationEntity {
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

  OperationEntity({
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
}
