import 'package:smart_expense/features/operations/data/datasources/local/wallet_adjustment_local_datasource.dart';
import 'package:smart_expense/features/operations/data/models/wallet_adjustment_model.dart';
import 'package:smart_expense/features/operations/domain/entities/wallet_adjustment_entity.dart';
import 'package:smart_expense/features/operations/domain/repositories/wallet_adjustment_repository.dart';

class WalletAdjustmentRepositoryImpl implements WalletAdjustmentRepository {
  final WalletAdjustmentLocalDataSource localDataSource;

  WalletAdjustmentRepositoryImpl(this.localDataSource);

  @override
  Future<List<WalletAdjustmentEntity>> getAllAdjustments() async {
    final data = await localDataSource.getAllAdjustments();
    return data.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<WalletAdjustmentEntity>> getWalletAdjustments(int walletId) async {
    final data = await localDataSource.getWalletAdjustments(walletId);
    return data.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> addWalletAdjustment(WalletAdjustmentEntity adjustment) async {
    final model = WalletAdjustmentModel.fromEntity(adjustment);
    await localDataSource.insertWalletAdjustment(model);
  }
}
