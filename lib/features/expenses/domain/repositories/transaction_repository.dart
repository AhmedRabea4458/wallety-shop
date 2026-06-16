import 'package:smart_expense/features/expenses/domain/entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<void> addTransaction(
    TransactionEntity transaction,
  );

  Future<List<TransactionEntity>> getTransactions();

  Future<void> deleteTransaction(
    int id,
  );

  Future<void> updateTransaction(
    TransactionEntity transaction,
  );
}