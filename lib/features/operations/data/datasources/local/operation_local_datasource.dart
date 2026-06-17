import 'package:smart_expense/features/operations/data/models/operation_model.dart';

abstract class OperationLocalDataSource {
  Future<List<OperationModel>> getOperations();
  Future<List<OperationModel>> getWalletOperations(int walletId);
  Future<void> insertOperation(OperationModel model);
  Future<void> updateOperation(OperationModel model);
  Future<void> deleteOperation(int id);
}
