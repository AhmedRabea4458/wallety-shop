import 'package:drift/drift.dart';
import 'package:smart_expense/core/database/app_database.dart';
import 'package:smart_expense/features/operations/data/datasources/local/wallet_adjustment_local_datasource.dart';
import 'package:smart_expense/features/operations/data/models/wallet_adjustment_model.dart';

class WalletAdjustmentLocalDataSourceImpl implements WalletAdjustmentLocalDataSource {
  final AppDatabase database;

  WalletAdjustmentLocalDataSourceImpl(this.database);

  @override
  Future<List<WalletAdjustmentModel>> getAllAdjustments() async {
    final data = await database.select(database.walletAdjustmentsTable).get();
    return data.map((e) => WalletAdjustmentModel.fromDrift(e)).toList();
  }

  @override
  Future<List<WalletAdjustmentModel>> getWalletAdjustments(int walletId) async {
    final data = await database.getWalletAdjustments(walletId);
    return data.map((e) => WalletAdjustmentModel.fromDrift(e)).toList();
  }

  @override
  Future<void> insertWalletAdjustment(WalletAdjustmentModel model) async {
    await database.insertWalletAdjustment(
      WalletAdjustmentsTableCompanion(
        walletId: Value(model.walletId),
        periodType: Value(model.periodType),
        amount: Value(model.amount),
        reason: Value(model.reason),
        createdAt: Value(model.createdAt),
      ),
    );
  }
}
