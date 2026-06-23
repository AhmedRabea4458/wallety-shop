import 'package:drift/drift.dart';
import 'package:smart_expense/core/database/app_database.dart';
import 'package:smart_expense/features/operations/data/datasources/local/operation_local_datasource.dart';
import 'package:smart_expense/features/operations/data/models/operation_model.dart';

class OperationLocalDataSourceImpl implements OperationLocalDataSource {
  final AppDatabase database;

  OperationLocalDataSourceImpl(this.database);

  @override
  Future<List<OperationModel>> getOperations() {
    return database.getOperations().then(
      (data) => data.map((e) => OperationModel.fromDrift(e)).toList(),
    );
  }

  @override
  Future<List<OperationModel>> getWalletOperations(int walletId) {
    return database.getWalletOperations(walletId).then(
      (data) => data.map((e) => OperationModel.fromDrift(e)).toList(),
    );
  }

  @override
  Future<int> insertOperation(OperationModel model,{bool isDebt=false}) {
    return database.addOperationWithBalanceUpdate(
      OperationsTableCompanion(
        walletId: Value(model.walletId),
        shiftId: Value(model.shiftId),
        operationType: Value(model.operationType.name),
        providerType: Value(model.providerType.name),
        amount: Value(model.amount),
        commission: Value(model.commission),
        networkFee: Value(model.networkFee),
        phoneNumber: Value(model.phoneNumber),
        notes: Value(model.notes),
        isDebt: Value(isDebt),
        instaPayAccountId: Value(model.instaPayAccountId),
        createdAt: Value(model.createdAt),
      ),
    );
  }

  @override
  Future<void> updateOperation(OperationModel model) {
    return database.updateOperationWithBalanceUpdate(
      OperationsTableCompanion(
        id: Value(model.id),
        walletId: Value(model.walletId),
        shiftId: Value(model.shiftId),
        operationType: Value(model.operationType.name),
        providerType: Value(model.providerType.name),
        amount: Value(model.amount),
        commission: Value(model.commission),
        networkFee: Value(model.networkFee),
        phoneNumber: Value(model.phoneNumber),
        notes: Value(model.notes),
        instaPayAccountId: Value(model.instaPayAccountId),
        createdAt: Value(model.createdAt),
      ),
    );
  }

  @override
  Future<void> deleteOperation(int id) {
    return database.deleteOperationWithBalanceUpdate(id);
  }
}
