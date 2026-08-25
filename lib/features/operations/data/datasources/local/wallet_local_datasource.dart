import 'package:smart_expense/features/operations/data/models/wallet_model.dart';

abstract class WalletLocalDataSource {
  Future<List<WalletModel>> getWallets();
  Future<WalletModel?> getWalletById(int id);
  Future<void> insertWallet(WalletModel model);
  Future<void> updateWallet(WalletModel model);
  Future<void> updateWalletBalance(int id, double newBalance);
  Future<void> deleteWallet(int id);
  Future<void> archiveWallet(int id);
  Future<void> unarchiveWallet(int id);
  Future<bool> walletHasOperations(int walletId);
}
