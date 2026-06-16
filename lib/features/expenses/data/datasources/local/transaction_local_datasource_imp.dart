import 'package:smart_expense/core/database/app_database.dart';
import 'package:smart_expense/features/expenses/data/datasources/local/transaction_local_datasource.dart';
import 'package:smart_expense/features/expenses/data/models/transaction_model.dart';

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  final AppDatabase database;

  TransactionLocalDataSourceImpl(this.database);

  @override
  Future<void> addTransaction(TransactionModel model) {
    return database.addTransaction(model);
  }

  @override
  Future<List<TransactionModel>> getTransactions() {
    return database.getTransactions().then(
      (data) => data.map((e) => TransactionModel.fromDrift(e)).toList(),
    );
  }

  @override
  Future<void> deleteTransaction(int id) {
    return database.deleteTransaction(id);
  }

  @override
  Future<void> updateTransaction(TransactionModel model) {
    return database.updateTransaction(model);
  }
}
