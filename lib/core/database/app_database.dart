import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_expense/core/database/tables/debtors_table.dart';
import 'package:smart_expense/core/database/tables/debts_table.dart';
import 'package:smart_expense/core/database/tables/instapay_accounts_table.dart';
import 'package:smart_expense/core/database/tables/debt_payments_table.dart';
import 'dart:ui';

import 'package:smart_expense/features/analytics/domain/entities/category_breakdown.dart';
import 'package:smart_expense/features/analytics/domain/entities/period_spending.dart';
import 'package:smart_expense/features/analytics/domain/entities/summary_result.dart';
import 'package:smart_expense/core/errors/exceptions.dart';

import 'tables/cash_drawer_table.dart';
import 'tables/operations_table.dart';
import 'tables/shifts_table.dart';
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
    ShiftsTable,
    DebtorsTable,
    DebtsTable,
    InstaPayAccountsTable,
    DebtPaymentsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 21;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await into(cashDrawerTable).insert(
            CashDrawerTableCompanion(id: const Value(1), balance: const Value(0.0)),
          );
          await _createSingleActiveShiftTrigger();
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
          if (from <= 9) {
            await m.createTable(shiftsTable);
            await m.addColumn(operationsTable, operationsTable.shiftId);
          }
          if (from <= 10) {
            await _repairDuplicateActiveShifts();
            await _createSingleActiveShiftTrigger();
          }
          if (from <= 11) {
            await m.createTable(debtorsTable);
            await m.createTable(debtsTable);
          }
          if (from <= 13) {
            try {
              await m.addColumn(operationsTable, operationsTable.isDebt);
            } catch (_) {
              // Column may already exist on some installs; safe to ignore.
            }
          }
          if (from <= 15) {
            await _recreateDebtsTableIfOperationIdNotNullable();
          }
          if (from <= 16) {
            await m.createTable(instaPayAccountsTable);
            try {
              await m.addColumn(operationsTable, operationsTable.instaPayAccountId);
            } catch (_) {
              // Column may already exist.
            }
          }
          if (from <= 17) {
            await m.addColumn(debtsTable, debtsTable.isCashLoan);
          }
          if (from <= 18) {
            await m.addColumn(debtsTable, debtsTable.debtType);
          }
          if (from <= 19) {
            await m.createTable(debtPaymentsTable);
          }
          if (from <= 20) {
            await m.addColumn(debtsTable, debtsTable.notes);
          }
        },
      );

  Future<void> _recreateDebtsTableIfOperationIdNotNullable() async {
    final columns = await customSelect(
      "PRAGMA table_info(${debtsTable.actualTableName})",
    ).get();
    QueryRow? operationIdInfo;
    for (final row in columns) {
      if (row.read<String>('name') == 'operation_id') {
        operationIdInfo = row;
        break;
      }
    }
    if (operationIdInfo == null) return;
    final isNotNull = operationIdInfo.read<int>('notnull') == 1;
    if (!isNotNull) return;

    await customStatement('''
      CREATE TABLE debts_table_new (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        debtor_id INTEGER NOT NULL REFERENCES debtors_table (id),
        operation_id INTEGER REFERENCES operations_table (id),
        operation_type TEXT NOT NULL DEFAULT 'deposit',
        provider_type TEXT,
        amount REAL NOT NULL,
        is_paid INTEGER NOT NULL DEFAULT 0 CHECK (is_paid IN (0, 1)),
        paid_at INTEGER,
        created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000)
      )
    ''');
    await customStatement('''
      INSERT INTO debts_table_new (
        id, debtor_id, operation_id, operation_type, provider_type, amount, is_paid, paid_at, created_at
      )
      SELECT
        id, debtor_id, operation_id, operation_type, provider_type, amount, is_paid, paid_at, created_at
      FROM debts_table
    ''');
    await customStatement('DROP TABLE debts_table');
    await customStatement('ALTER TABLE debts_table_new RENAME TO debts_table');
  }

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

  Future<void> updateCashDrawerBalance(double newBalance) async {
    await (update(cashDrawerTable)..where((c) => c.id.equals(1))).write(
      CashDrawerTableCompanion(
        balance: Value(newBalance),
        updatedAt: Value(DateTime.now()),
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

  Future<List<OperationsTableData>> getOperationsByShiftId(int shiftId) {
    return (select(operationsTable)..where((o) => o.shiftId.equals(shiftId))).get();
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

  Future<int> addOperationWithBalanceUpdate(OperationsTableCompanion operation) {
    return transaction(() async {
      final walletId = operation.walletId.value;
      final providerType = operation.providerType.value;
      final type = operation.operationType.value;
      final amount = operation.amount.value;
      final commission = operation.commission.value;
      final networkFee = operation.networkFee.value;
      final isDebt = operation.isDebt.value;

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

      final operationId = await into(operationsTable).insert(operation);

      // Update cash drawer
      final cashDrawer = await (select(cashDrawerTable)..where((c) => c.id.equals(1))).getSingle();
      double cashBalance = cashDrawer.balance;
      if (providerType == 'vodafoneCash') {
        if (type == 'deposit') {
       if (!isDebt) {
  cashBalance += amount + commission;
}
        } else if (type == 'withdrawal') {
          cashBalance -= amount - commission;
          if (cashBalance < 0) {
            throw InsufficientCashDrawerBalanceException();
          }
        }
      } else if (providerType == 'instaPay') {
        if (type == 'deposit') {
          cashBalance += commission;
        } else if (type == 'withdrawal') {
          cashBalance -= amount - commission;
          if (cashBalance < 0) {
            throw InsufficientCashDrawerBalanceException();
          }
        }
      }
      await (update(cashDrawerTable)..where((c) => c.id.equals(1)))
          .write(CashDrawerTableCompanion(balance: Value(cashBalance)));
      return operationId;
    });
  }

  Future<int> addPartialWithdrawalWithPayable({
    required OperationsTableCompanion operation,
    required String customerName,
    String? customerPhone,
  }) {
    return transaction(() async {
      final walletId = operation.walletId.value;
      final providerType = operation.providerType.value;
      final type = operation.operationType.value;
      final amount = operation.amount.value;
      final commission = operation.commission.value;

      if (type != 'withdrawal') {
        throw Exception('addPartialWithdrawalWithPayable can only be used for withdrawal operations');
      }

      // 1. Vodafone Cash affects wallet balance by full requested withdrawal amount
      if (providerType == 'vodafoneCash') {
        final wallet = await (select(walletsTable)..where((w) => w.id.equals(walletId))).getSingle();
        await (update(walletsTable)..where((w) => w.id.equals(walletId)))
            .write(WalletsTableCompanion(balance: Value(wallet.balance + amount)));
      }

      // 2. Insert withdrawal operation with full requested amount
      final operationId = await into(operationsTable).insert(operation);

      // 3. Calculate cash drawer deduction and payable remainder
      final cashDrawer = await (select(cashDrawerTable)..where((c) => c.id.equals(1))).getSingle();
      final availableCash = cashDrawer.balance;

      // Net cash required from drawer to complete full withdrawal
      final requiredCashFromDrawer = amount - commission;
      final actualCashPaidFromDrawer = availableCash; // Drain available cash completely
      final remainderPayable = requiredCashFromDrawer - actualCashPaidFromDrawer;

      // Cash drawer balance goes to zero (or 0 if negative check)
      final newCashBalance = 0.0;
      await (update(cashDrawerTable)..where((c) => c.id.equals(1)))
          .write(CashDrawerTableCompanion(balance: Value(newCashBalance)));

      // 4. Find or create debtor
      DebtorsTableData debtor;
      DebtorsTableData? existing;
      if (customerPhone != null && customerPhone.trim().isNotEmpty) {
        existing = await getDebtorByPhone(customerPhone.trim());
      }
      existing ??= await getDebtorByName(customerName.trim());

      if (existing != null) {
        debtor = existing;
      } else {
        final debtorId = await into(debtorsTable).insert(
          DebtorsTableCompanion(
            name: Value(customerName.trim()),
            phone: Value((customerPhone != null && customerPhone.trim().isNotEmpty) ? customerPhone.trim() : null),
          ),
        );
        debtor = (await (select(debtorsTable)..where((d) => d.id.equals(debtorId))).getSingle());
      }

      // 5. Create linked payable for the remaining deficit
      await into(debtsTable).insert(
        DebtsTableCompanion(
          debtorId: Value(debtor.id),
          operationId: Value(operationId),
          operationType: const Value('withdrawal'),
          providerType: Value(providerType),
          amount: Value(remainderPayable),
          isPaid: const Value(false),
          isCashLoan: const Value(false),
          debtType: const Value('payable'),
          notes: Value('مستحق متبقي من سحب بقيمة ${amount.toStringAsFixed(0)} ج.م'),
          createdAt: Value(DateTime.now()),
        ),
      );

      return operationId;
    });
  }

  Future<int> addFullWithdrawalPayable({
    required OperationsTableCompanion operation,
    required String customerName,
    String? customerPhone,
  }) {
    return transaction(() async {
      final walletId = operation.walletId.value;
      final providerType = operation.providerType.value;
      final type = operation.operationType.value;
      final amount = operation.amount.value;

      if (type != 'withdrawal') {
        throw Exception('addFullWithdrawalPayable can only be used for withdrawal operations');
      }

      // 1. Vodafone Cash affects wallet balance by full requested withdrawal amount
      if (providerType == 'vodafoneCash') {
        final wallet = await (select(walletsTable)..where((w) => w.id.equals(walletId))).getSingle();
        await (update(walletsTable)..where((w) => w.id.equals(walletId)))
            .write(WalletsTableCompanion(balance: Value(wallet.balance + amount)));
      }

      // 2. Insert withdrawal operation
      final operationId = await into(operationsTable).insert(operation);

      // 3. Do NOT modify cash drawer (cash is retained, not paid out)

      // 4. Find or create debtor
      DebtorsTableData debtor;
      DebtorsTableData? existing;
      if (customerPhone != null && customerPhone.trim().isNotEmpty) {
        existing = await getDebtorByPhone(customerPhone.trim());
      }
      existing ??= await getDebtorByName(customerName.trim());

      if (existing != null) {
        debtor = existing;
      } else {
        final debtorId = await into(debtorsTable).insert(
          DebtorsTableCompanion(
            name: Value(customerName.trim()),
            phone: Value((customerPhone != null && customerPhone.trim().isNotEmpty) ? customerPhone.trim() : null),
          ),
        );
        debtor = (await (select(debtorsTable)..where((d) => d.id.equals(debtorId))).getSingle());
      }

      // 5. Create linked payable for full withdrawal amount
      await into(debtsTable).insert(
        DebtsTableCompanion(
          debtorId: Value(debtor.id),
          operationId: Value(operationId),
          operationType: const Value('withdrawal'),
          providerType: Value(providerType),
          amount: Value(amount),
          isPaid: const Value(false),
          isCashLoan: const Value(false),
          debtType: const Value('payable'),
          notes: Value('مستحق كامل من سحب مؤجل بتاريخ ${DateTime.now().toString().split(' ')[0]}'),
          createdAt: Value(DateTime.now()),
        ),
      );

      return operationId;
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
        if (oldOp.operationType == 'deposit') {
          cashBalance -= oldOp.commission;
          if (cashBalance < 0) {
            throw InsufficientCashDrawerBalanceException();
          }
        } else if (oldOp.operationType == 'withdrawal') {
          cashBalance += oldOp.amount - oldOp.commission;
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
        if (newType == 'deposit') {
          cashBalance += newCommission;
        } else if (newType == 'withdrawal') {
          cashBalance -= newAmount - newCommission;
          if (cashBalance < 0) {
            throw InsufficientCashDrawerBalanceException();
          }
        }
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
        if (operation.operationType == 'deposit') {
          cashBalance -= operation.commission;
          if (cashBalance < 0) {
            throw InsufficientCashDrawerBalanceException();
          }
        } else if (operation.operationType == 'withdrawal') {
          cashBalance += operation.amount - operation.commission;
        }
      }
      await (update(cashDrawerTable)..where((c) => c.id.equals(1)))
          .write(CashDrawerTableCompanion(balance: Value(cashBalance)));
    });
  }

  // ── Shift Methods ──

  Future<ShiftsTableData?> getActiveShift() async {
    final active = await (select(shiftsTable)..where((s) => s.endTime.isNull())).get();
    if (active.isEmpty) return null;
    if (active.length == 1) return active.first;
    throw MultipleActiveShiftsException(active.length);
  }

  Future<List<ShiftsTableData>> _getActiveShifts() {
    return (select(shiftsTable)..where((s) => s.endTime.isNull())).get();
  }

  Future<void> repairActiveShifts() async {
    final active = await _getActiveShifts();
    if (active.length <= 1) return;
    active.sort((a, b) => b.startTime.compareTo(a.startTime));
    final duplicates = active.skip(1);
    for (final shift in duplicates) {
      await (update(shiftsTable)..where((s) => s.id.equals(shift.id))).write(
        ShiftsTableCompanion(
          endTime: Value(shift.startTime),
          closingCashDrawer: Value(shift.openingCashDrawer),
        ),
      );
    }
  }

  Future<void> _repairDuplicateActiveShifts() => repairActiveShifts();

  Future<void> _createSingleActiveShiftTrigger() async {
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS trg_single_active_shift
      BEFORE INSERT ON shifts_table
      FOR EACH ROW
      WHEN NEW.end_time IS NULL
      BEGIN
        SELECT CASE
          WHEN EXISTS (SELECT 1 FROM shifts_table WHERE end_time IS NULL)
          THEN RAISE(ABORT, 'Only one active shift is allowed')
        END;
      END;
    ''');
  }

  Future<List<ShiftsTableData>> getShiftHistory() {
    return (select(shiftsTable)
      ..orderBy([(s) => OrderingTerm.desc(s.startTime)])
    ).get();
  }

  Future<ShiftsTableData?> getShiftById(int id) {
    return (select(shiftsTable)..where((s) => s.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertShift(ShiftsTableCompanion shift) async {
    await into(shiftsTable).insert(shift);
  }

  Future<void> closeShift(int id, double closingBalance) async {
    await (update(shiftsTable)..where((s) => s.id.equals(id)))
        .write(ShiftsTableCompanion(
          endTime: Value(DateTime.now()),
          closingCashDrawer: Value(closingBalance),
        ));
  }
  Future<List<DebtorsTableData>> getAllDebtors() {
  return select(debtorsTable).get();
}
Future<DebtorsTableData?> getDebtorByPhone(String phone) async {
  final trimmed = phone.trim();
  if (trimmed.isEmpty) return null;
  final results = await (select(debtorsTable)
        ..where((tbl) => tbl.phone.equals(trimmed)))
      .get();
  return results.isEmpty ? null : results.first;
}
Future<DebtorsTableData?> getDebtorById(int id) {
  return (select(debtorsTable)
        ..where((tbl) => tbl.id.equals(id)))
      .getSingleOrNull();
}
Future<DebtorsTableData?> getDebtorByName(String name) async {
  final trimmed = name.trim();
  final results = await (select(debtorsTable)
        ..where((tbl) => tbl.name.lower().equals(trimmed.toLowerCase())))
      .get();
  return results.isEmpty ? null : results.first;
}
Future<DebtsTableData?> getDebtByOperationId(int operationId) {
  return (select(debtsTable)
        ..where((d) => d.operationId.equals(operationId)))
      .getSingleOrNull();
}
Future<Map<int, DebtsTableData>> getOperationDebts() async {
  final debts = await (select(debtsTable)
        ..where((d) => d.operationId.isNotNull()))
      .get();
  return {for (final d in debts) d.operationId!: d};
}
Future<bool> hasDebt(int operationId) async {
  final debt = await getDebtByOperationId(operationId);
  return debt != null;
}
Future<void> settleDebt(int debtId) async {
  await transaction(() async {
    final debt = await (select(debtsTable)
          ..where((d) => d.id.equals(debtId)))
        .getSingle();

    if (debt.isPaid) return;

    final payments = await (select(debtPaymentsTable)
          ..where((p) => p.debtId.equals(debtId)))
        .get();
    final totalPaidSoFar = payments.fold(0.0, (sum, p) => sum + p.amount);
    final remaining = debt.amount - totalPaidSoFar;

    await payDebt(
      debtId: debtId,
      amount: remaining,
      notes: 'تسوية كاملة',
      paymentMethod: 'cash',
    );
  });
}

Future<List<DebtPaymentsTableData>> getPaymentsForDebts(List<int> debtIds) {
  if (debtIds.isEmpty) return Future.value([]);
  return (select(debtPaymentsTable)
        ..where((tbl) => tbl.debtId.isIn(debtIds)))
      .get();
}

Future<void> payDebt({
  required int debtId,
  required double amount,
  String? notes,
  String paymentMethod = 'cash',
}) {
  return transaction(() async {
    final debt = await (select(debtsTable)..where((d) => d.id.equals(debtId))).getSingle();
    if (debt.isPaid) {
      throw Exception('الدين مدفوع بالفعل بالكامل');
    }

    final payments = await (select(debtPaymentsTable)
          ..where((p) => p.debtId.equals(debtId)))
        .get();
    final totalPaidSoFar = payments.fold(0.0, (sum, p) => sum + p.amount);
    final remaining = debt.amount - totalPaidSoFar;

    if (amount <= 0) {
      throw Exception('قيمة الدفعة يجب أن تكون أكبر من الصفر');
    }
    if (amount > remaining) {
      throw Exception('قيمة الدفعة أكبر من المبلغ المتبقي المستحق');
    }

    await into(debtPaymentsTable).insert(
      DebtPaymentsTableCompanion(
        debtId: Value(debtId),
        amount: Value(amount),
        notes: Value(notes),
        paymentMethod: Value(paymentMethod),
        createdAt: Value(DateTime.now()),
      ),
    );

    final cashDrawer = await (select(cashDrawerTable)..where((c) => c.id.equals(1))).getSingle();
    await (update(cashDrawerTable)..where((c) => c.id.equals(1))).write(
      CashDrawerTableCompanion(
        balance: Value(cashDrawer.balance + amount),
      ),
    );

    final isFullyPaid = (totalPaidSoFar + amount) == debt.amount;
    if (isFullyPaid) {
      await (update(debtsTable)..where((d) => d.id.equals(debtId))).write(
        DebtsTableCompanion(
          isPaid: const Value(true),
          paidAt: Value(DateTime.now()),
        ),
      );
    }
  });
}
Future<int> insertDebtor(DebtorsTableCompanion debtor) {
  return into(debtorsTable).insert(debtor);
}
Future<int> insertDebt(DebtsTableCompanion debt) {
  return into(debtsTable).insert(debt);
}
Future<int> insertCashLoanDebt(DebtsTableCompanion debt) async {
  return await transaction(() async {
    final amount = debt.amount.value;
    final cashDrawer = await (select(cashDrawerTable)..where((c) => c.id.equals(1))).getSingle();
    if (cashDrawer.balance < amount) {
      throw InsufficientCashDrawerBalanceException();
    }
    await (update(cashDrawerTable)..where((c) => c.id.equals(1)))
        .write(CashDrawerTableCompanion(balance: Value(cashDrawer.balance - amount)));
    return await into(debtsTable).insert(debt);
  });
}
Future<List<DebtsTableData>> getDebtsByDebtor(int debtorId) {
  return (select(debtsTable)
        ..where((tbl) => tbl.debtorId.equals(debtorId)))
      .get();
}
Future<List<DebtsTableData>> getUnpaidDebts() {
  return (select(debtsTable)
        ..where((tbl) => tbl.isPaid.equals(false)))
      .get();
}
Future<double> getTotalOutstandingDebt() async {
  final query = selectOnly(debtsTable)
    ..addColumns([debtsTable.amount.sum()])
    ..where(debtsTable.isPaid.equals(false));

  final result = await query.getSingle();

  return result.read(debtsTable.amount.sum()) ?? 0;
}
Future<List<InstaPayAccountsTableData>> getAllInstaPayAccounts() {
  return select(instaPayAccountsTable).get();
}

Future<void> updateDebtorRecord(int id, DebtorsTableCompanion debtor) {
  return (update(debtorsTable)..where((d) => d.id.equals(id))).write(debtor);
}

Future<void> updateDebtRecord(int id, DebtsTableCompanion debt) {
  return (update(debtsTable)..where((d) => d.id.equals(id))).write(debt);
}

Future<void> updateCashLoanDebtAmount(int debtId, double newAmount) async {
  await transaction(() async {
    final debt = await (select(debtsTable)..where((d) => d.id.equals(debtId))).getSingle();
    final delta = newAmount - debt.amount;
    if (delta != 0) {
      final cashDrawer = await (select(cashDrawerTable)..where((c) => c.id.equals(1))).getSingle();
      final newDrawerBalance = cashDrawer.balance - delta;
      if (newDrawerBalance < 0) {
        throw InsufficientCashDrawerBalanceException();
      }
      await (update(cashDrawerTable)..where((c) => c.id.equals(1)))
          .write(CashDrawerTableCompanion(balance: Value(newDrawerBalance)));
      await (update(debtsTable)..where((d) => d.id.equals(debtId)))
          .write(DebtsTableCompanion(amount: Value(newAmount)));
    }
  });
}

Future<void> mergeDebtors({required int sourceDebtorId, required int targetDebtorId}) {
  return transaction(() async {
    await (update(debtsTable)..where((d) => d.debtorId.equals(sourceDebtorId))).write(
      DebtsTableCompanion(debtorId: Value(targetDebtorId)),
    );
    await (delete(debtorsTable)..where((d) => d.id.equals(sourceDebtorId))).go();
  });
}

/// Pays multiple debts in one atomic transaction, oldest-first.
/// [debtIds] must already be sorted oldest-first by the caller.
/// [totalAmount] is the customer's total payment — distributed across debts
/// until exhausted. Partial payment is recorded for the last debt if needed.
Future<void> bulkPayDebts({
  required List<int> debtIds,
  required double totalAmount,
  String? notes,
}) {
  return transaction(() async {
    double remaining = totalAmount;
    final noteText = notes != null && notes.trim().isNotEmpty
        ? notes.trim()
        : 'دفعة سريعة';

    for (final id in debtIds) {
      if (remaining <= 0) break;

      final debt = await (select(debtsTable)..where((d) => d.id.equals(id))).getSingle();
      if (debt.isPaid) continue;

      final payments = await (select(debtPaymentsTable)..where((p) => p.debtId.equals(id))).get();
      final paidSoFar = payments.fold(0.0, (s, p) => s + p.amount);
      final debtRemaining = debt.amount - paidSoFar;

      final payAmount = remaining >= debtRemaining ? debtRemaining : remaining;
      await payDebt(debtId: id, amount: payAmount, notes: noteText, paymentMethod: 'cash');
      remaining -= payAmount;
    }
  });
}

}

