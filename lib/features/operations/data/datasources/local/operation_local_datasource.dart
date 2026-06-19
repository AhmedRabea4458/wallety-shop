import 'package:smart_expense/features/operations/data/models/operation_model.dart';

abstract class OperationLocalDataSource {
  Future<List<OperationModel>> getOperations();
  Future<List<OperationModel>> getWalletOperations(int walletId);
  Future<int> insertOperation(OperationModel model, {bool isDebt = false});
  Future<void> updateOperation(OperationModel model);
  Future<void> deleteOperation(int id);
}
