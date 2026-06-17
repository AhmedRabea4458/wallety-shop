import 'package:smart_expense/features/operations/domain/entities/wallet_adjustment_entity.dart';

abstract class WalletAdjustmentRepository {
  Future<List<WalletAdjustmentEntity>> getAllAdjustments();
  Future<List<WalletAdjustmentEntity>> getWalletAdjustments(int walletId);
  Future<void> addWalletAdjustment(WalletAdjustmentEntity adjustment);
}
