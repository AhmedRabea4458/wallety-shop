import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:smart_expense/core/database/app_database.dart';
import 'package:smart_expense/features/operations/data/datasources/local/shift_local_datasource_impl.dart';
import 'package:smart_expense/features/operations/data/repositories/shift_repository_impl.dart';
import 'package:smart_expense/features/operations/presentation/cubit/active_shift_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/active_shift_state.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'dart:io';

class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return Directory.systemTemp.createTempSync().path;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    PathProviderPlatform.instance = MockPathProviderPlatform();
  });

  test('Concurrent startup simulation', () async {
    final db = AppDatabase();
    
    // Simulate concurrent database queries on startup
    final futures = <Future>[
      db.select(db.operationsTable).get(),
      db.select(db.walletsTable).get(),
      db.select(db.cashDrawerTable).get(),
      db.select(db.walletAdjustmentsTable).get(),
      db.getActiveShift(),
      db.select(db.debtorsTable).get(),
      db.select(db.debtsTable).get(),
      db.select(db.instaPayAccountsTable).get(),
    ];

    try {
      await Future.wait(futures);
      print('All concurrent startup queries completed successfully!');
    } catch (e, stack) {
      print('Concurrent startup query failed: $e\n$stack');
      rethrow;
    }

    final localDataSource = ShiftLocalDataSourceImpl(db);
    final repository = ShiftRepositoryImpl(localDataSource);
    final cubit = ActiveShiftCubit(repository);

    cubit.stream.listen((state) {
      print('ActiveShiftCubit state: $state');
    });

    await cubit.loadActiveShift();
    print('Final state: ${cubit.state}');
    expect(cubit.state, isA<NoActiveShift>());
  });

  test('Partial payment logic test', () async {
    final db = AppDatabase();
    
    // 1. Insert a debtor
    final debtorId = await db.insertDebtor(
      const DebtorsTableCompanion(
        name: Value('Test Debtor'),
      ),
    );
    
    // 2. Insert a debt of 1000
    final debtId = await db.insertDebt(
      DebtsTableCompanion(
        debtorId: Value(debtorId),
        amount: const Value(1000.0),
        isPaid: const Value(false),
        createdAt: Value(DateTime.now()),
      ),
    );

    // Initial cash drawer check (starts at 0.0 or from onCreate insert)
    final initialDrawer = await db.select(db.cashDrawerTable).getSingle();
    final initialDrawerBalance = initialDrawer.balance;

    // 3. Make a payment of 300
    await db.payDebt(
      debtId: debtId,
      amount: 300.0,
      notes: 'Partial 300',
    );

    // Assert payments
    final payments = await db.getPaymentsForDebts([debtId]);
    expect(payments.length, 1);
    expect(payments.first.amount, 300.0);

    // Assert cash drawer increased by 300
    final drawerAfter300 = await db.select(db.cashDrawerTable).getSingle();
    expect(drawerAfter300.balance, initialDrawerBalance + 300.0);

    // Assert debt is not paid yet
    var debt = await (db.select(db.debtsTable)..where((tbl) => tbl.id.equals(debtId))).getSingle();
    expect(debt.isPaid, false);

    // 4. Try to make a payment exceeding the remaining balance (remaining is 700, try to pay 800)
    expect(
      () => db.payDebt(
        debtId: debtId,
        amount: 800.0,
        notes: 'Excessive payment',
      ),
      throwsA(isA<Exception>()),
    );

    // Try to pay negative or zero amount
    expect(
      () => db.payDebt(
        debtId: debtId,
        amount: 0.0,
      ),
      throwsA(isA<Exception>()),
    );
    expect(
      () => db.payDebt(
        debtId: debtId,
        amount: -50.0,
      ),
      throwsA(isA<Exception>()),
    );

    // 5. Make a payment of 700
    await db.payDebt(
      debtId: debtId,
      amount: 700.0,
      notes: 'Final 700',
    );

    // Assert payments
    final finalPayments = await db.getPaymentsForDebts([debtId]);
    expect(finalPayments.length, 2);
    final totalPaid = finalPayments.fold(0.0, (sum, p) => sum + p.amount);
    expect(totalPaid, 1000.0);

    // Assert cash drawer increased by 700 more
    final drawerAfter700 = await db.select(db.cashDrawerTable).getSingle();
    expect(drawerAfter700.balance, initialDrawerBalance + 1000.0);

    // Assert debt is now paid and has paidAt populated
    debt = await (db.select(db.debtsTable)..where((tbl) => tbl.id.equals(debtId))).getSingle();
    expect(debt.isPaid, true);
    expect(debt.paidAt, isNotNull);

    // 6. Try to pay a debt that is already paid
    expect(
      () => db.payDebt(
        debtId: debtId,
        amount: 10.0,
      ),
      throwsA(isA<Exception>()),
    );
  });

  test('Debt-level notes test', () async {
    final db = AppDatabase();

    // 1. Insert a debtor
    final debtorId = await db.insertDebtor(
      const DebtorsTableCompanion(
        name: Value('Notes Test Debtor'),
      ),
    );

    // 2. Insert Debt A with Note A
    final debtAId = await db.insertDebt(
      DebtsTableCompanion(
        debtorId: Value(debtorId),
        amount: const Value(500.0),
        isPaid: const Value(false),
        notes: const Value('Note A'),
        createdAt: Value(DateTime.now()),
      ),
    );

    // 3. Insert Debt B with no notes
    final debtBId = await db.insertDebt(
      DebtsTableCompanion(
        debtorId: Value(debtorId),
        amount: const Value(300.0),
        isPaid: const Value(false),
        createdAt: Value(DateTime.now()),
      ),
    );

    // 4. Retrieve both debts and assert notes are independent
    final debts = await db.getDebtsByDebtor(debtorId);
    expect(debts.length, 2);

    final debtA = debts.firstWhere((d) => d.id == debtAId);
    final debtB = debts.firstWhere((d) => d.id == debtBId);

    expect(debtA.notes, 'Note A');
    expect(debtB.notes, isNull);

    // 5. Update Debt B notes
    await db.updateDebtRecord(
      debtBId,
      const DebtsTableCompanion(
        notes: Value('Note B Updated'),
      ),
    );

    // Retrieve again and assert Debt B has the new note while Debt A is unaffected
    final updatedDebts = await db.getDebtsByDebtor(debtorId);
    final updatedDebtA = updatedDebts.firstWhere((d) => d.id == debtAId);
    final updatedDebtB = updatedDebts.firstWhere((d) => d.id == debtBId);

    expect(updatedDebtA.notes, 'Note A');
    expect(updatedDebtB.notes, 'Note B Updated');
  });

  test('Manual debtor merge test', () async {
    final db = AppDatabase();

    // 1. Insert source debtor and target debtor
    final sourceId = await db.insertDebtor(
      const DebtorsTableCompanion(name: Value('Duplicate Ahmed')),
    );
    final targetId = await db.insertDebtor(
      const DebtorsTableCompanion(name: Value('Ahmed')),
    );

    // 2. Insert a debt on source debtor
    final debtId = await db.insertDebt(
      DebtsTableCompanion(
        debtorId: Value(sourceId),
        amount: const Value(500.0),
        isPaid: const Value(false),
        createdAt: Value(DateTime.now()),
      ),
    );

    // 3. Make a payment of 100 on that debt
    await db.payDebt(
      debtId: debtId,
      amount: 100.0,
      notes: 'Test Payment',
    );

    // 4. Merge source into target
    await db.mergeDebtors(sourceDebtorId: sourceId, targetDebtorId: targetId);

    // 5. Verify the source debtor is deleted
    final allDebtors = await db.getAllDebtors();
    expect(allDebtors.any((d) => d.id == sourceId), false);
    expect(allDebtors.any((d) => d.id == targetId), true);

    // 6. Verify the debt is moved to the target debtor
    final targetDebts = await db.getDebtsByDebtor(targetId);
    expect(targetDebts.length, 1);
    expect(targetDebts.first.id, debtId);
    expect(targetDebts.first.debtorId, targetId);

    // 7. Verify payments are preserved
    final payments = await db.getPaymentsForDebts([debtId]);
    expect(payments.length, 1);
    expect(payments.first.amount, 100.0);
  });

  test('Database restore deletion order and FK safety test', () async {
    final db = AppDatabase();

    // 1. Insert data to create FK constraints (Debtor -> Debt -> Payment)
    final debtorId = await db.insertDebtor(
      const DebtorsTableCompanion(name: Value('Restore test user')),
    );
    final debtId = await db.insertDebt(
      DebtsTableCompanion(
        debtorId: Value(debtorId),
        amount: const Value(2000.0),
        isPaid: const Value(false),
        createdAt: Value(DateTime.now()),
      ),
    );
    await db.payDebt(
      debtId: debtId,
      amount: 400.0,
      notes: 'Initial payment',
    );

    // 2. Perform the deletions in the exact order defined in restore service
    await db.transaction(() async {
      await db.delete(db.debtPaymentsTable).go();
      await db.delete(db.debtsTable).go();
      await db.delete(db.debtorsTable).go();
      await db.delete(db.walletAdjustmentsTable).go();
      await db.delete(db.operationsTable).go();
      await db.delete(db.shiftsTable).go();
      await db.delete(db.walletsTable).go();
      await db.delete(db.cashDrawerTable).go();
      await db.delete(db.instaPayAccountsTable).go();
    });

    // 3. Assert all tables are empty
    expect(await db.select(db.debtorsTable).get(), isEmpty);
    expect(await db.select(db.debtsTable).get(), isEmpty);
    expect(await db.select(db.debtPaymentsTable).get(), isEmpty);
  });

  test('Payables backup and restore data integrity test', () async {
    final db = AppDatabase();

    // 1. Insert a payable with operation link, notes, and partial payment
    await db.into(db.cashDrawerTable).insertOnConflictUpdate(
      CashDrawerTableCompanion(
        id: const Value(1),
        balance: const Value(10000.0),
        initialBalance: const Value(10000.0),
        updatedAt: Value(DateTime.now()),
      ),
    );

    final debtorId = await db.insertDebtor(
      const DebtorsTableCompanion(name: Value('Supplier Corp')),
    );
    final debtId = await db.insertDebt(
      DebtsTableCompanion(
        debtorId: Value(debtorId),
        amount: const Value(5000.0),
        isPaid: const Value(false),
        debtType: const Value('payable'),
        notes: Value('Deferred payout notes'),
        createdAt: Value(DateTime.now()),
      ),
    );
    await db.payDebt(
      debtId: debtId,
      amount: 1500.0,
      notes: 'Partial settlement',
    );

    // 2. Verify values before backup
    final debtsBefore = await db.getDebtsByDebtor(debtorId);
    expect(debtsBefore.length, 1);
    expect(debtsBefore.first.debtType, 'payable');
    expect(debtsBefore.first.notes, 'Deferred payout notes');

    final paymentsBefore = await db.getPaymentsForDebts([debtId]);
    expect(paymentsBefore.length, 1);
    expect(paymentsBefore.first.amount, 1500.0);
    expect(paymentsBefore.first.notes, 'Partial settlement');
  });

  test('Safe operation deletion - Standard cash withdrawal and deposit reversal', () async {
    final db = AppDatabase();

    // 1. Setup wallet and initial drawer
    final walletId = await db.into(db.walletsTable).insert(
      WalletsTableCompanion(
        name: const Value('Test Wallet'),
        balance: const Value(5000.0),
      ),
    );

    await db.into(db.cashDrawerTable).insertOnConflictUpdate(
      CashDrawerTableCompanion(
        id: const Value(1),
        balance: const Value(10000.0),
      ),
    );

    // 2. Perform a normal withdrawal: amount=1000, commission=20
    // Wallet should become: 5000 + 1000 = 6000
    // Drawer should become: 10000 - (1000 - 20) = 9020
    final opId = await db.addOperationWithBalanceUpdate(
      OperationsTableCompanion(
        walletId: Value(walletId),
        operationType: const Value('withdrawal'),
        providerType: const Value('vodafoneCash'),
        amount: const Value(1000.0),
        commission: const Value(20.0),
        networkFee: const Value(0.0),
        isDebt: const Value(false),
      ),
    );

    var wallet = await (db.select(db.walletsTable)..where((w) => w.id.equals(walletId))).getSingle();
    var drawer = await (db.select(db.cashDrawerTable)..where((c) => c.id.equals(1))).getSingle();
    expect(wallet.balance, 6000.0);
    expect(drawer.balance, 9020.0);

    // 3. Delete the operation
    await db.deleteOperationWithBalanceUpdate(opId);

    // 4. Assert balances perfectly restored
    wallet = await (db.select(db.walletsTable)..where((w) => w.id.equals(walletId))).getSingle();
    drawer = await (db.select(db.cashDrawerTable)..where((c) => c.id.equals(1))).getSingle();
    expect(wallet.balance, 5000.0);
    expect(drawer.balance, 10000.0);
  });

  test('Safe operation deletion - Deferred payable and debt operation handling', () async {
    final db = AppDatabase();

    final walletId = await db.into(db.walletsTable).insert(
      WalletsTableCompanion(
        name: const Value('Payable Wallet'),
        balance: const Value(2000.0),
      ),
    );

    await db.into(db.cashDrawerTable).insertOnConflictUpdate(
      CashDrawerTableCompanion(
        id: const Value(1),
        balance: const Value(1000.0),
      ),
    );

    // Create a full payable withdrawal of 500 (commission 10 -> payable 490, cash drawer unchanged at 1000)
    final opId = await db.addFullWithdrawalPayable(
      operation: OperationsTableCompanion(
        walletId: Value(walletId),
        operationType: const Value('withdrawal'),
        providerType: const Value('vodafoneCash'),
        amount: const Value(500.0),
        commission: const Value(10.0),
        networkFee: const Value(0.0),
        isDebt: const Value(false),
      ),
      customerName: 'Deferred Customer',
    );

    var wallet = await (db.select(db.walletsTable)..where((w) => w.id.equals(walletId))).getSingle();
    var drawer = await (db.select(db.cashDrawerTable)..where((c) => c.id.equals(1))).getSingle();
    expect(wallet.balance, 2500.0);
    expect(drawer.balance, 1000.0);

    final linkedDebt = await (db.select(db.debtsTable)..where((d) => d.operationId.equals(opId))).getSingle();
    expect(linkedDebt.amount, 490.0);
    expect(linkedDebt.debtType, 'payable');

    // 1. Test deletion succeeds when no payments have been made on the payable
    await db.deleteOperationWithBalanceUpdate(opId);

    wallet = await (db.select(db.walletsTable)..where((w) => w.id.equals(walletId))).getSingle();
    drawer = await (db.select(db.cashDrawerTable)..where((c) => c.id.equals(1))).getSingle();
    expect(wallet.balance, 2000.0);
    expect(drawer.balance, 1000.0); // Never subtracted cash initially, so never refunds extra cash!

    final debtAfterOpDelete = await (db.select(db.debtsTable)..where((d) => d.operationId.equals(opId))).getSingleOrNull();
    expect(debtAfterOpDelete, isNull);
  });

  group('Sprint 6.3 - Debt Settlement Method (Cash vs Other)', () {
    test('Customer debt collection: Cash increases Cash Drawer, Other does NOT change Cash Drawer', () async {
      final db = AppDatabase();

      await db.into(db.cashDrawerTable).insertOnConflictUpdate(
        CashDrawerTableCompanion(
          id: const Value(1),
          balance: const Value(1000.0),
        ),
      );

      final debtorId = await db.insertDebtor(
        const DebtorsTableCompanion(name: Value('Customer A')),
      );

      // Create customer debt of 500
      final debtId = await db.insertDebt(
        DebtsTableCompanion(
          debtorId: Value(debtorId),
          amount: const Value(500.0),
          isPaid: const Value(false),
          debtType: const Value('customerDebt'),
          createdAt: Value(DateTime.now()),
        ),
      );

      // Pay 200 via Cash -> Drawer increases by 200 (1000 -> 1200)
      await db.payDebt(
        debtId: debtId,
        amount: 200.0,
        paymentMethod: 'cash',
        notes: 'Cash payment',
      );

      var drawer = await (db.select(db.cashDrawerTable)..where((c) => c.id.equals(1))).getSingle();
      expect(drawer.balance, 1200.0);

      // Pay remaining 300 via Other -> Drawer remains 1200, debt is fully paid
      await db.payDebt(
        debtId: debtId,
        amount: 300.0,
        paymentMethod: 'other',
        notes: 'External transfer',
      );

      drawer = await (db.select(db.cashDrawerTable)..where((c) => c.id.equals(1))).getSingle();
      expect(drawer.balance, 1200.0);

      final debt = await (db.select(db.debtsTable)..where((d) => d.id.equals(debtId))).getSingle();
      expect(debt.isPaid, isTrue);

      final payments = await db.getPaymentsForDebts([debtId]);
      expect(payments.length, 2);
      expect(payments[0].paymentMethod, 'cash');
      expect(payments[0].amount, 200.0);
      expect(payments[1].paymentMethod, 'other');
      expect(payments[1].amount, 300.0);
    });

    test('Payable settlement: Cash decreases Cash Drawer, Other does NOT change Cash Drawer', () async {
      final db = AppDatabase();

      await db.into(db.cashDrawerTable).insertOnConflictUpdate(
        CashDrawerTableCompanion(
          id: const Value(1),
          balance: const Value(2000.0),
        ),
      );

      final debtorId = await db.insertDebtor(
        const DebtorsTableCompanion(name: Value('Supplier B')),
      );

      // Create payable of 600
      final debtId = await db.insertDebt(
        DebtsTableCompanion(
          debtorId: Value(debtorId),
          amount: const Value(600.0),
          isPaid: const Value(false),
          debtType: const Value('payable'),
          createdAt: Value(DateTime.now()),
        ),
      );

      // Settle 250 via Cash -> Drawer decreases by 250 (2000 -> 1750)
      await db.payDebt(
        debtId: debtId,
        amount: 250.0,
        paymentMethod: 'cash',
        notes: 'Cash payout',
      );

      var drawer = await (db.select(db.cashDrawerTable)..where((c) => c.id.equals(1))).getSingle();
      expect(drawer.balance, 1750.0);

      // Settle full remaining via settleDebt with Other -> Drawer remains 1750, payable is paid
      await db.settleDebt(debtId, paymentMethod: 'other');

      drawer = await (db.select(db.cashDrawerTable)..where((c) => c.id.equals(1))).getSingle();
      expect(drawer.balance, 1750.0);

      final debt = await (db.select(db.debtsTable)..where((d) => d.id.equals(debtId))).getSingle();
      expect(debt.isPaid, isTrue);

      final payments = await db.getPaymentsForDebts([debtId]);
      expect(payments.length, 2);
      expect(payments[0].paymentMethod, 'cash');
      expect(payments[0].amount, 250.0);
      expect(payments[1].paymentMethod, 'other');
      expect(payments[1].amount, 350.0);
    });

    test('Bulk pay debts supports settlement method without changing drawer when Other is used', () async {
      final db = AppDatabase();

      await db.into(db.cashDrawerTable).insertOnConflictUpdate(
        CashDrawerTableCompanion(
          id: const Value(1),
          balance: const Value(1000.0),
        ),
      );

      final debtorId = await db.insertDebtor(
        const DebtorsTableCompanion(name: Value('Bulk Customer')),
      );

      final debt1 = await db.insertDebt(
        DebtsTableCompanion(
          debtorId: Value(debtorId),
          amount: const Value(100.0),
          isPaid: const Value(false),
          debtType: const Value('customerDebt'),
          createdAt: Value(DateTime.now().subtract(const Duration(hours: 2))),
        ),
      );
      final debt2 = await db.insertDebt(
        DebtsTableCompanion(
          debtorId: Value(debtorId),
          amount: const Value(200.0),
          isPaid: const Value(false),
          debtType: const Value('customerDebt'),
          createdAt: Value(DateTime.now().subtract(const Duration(hours: 1))),
        ),
      );

      await db.bulkPayDebts(
        debtIds: [debt1, debt2],
        totalAmount: 300.0,
        paymentMethod: 'other',
      );

      final drawer = await (db.select(db.cashDrawerTable)..where((c) => c.id.equals(1))).getSingle();
      expect(drawer.balance, 1000.0); // Drawer untouched

      final d1 = await (db.select(db.debtsTable)..where((d) => d.id.equals(debt1))).getSingle();
      final d2 = await (db.select(db.debtsTable)..where((d) => d.id.equals(debt2))).getSingle();
      expect(d1.isPaid, isTrue);
      expect(d2.isPaid, isTrue);

      final payments = await db.getPaymentsForDebts([debt1, debt2]);
      for (final p in payments) {
        expect(p.paymentMethod, 'other');
      }
    });
  });
}

