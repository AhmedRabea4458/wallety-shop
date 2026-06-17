import 'package:smart_expense/features/operations/domain/entities/wallet_adjustment_entity.dart';

abstract class WalletAdjustmentState {}

class WalletAdjustmentInitial extends WalletAdjustmentState {}

class WalletAdjustmentLoading extends WalletAdjustmentState {}

class WalletAdjustmentLoaded extends WalletAdjustmentState {
  final List<WalletAdjustmentEntity> adjustments;

  WalletAdjustmentLoaded({required this.adjustments});
}

class WalletAdjustmentError extends WalletAdjustmentState {
  final String message;

  WalletAdjustmentError({required this.message});
}
