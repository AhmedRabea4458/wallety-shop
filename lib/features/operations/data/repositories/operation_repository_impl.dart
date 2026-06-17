import 'package:smart_expense/features/operations/data/datasources/local/operation_local_datasource.dart';
import 'package:smart_expense/features/operations/data/models/operation_model.dart';
import 'package:smart_expense/features/operations/domain/entities/operation_entity.dart';
import 'package:smart_expense/features/operations/domain/repositories/operation_repository.dart';

class OperationRepositoryImpl implements OperationRepository {
  final OperationLocalDataSource localDataSource;

  OperationRepositoryImpl(this.localDataSource);

  @override
  Future<List<OperationEntity>> getOperations() {
    return localDataSource.getOperations().then(
      (data) => data.map((model) => model.toEntity()).toList(),
    );
  }

  @override
  Future<List<OperationEntity>> getWalletOperations(int walletId) {
    return localDataSource.getWalletOperations(walletId).then(
      (data) => data.map((model) => model.toEntity()).toList(),
    );
  }

  @override
  Future<void> addOperation(OperationEntity operation) {
    final model = OperationModel.fromEntity(operation);
    return localDataSource.insertOperation(model);
  }

  @override
  Future<void> updateOperation(OperationEntity operation) {
    final model = OperationModel.fromEntity(operation);
    return localDataSource.updateOperation(model);
  }

  @override
  Future<void> deleteOperation(int id) {
    return localDataSource.deleteOperation(id);
  }
}
