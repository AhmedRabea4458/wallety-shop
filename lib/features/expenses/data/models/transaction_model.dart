import 'package:smart_expense/core/database/app_database.dart';
import 'package:smart_expense/features/expenses/domain/entities/transaction_entity.dart';

class TransactionModel  {
  final int id;
  final String note;
  final TransactionType type;
  final double amount;
  final DateTime date;
  final TransactionCategory category;

  TransactionModel({
    required this.id,
    required this.note,
    required this.type,
    required this.amount,
    required this.date,
    required this.category,
   
  });
  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      note: note,
      type: type,
      amount: amount,
      date: date,
      category: category,
    );
  }
  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      note: entity.note,
      type: entity.type,
      amount: entity.amount,
      date: entity.date,
      category: entity.category,
    );
  }

  factory TransactionModel.fromDrift(TransactionsTableData data) {
    return TransactionModel(
      id: data.id,
      note: data.note,
      type: _typeFromString(data.type),
      amount: data.amount,
      date: data.date,
      category: _categoryFromString(data.category),
    );
  }

  static TransactionCategory _categoryFromString(String value) {
    switch (value) {
      case 'طعام':
      case 'food':
        return TransactionCategory.food;
      case 'مواصلات':
      case 'transport':
        return TransactionCategory.transport;
      case 'فواتير':
      case 'bills':
        return TransactionCategory.bills;
      case 'ترفيه':
      case 'entertainment':
        return TransactionCategory.entertainment;
      case 'تسوق':
      case 'shopping':
        return TransactionCategory.shopping;
      case 'راتب':
      case 'salary':
        return TransactionCategory.salary;
      case 'أخرى':
      case 'other':
        return TransactionCategory.other;
      default:
        return TransactionCategory.other;
    }
  }

  static TransactionType _typeFromString(String value) {
    switch (value) {
      case 'expense':
      case 'مصروف':
        return TransactionType.expense;
      case 'income':
      case 'دخل':
        return TransactionType.income;
      default:
        return TransactionType.expense;
    }
  }
}