import 'package:smart_expense/features/operations/domain/entities/operation_entity.dart';

abstract class OperationRepository {
  Future<List<OperationEntity>> getOperations();
  Future<List<OperationEntity>> getWalletOperations(int walletId);
  Future<int> addOperation(OperationEntity operation, {bool isDebt = false});
  Future<void> updateOperation(OperationEntity operation);
  Future<void> deleteOperation(int id);
}
