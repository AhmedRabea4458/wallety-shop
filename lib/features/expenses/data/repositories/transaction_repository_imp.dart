import 'package:smart_expense/features/expenses/data/datasources/local/transaction_local_datasource.dart';
import 'package:smart_expense/features/expenses/data/models/transaction_model.dart';
import 'package:smart_expense/features/expenses/domain/entities/transaction_entity.dart';
import 'package:smart_expense/features/expenses/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource localDataSource;

  TransactionRepositoryImpl(this.localDataSource);

  @override
  Future<void> addTransaction(TransactionEntity transaction) {
    final model = TransactionModel.fromEntity(transaction);
    return localDataSource.addTransaction(model);
  }

  @override
  Future<List<TransactionEntity>> getTransactions() {
    return localDataSource.getTransactions().then(
      (data) => data.map((model) => model.toEntity()).toList(),
    );
  }

  @override
  Future<void> deleteTransaction(int id) {
    return localDataSource.deleteTransaction(id);
  }

  @override
  Future<void> updateTransaction(TransactionEntity transaction) {
    final model = TransactionModel.fromEntity(transaction);
    return localDataSource.updateTransaction(model);
  }
}
