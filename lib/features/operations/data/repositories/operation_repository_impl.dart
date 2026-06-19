import 'package:smart_expense/core/errors/exceptions.dart';
import 'package:smart_expense/features/operations/data/datasources/local/debt_local_datasource.dart';
import 'package:smart_expense/features/operations/data/datasources/local/operation_local_datasource.dart';
import 'package:smart_expense/features/operations/data/models/operation_model.dart';
import 'package:smart_expense/features/operations/domain/entities/operation_entity.dart';
import 'package:smart_expense/features/operations/domain/repositories/operation_repository.dart';

class OperationRepositoryImpl implements OperationRepository {
  final OperationLocalDataSource localDataSource;
  final DebtLocalDataSource debtDataSource;

  OperationRepositoryImpl(this.localDataSource, {required this.debtDataSource});

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
  Future<int> addOperation(OperationEntity operation, {bool isDebt = false}) {
    final model = OperationModel.fromEntity(operation);
    return localDataSource.insertOperation(model, isDebt: isDebt);
  }

  @override
  Future<void> updateOperation(OperationEntity operation) async {
    if (operation.id != 0) {
      final hasDebt = await debtDataSource.getDebtByOperationId(operation.id);
      if (hasDebt != null) {
        throw OperationLinkedToDebtException(operation.id);
      }
    }
    final model = OperationModel.fromEntity(operation);
    return localDataSource.updateOperation(model);
  }

  @override
  Future<void> deleteOperation(int id) async {
    final hasDebt = await debtDataSource.getDebtByOperationId(id);
    if (hasDebt != null) {
      throw OperationLinkedToDebtException(id);
    }
    return localDataSource.deleteOperation(id);
  }
}
