import 'package:smart_expense/features/expenses/domain/entities/transaction_entity.dart';

abstract class TransactionState {}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<TransactionEntity> allTransactions;
  final List<TransactionEntity> visibleTransactions;
  final String searchQuery;
  final TransactionCategory? selectedCategory;

  TransactionLoaded({
    required this.allTransactions,
    required this.visibleTransactions,
    this.searchQuery = '',
    this.selectedCategory,
  });
}

class TransactionError extends TransactionState {
  final String message;

  TransactionError(this.message);
}