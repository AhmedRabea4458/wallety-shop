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
}
