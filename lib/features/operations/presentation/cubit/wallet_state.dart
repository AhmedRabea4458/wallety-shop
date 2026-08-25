import 'package:smart_expense/features/operations/domain/entities/wallet_entity.dart';

abstract class WalletState {}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final List<WalletEntity> wallets;

  WalletLoaded({required this.wallets});

  List<WalletEntity> get activeWallets => wallets.where((w) => !w.isArchived).toList();
  List<WalletEntity> get archivedWallets => wallets.where((w) => w.isArchived).toList();
}

class WalletError extends WalletState {
  final String message;

  WalletError(this.message);
}
