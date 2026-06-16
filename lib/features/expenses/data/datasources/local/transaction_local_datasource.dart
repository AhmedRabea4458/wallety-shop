import 'package:smart_expense/features/expenses/data/models/transaction_model.dart';

abstract class TransactionLocalDataSource {
  Future<void> addTransaction(TransactionModel model);

  Future<List<TransactionModel>> getTransactions();

  Future<void> deleteTransaction(int id);

  Future<void> updateTransaction(TransactionModel model);
}
