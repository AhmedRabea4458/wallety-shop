import 'package:smart_expense/features/operations/domain/entities/wallet_entity.dart';

abstract class WalletRepository {
  Future<List<WalletEntity>> getWallets();
  Future<WalletEntity?> getWalletById(int id);
  Future<void> addWallet(WalletEntity wallet);
  Future<void> updateWallet(WalletEntity wallet);
  Future<void> updateWalletBalance(int id, double newBalance);
  Future<void> deleteWallet(int id);
  Future<bool> walletHasOperations(int walletId);
}
