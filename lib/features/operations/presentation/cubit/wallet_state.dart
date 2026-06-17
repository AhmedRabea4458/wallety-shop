import 'package:smart_expense/features/operations/domain/entities/wallet_entity.dart';

abstract class WalletState {}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final List<WalletEntity> wallets;

  WalletLoaded({required this.wallets});
}

class WalletError extends WalletState {
  final String message;

  WalletError(this.message);
}
