import 'package:smart_expense/features/operations/data/models/wallet_adjustment_model.dart';

abstract class WalletAdjustmentLocalDataSource {
  Future<List<WalletAdjustmentModel>> getAllAdjustments();
  Future<List<WalletAdjustmentModel>> getWalletAdjustments(int walletId);
  Future<void> insertWalletAdjustment(WalletAdjustmentModel model);
}
