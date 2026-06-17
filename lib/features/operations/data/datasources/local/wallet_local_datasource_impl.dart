import 'package:drift/drift.dart';
import 'package:smart_expense/core/database/app_database.dart';
import 'package:smart_expense/features/operations/data/datasources/local/wallet_local_datasource.dart';
import 'package:smart_expense/features/operations/data/models/wallet_model.dart';

class WalletLocalDataSourceImpl implements WalletLocalDataSource {
  final AppDatabase database;

  WalletLocalDataSourceImpl(this.database);

  @override
  Future<List<WalletModel>> getWallets() {
    return database.getWallets().then(
      (data) => data.map((e) => WalletModel.fromDrift(e)).toList(),
    );
  }

  @override
  Future<WalletModel?> getWalletById(int id) {
    return database.getWalletById(id).then(
      (data) => data != null ? WalletModel.fromDrift(data) : null,
    );
  }

  @override
  Future<void> insertWallet(WalletModel model) {
    return database.insertWallet(
      WalletsTableCompanion(
        name: Value(model.name),
        phoneNumber: Value(model.phoneNumber),
        balance: Value(model.balance),
        color: Value(WalletModel.colorToHex(model.color)),
        dailyLimit: Value(model.dailyLimit),
        weeklyLimit: Value(model.weeklyLimit),
        monthlyLimit: Value(model.monthlyLimit),
      ),
    );
  }

  @override
  Future<void> updateWallet(WalletModel model) {
    return database.updateWallet(
      WalletsTableCompanion(
        id: Value(model.id),
        name: Value(model.name),
        phoneNumber: Value(model.phoneNumber),
        balance: Value(model.balance),
        color: Value(WalletModel.colorToHex(model.color)),
        dailyLimit: Value(model.dailyLimit),
        weeklyLimit: Value(model.weeklyLimit),
        monthlyLimit: Value(model.monthlyLimit),
        createdAt: Value(model.createdAt),
      ),
    );
  }

  @override
  Future<void> updateWalletBalance(int id, double newBalance) {
    return database.updateWalletBalance(id, newBalance);
  }

  @override
  Future<void> deleteWallet(int id) {
    return database.deleteWallet(id);
  }

  @override
  Future<bool> walletHasOperations(int walletId) {
    return database.walletHasOperations(walletId);
  }
}
