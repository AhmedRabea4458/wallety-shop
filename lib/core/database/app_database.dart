import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_expense/core/constants/category_colors.dart';
import 'package:smart_expense/features/analytics/domain/entities/category_breakdown.dart';
import 'package:smart_expense/features/analytics/domain/entities/period_spending.dart';
import 'package:smart_expense/features/analytics/domain/entities/summary_result.dart';
import 'package:smart_expense/features/expenses/data/models/transaction_model.dart';

import 'tables/transactions_table.dart';

part 'app_database.g.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File('${dbFolder.path}/smart_expense.db');

    return NativeDatabase(file);
  });
}

@DriftDatabase(
  tables: [
    TransactionsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<List<TransactionsTableData>> getTransactions() {
    return select(transactionsTable).get();
  }

  Future<void> addTransaction(TransactionModel model) async {
    await into(transactionsTable).insert(
      TransactionsTableCompanion.insert(
        note: model.note,
        amount: model.amount,
        date: model.date,
        category: model.category.name,
        type: model.type.name,
      ),
    );
  }

  Future<void> deleteTransaction(int id) async {
    await (delete(transactionsTable)..where((t) => t.id.equals(id))).go();
  }

  Future<void> updateTransaction(TransactionModel model) async {
    await update(transactionsTable).replace(
      TransactionsTableCompanion(
        id: Value(model.id),
        note: Value(model.note),
        amount: Value(model.amount),
        date: Value(model.date),
        category: Value(model.category.name),
        type: Value(model.type.name),
      ),
    );
  }

  Future<void> clearTransactions() async {
    await delete(transactionsTable).go();
  }
  Future<SummaryResult> getSummary({DateTime? startDate, DateTime? endDate}) {
    var query = select(transactionsTable);
    return query.get().then((transactions) {
      final filtered = _filterByDate(transactions, startDate, endDate);
      double totalIncome = 0;
      double totalExpense = 0;

      for (var transaction in filtered) {
        if (transaction.type == 'income') {
          totalIncome += transaction.amount;
        } else if (transaction.type == 'expense') {
          totalExpense += transaction.amount;
        }
      }

      return SummaryResult(
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        balance: totalIncome - totalExpense,
      );
    });
  }

  Future<List<CategoryBreakdown>> getCategoryBreakdown({DateTime? startDate, DateTime? endDate}) {
    var query = select(transactionsTable);
    return query.get().then((transactions) {
      final filtered = _filterByDate(transactions, startDate, endDate);
      final Map<String, double> categoryTotals = {};

      for (var transaction in filtered) {
        if (transaction.type == 'expense') {
          categoryTotals.update(
            transaction.category,
            (value) => value + transaction.amount,
            ifAbsent: () => transaction.amount,
          );
        }
      }

      final totalExpenses = categoryTotals.values.fold(
        0.0,
        (sum, amount) => sum + amount,
      );

      final result = categoryTotals.entries.map((entry) {
        final percentage = totalExpenses > 0
            ? (entry.value / totalExpenses) * 100
            : 0.0;

        return CategoryBreakdown(
          category: entry.key,
          amount: entry.value,
          percentage: percentage,
          color: CategoryColors.getColor(entry.key),
        );
      }).toList();

      result.sort((a, b) => b.amount.compareTo(a.amount));
      return result;
    });
  }

  Future<List<PeriodSpending>> getSpendingTrend({DateTime? startDate, DateTime? endDate}) {
    var query = select(transactionsTable);
    return query.get().then((transactions) {
      final filtered = _filterByDate(transactions, startDate, endDate);
      final Map<String, double> monthlyTotals = {};

      for (var transaction in filtered) {
        if (transaction.type == 'expense') {
          final month = '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}';
          monthlyTotals.update(
            month,
            (value) => value + transaction.amount,
            ifAbsent: () => transaction.amount,
          );
        }
      }

      final result = monthlyTotals.entries.map((entry) {
        return PeriodSpending(
          label: entry.key,
          amount: entry.value,
        );
      }).toList();

      result.sort((a, b) => a.label.compareTo(b.label));
      return result;
    });
  }

  List<TransactionsTableData> _filterByDate(
    List<TransactionsTableData> transactions,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    if (startDate == null && endDate == null) {
      return transactions;
    }
    return transactions.where((t) {
      final date = t.date;
      if (startDate != null && date.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && date.isAfter(endDate)) {
        return false;
      }
      return true;
    }).toList();
  }
}