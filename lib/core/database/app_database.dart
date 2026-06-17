import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui';

import 'package:smart_expense/features/analytics/domain/entities/category_breakdown.dart';
import 'package:smart_expense/features/analytics/domain/entities/period_spending.dart';
import 'package:smart_expense/features/analytics/domain/entities/summary_result.dart';
import 'package:smart_expense/core/errors/exceptions.dart';

import 'tables/cash_drawer_table.dart';
import 'tables/operations_table.dart';
import 'tables/transactions_table.dart';
import 'tables/wallet_adjustments_table.dart';
import 'tables/wallets_table.dart';

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
    WalletsTable,
    OperationsTable,
    CashDrawerTable,
    WalletAdjustmentsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from == 1) {
            await m.deleteTable('transactions_table');
            await m.createAll();
          } else if (from == 2) {
            await m.addColumn(walletsTable, walletsTable.phoneNumber);
          }
          if (from <= 3) {
            await m.createTable(cashDrawerTable);
            await into(cashDrawerTable).insert(
              CashDrawerTableCompanion(id: const Value(1), balance: const Value(0.0)),
            );
          }
          if (from <= 4) {
            await m.addColumn(cashDrawerTable, cashDrawerTable.initialBalance);
          }
          if (from <= 5) {
            await m.addColumn(walletsTable, walletsTable.dailyLimit);
            await m.addColumn(walletsTable, walletsTable.weeklyLimit);
            await m.addColumn(walletsTable, walletsTable.monthlyLimit);
          }
          if (from <= 6) {
            await m.addColumn(operationsTable, operationsTable.providerType);
          }
          if (from <= 7) {
            await m.addColumn(walletsTable, walletsTable.color);
            await m.createTable(walletAdjustmentsTable);
          }
          if (from <= 8) {
            await m.addColumn(operationsTable, operationsTable.networkFee);
          }
        },
      );

  // ── Legacy Transaction Methods (keep for backward compatibility) ──
  Future<List<TransactionsTableData>> getTransactions() {
    return select(transactionsTable).get();
  }

  Future<void> deleteTransaction(int id) async {
    await (delete(transactionsTable)..where((t) => t.id.equals(id))).go();
  }

  Future<void> clearTransactions() async {
    await delete(transactionsTable).go();
  }

  // ── Analytics Methods (keep for backward compatibility) ──
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
          color: const Color(0xFF9E9E9E),
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

  // ── Cash Drawer Methods ──
  Future<CashDrawerTableData?> getCashDrawer() {
    return (select(cashDrawerTable)..where((c) => c.id.equals(1))).getSingleOrNull();
  }

  Future<void> updateCashDrawerInitialBalance(double newInitialBalance) async {
    final cashDrawer = await (select(cashDrawerTable)..where((c) => c.id.equals(1))).getSingle();
    final delta = newInitialBalance - cashDrawer.initialBalance;
    final newBalance = cashDrawer.balance + delta;
    await (update(cashDrawerTable)..where((c) => c.id.equals(1))).write(
      CashDrawerTableCompanion(
        initialBalance: Value(newInitialBalance),
        balance: Value(newBalance),
      ),
    );
  }

  // ── Wallet Adjustment Methods ──
  Future<List<WalletAdjustmentsTableData>> getWalletAdjustments(int walletId) {
    return (select(walletAdjustmentsTable)..where((a) => a.walletId.equals(walletId))).get();
  }

  Future<void> insertWalletAdjustment(WalletAdjustmentsTableCompanion adjustment) async {
    await into(walletAdjustmentsTable).insert(adjustment);
  }

  // ── Wallet Methods ──
  Future<List<WalletsTableData>> getWallets() => select(walletsTable).get();

  Future<WalletsTableData?> getWalletById(int id) {
    return (select(walletsTable)..where((w) => w.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertWallet(WalletsTableCompanion wallet) async {
    await into(walletsTable).insert(wallet);
  }

  Future<void> updateWallet(WalletsTableCompanion wallet) async {
    await update(walletsTable).replace(wallet);
  }

  Future<void> updateWalletBalance(int id, double newBalance) async {
    await (update(walletsTable)..where((w) => w.id.equals(id)))
        .write(WalletsTableCompanion(balance: Value(newBalance)));
  }

  Future<void> deleteWallet(int id) async {
    await (delete(walletsTable)..where((w) => w.id.equals(id))).go();
  }

  Future<bool> walletHasOperations(int walletId) async {
    final count = await (select(operationsTable)..where((o) => o.walletId.equals(walletId))).get();
    return count.isNotEmpty;
  }

  // ── Operation Read Methods ──
  Future<List<OperationsTableData>> getOperations() => select(operationsTable).get();

  Future<OperationsTableData?> getOperationById(int id) {
    return (select(operationsTable)..where((o) => o.id.equals(id))).getSingleOrNull();
  }

  Future<List<OperationsTableData>> getWalletOperations(int walletId) {
    return (select(operationsTable)..where((o) => o.walletId.equals(walletId))).get();
  }

  // ── Atomic Operation Methods (with Balance Update) ──

  Future<void> addOperationWithBalanceUpdate(OperationsTableCompanion operation) {
    return transaction(() async {
      final walletId = operation.walletId.value;
      final providerType = operation.providerType.value;
      final type = operation.operationType.value;
      final amount = operation.amount.value;
      final commission = operation.commission.value;
      final networkFee = operation.networkFee.value;

      // Vodafone Cash affects wallet balance; InstaPay does not
      if (providerType == 'vodafoneCash') {
        final wallet = await (select(walletsTable)..where((w) => w.id.equals(walletId))).getSingle();
        double newBalance = wallet.balance;
        if (type == 'deposit') {
          newBalance -= amount + networkFee;
          if (newBalance < 0) {
            throw InsufficientBalanceException();
          }
        } else if (type == 'withdrawal') {
          newBalance += amount;
        }
        await (update(walletsTable)..where((w) => w.id.equals(walletId)))
            .write(WalletsTableCompanion(balance: Value(newBalance)));
      }

      await into(operationsTable).insert(operation);

      // Update cash drawer
      final cashDrawer = await (select(cashDrawerTable)..where((c) => c.id.equals(1))).getSingle();
      double cashBalance = cashDrawer.balance;
      if (providerType == 'vodafoneCash') {
        if (type == 'deposit') {
          cashBalance += amount + commission;
        } else if (type == 'withdrawal') {
          cashBalance -= amount - commission;
          if (cashBalance < 0) {
            throw InsufficientCashDrawerBalanceException();
          }
        }
      } else if (providerType == 'instaPay') {
        cashBalance += commission;
      }
      await (update(cashDrawerTable)..where((c) => c.id.equals(1)))
          .write(CashDrawerTableCompanion(balance: Value(cashBalance)));
    });
  }

  Future<void> updateOperationWithBalanceUpdate(OperationsTableCompanion operation) {
    return transaction(() async {
      final operationId = operation.id.value;
      final oldOp = await (select(operationsTable)..where((o) => o.id.equals(operationId))).getSingle();
      final oldWalletId = oldOp.walletId;
      final newWalletId = operation.walletId.value;
      final oldProvider = oldOp.providerType;
      final newProvider = operation.providerType.value;
      final newCommission = operation.commission.value;
      final newNetworkFee = operation.networkFee.value;
      final newType = operation.operationType.value;
      final newAmount = operation.amount.value;

      // Reverse old wallet effect (Vodafone Cash only)
      if (oldProvider == 'vodafoneCash') {
        final oldWallet = await (select(walletsTable)..where((w) => w.id.equals(oldWalletId))).getSingle();
        double oldBalance = oldWallet.balance;
        if (oldOp.operationType == 'deposit') {
          oldBalance += oldOp.amount + oldOp.networkFee;
        } else if (oldOp.operationType == 'withdrawal') {
          oldBalance -= oldOp.amount;
        }
        await (update(walletsTable)..where((w) => w.id.equals(oldWalletId)))
            .write(WalletsTableCompanion(balance: Value(oldBalance)));
      }

      // Apply new wallet effect (Vodafone Cash only)
      if (newProvider == 'vodafoneCash') {
        final newWallet = await (select(walletsTable)..where((w) => w.id.equals(newWalletId))).getSingle();
        double newBalance = newWallet.balance;
        if (newType == 'deposit') {
          newBalance -= newAmount + newNetworkFee;
          if (newBalance < 0) {
            throw InsufficientBalanceException();
          }
        } else if (newType == 'withdrawal') {
          newBalance += newAmount;
        }
        await (update(walletsTable)..where((w) => w.id.equals(newWalletId)))
            .write(WalletsTableCompanion(balance: Value(newBalance)));
      }

      await update(operationsTable).replace(operation);

      // Update cash drawer: reverse old, apply new
      final cashDrawer = await (select(cashDrawerTable)..where((c) => c.id.equals(1))).getSingle();
      double cashBalance = cashDrawer.balance;

      // Reverse old cash drawer effect
      if (oldProvider == 'vodafoneCash') {
        if (oldOp.operationType == 'deposit') {
          cashBalance -= oldOp.amount + oldOp.commission;
          if (cashBalance < 0) {
            throw InsufficientCashDrawerBalanceException();
          }
        } else if (oldOp.operationType == 'withdrawal') {
          cashBalance += oldOp.amount - oldOp.commission;
        }
      } else if (oldProvider == 'instaPay') {
        cashBalance -= oldOp.commission;
        if (cashBalance < 0) {
          throw InsufficientCashDrawerBalanceException();
        }
      }

      // Apply new cash drawer effect
      if (newProvider == 'vodafoneCash') {
        if (newType == 'deposit') {
          cashBalance += newAmount + newCommission;
        } else if (newType == 'withdrawal') {
          cashBalance -= newAmount - newCommission;
          if (cashBalance < 0) {
            throw InsufficientCashDrawerBalanceException();
          }
        }
      } else if (newProvider == 'instaPay') {
        cashBalance += newCommission;
      }

      await (update(cashDrawerTable)..where((c) => c.id.equals(1)))
          .write(CashDrawerTableCompanion(balance: Value(cashBalance)));
    });
  }

  Future<void> deleteOperationWithBalanceUpdate(int id) {
    return transaction(() async {
      final operation = await (select(operationsTable)..where((o) => o.id.equals(id))).getSingle();
      final walletId = operation.walletId;
      final providerType = operation.providerType;

      // Reverse wallet effect (Vodafone Cash only)
      if (providerType == 'vodafoneCash') {
        final wallet = await (select(walletsTable)..where((w) => w.id.equals(walletId))).getSingle();
        double balance = wallet.balance;
        if (operation.operationType == 'deposit') {
          balance += operation.amount + operation.networkFee;
        } else if (operation.operationType == 'withdrawal') {
          balance -= operation.amount;
          if (balance < 0) {
            throw InsufficientBalanceException();
          }
        }
        await (update(walletsTable)..where((w) => w.id.equals(walletId)))
            .write(WalletsTableCompanion(balance: Value(balance)));
      }

      await (delete(operationsTable)..where((o) => o.id.equals(id))).go();

      // Reverse cash drawer effect
      final cashDrawer = await (select(cashDrawerTable)..where((c) => c.id.equals(1))).getSingle();
      double cashBalance = cashDrawer.balance;
      if (providerType == 'vodafoneCash') {
        if (operation.operationType == 'deposit') {
          cashBalance -= operation.amount + operation.commission;
          if (cashBalance < 0) {
            throw InsufficientCashDrawerBalanceException();
          }
        } else if (operation.operationType == 'withdrawal') {
          cashBalance += operation.amount - operation.commission;
        }
      } else if (providerType == 'instaPay') {
        cashBalance -= operation.commission;
        if (cashBalance < 0) {
          throw InsufficientCashDrawerBalanceException();
        }
      }
      await (update(cashDrawerTable)..where((c) => c.id.equals(1)))
          .write(CashDrawerTableCompanion(balance: Value(cashBalance)));
    });
  }
}
