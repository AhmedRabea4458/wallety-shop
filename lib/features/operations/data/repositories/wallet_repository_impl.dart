import 'package:smart_expense/features/operations/data/datasources/local/wallet_local_datasource.dart';
import 'package:smart_expense/features/operations/data/models/wallet_model.dart';
import 'package:smart_expense/features/operations/domain/entities/wallet_entity.dart';
import 'package:smart_expense/features/operations/domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletLocalDataSource localDataSource;

  WalletRepositoryImpl(this.localDataSource);

  @override
  Future<List<WalletEntity>> getWallets() {
    return localDataSource.getWallets().then(
      (data) => data.map((model) => model.toEntity()).toList(),
    );
  }

  @override
  Future<WalletEntity?> getWalletById(int id) {
    return localDataSource.getWalletById(id).then(
      (model) => model?.toEntity(),
    );
  }

  @override
  Future<void> addWallet(WalletEntity wallet) {
    final model = WalletModel.fromEntity(wallet);
    return localDataSource.insertWallet(model);
  }

  @override
  Future<void> updateWallet(WalletEntity wallet) {
    final model = WalletModel.fromEntity(wallet);
    return localDataSource.updateWallet(model);
  }

  @override
  Future<void> updateWalletBalance(int id, double newBalance) {
    return localDataSource.updateWalletBalance(id, newBalance);
  }

  @override
  Future<void> deleteWallet(int id) {
    return localDataSource.deleteWallet(id);
  }

  @override
  Future<bool> walletHasOperations(int walletId) {
    return localDataSource.walletHasOperations(walletId);
  }
}
