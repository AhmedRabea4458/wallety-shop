import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:smart_expense/core/database/app_database.dart';
import 'package:smart_expense/core/services/backup_restore_service.dart';
import 'package:smart_expense/core/di/injection_container.dart' as di;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return Directory.systemTemp.createTempSync().path;
  }

  @override
  Future<String?> getTemporaryPath() async {
    return Directory.systemTemp.createTempSync().path;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    PathProviderPlatform.instance = MockPathProviderPlatform();
  });

  test(
    'InstaPay accounts and balances are preserved across backup and restore',
    () async {
      // Reset and initialize DI
      await di.init();

      final db = di.sl<AppDatabase>();

      // Clear existing accounts
      await db.delete(db.instaPayAccountsTable).go();

      // Insert test InstaPay accounts with balances
      final id1 = await db
          .into(db.instaPayAccountsTable)
          .insert(
            InstaPayAccountsTableCompanion(
              name: const Value('InstaPay Account 1'),
              balance: const Value(3500.50),
              createdAt: Value(DateTime.now()),
            ),
          );

      final id2 = await db
          .into(db.instaPayAccountsTable)
          .insert(
            InstaPayAccountsTableCompanion(
              name: const Value('InstaPay Account 2'),
              balance: const Value(12000.0),
              createdAt: Value(DateTime.now()),
            ),
          );

      // Verify in DB
      final accountsBefore = await db.select(db.instaPayAccountsTable).get();
      expect(accountsBefore.length, 2);
      expect(accountsBefore.firstWhere((a) => a.id == id1).balance, 3500.50);
      expect(accountsBefore.firstWhere((a) => a.id == id2).balance, 12000.0);

      // Create a backup json content directly
      final data = <String, dynamic>{
        'version': 1,
        'schemaVersion': db.schemaVersion,
        'exportedAt': DateTime.now().toIso8601String(),
        'wallets': <Map<String, dynamic>>[],
        'operations': <Map<String, dynamic>>[],
        'cashDrawer': <Map<String, dynamic>>[],
        'walletAdjustments': <Map<String, dynamic>>[],
        'shifts': <Map<String, dynamic>>[],
        'debtors': <Map<String, dynamic>>[],
        'debts': <Map<String, dynamic>>[],
        'instaPayAccounts':
            accountsBefore
                .map(
                  (a) => {
                    'id': a.id,
                    'name': a.name,
                    'balance': a.balance,
                    'createdAt': a.createdAt.toIso8601String(),
                  },
                )
                .toList(),
        'debtPayments': <Map<String, dynamic>>[],
      };

      final tempDir = Directory.systemTemp.createTempSync();
      final backupFile = File('${tempDir.path}/test_backup.json');
      await backupFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert(data),
      );

      // Wipe accounts
      await db.delete(db.instaPayAccountsTable).go();
      final emptyAccounts = await db.select(db.instaPayAccountsTable).get();
      expect(emptyAccounts.isEmpty, isTrue);

      // Restore from backup
      await BackupRestoreService.restore(backupFile.path);

      // Verify restored data
      final restoredAccounts = await db.select(db.instaPayAccountsTable).get();
      expect(restoredAccounts.length, 2);

      final restored1 = restoredAccounts.firstWhere((a) => a.id == id1);
      expect(restored1.name, 'InstaPay Account 1');
      expect(restored1.balance, 3500.50);

      final restored2 = restoredAccounts.firstWhere((a) => a.id == id2);
      expect(restored2.name, 'InstaPay Account 2');
      expect(restored2.balance, 12000.0);
    },
  );

  test(
    'Backward compatibility: restoring older backup without balance field defaults to 0.0',
    () async {
      final db = di.sl<AppDatabase>();
      await db.delete(db.instaPayAccountsTable).go();

      final legacyData = <String, dynamic>{
        'version': 1,
        'schemaVersion': 20,
        'exportedAt': DateTime.now().toIso8601String(),
        'wallets': <Map<String, dynamic>>[],
        'operations': <Map<String, dynamic>>[],
        'cashDrawer': <Map<String, dynamic>>[],
        'walletAdjustments': <Map<String, dynamic>>[],
        'shifts': <Map<String, dynamic>>[],
        'debtors': <Map<String, dynamic>>[],
        'debts': <Map<String, dynamic>>[],
        'instaPayAccounts': [
          {
            'id': 100,
            'name': 'Legacy InstaPay Account',
            'createdAt': DateTime.now().toIso8601String(),
            // Note: No balance field present in legacy backups
          },
        ],
        'debtPayments': <Map<String, dynamic>>[],
      };

      final tempDir = Directory.systemTemp.createTempSync();
      final legacyFile = File('${tempDir.path}/legacy_backup.json');
      await legacyFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert(legacyData),
      );

      await BackupRestoreService.restore(legacyFile.path);

      final restored = await db.select(db.instaPayAccountsTable).get();
      expect(restored.length, 1);
      expect(restored.first.id, 100);
      expect(restored.first.name, 'Legacy InstaPay Account');
      expect(restored.first.balance, 0.0);
    },
  );

  test(
    'Backward compatibility: restoring operations without networkFee field defaults to 0.0',
    () async {
      final db = di.sl<AppDatabase>();
      await db.delete(db.operationsTable).go();
      await db.delete(db.walletsTable).go();

      // Ensure a wallet exists
      await db.into(db.walletsTable).insert(
        WalletsTableCompanion(
          id: const Value(1),
          name: const Value('Wallet 1'),
          balance: const Value(1000.0),
          createdAt: Value(DateTime.now()),
        ),
      );

      final legacyData = <String, dynamic>{
        'version': 1,
        'schemaVersion': 20,
        'exportedAt': DateTime.now().toIso8601String(),
        'wallets': [
          {
            'id': 1,
            'name': 'Wallet 1',
            'balance': 1000.0,
            'phoneNumber': null,
            'color': 0xFF000000,
            'dailyLimit': null,
            'weeklyLimit': null,
            'monthlyLimit': null,
            'isArchived': false,
            'createdAt': DateTime.now().toIso8601String(),
          }
        ],
        'operations': [
          {
            'id': 50,
            'walletId': 1,
            'shiftId': null,
            'operationType': 'deposit',
            'providerType': 'instaPay',
            'amount': 250.0,
            // networkFee is omitted in legacy records
            'commission': 5.0,
            'phoneNumber': null,
            'notes': null,
            'isDebt': false,
            'instaPayAccountId': null,
            'createdAt': DateTime.now().toIso8601String(),
          }
        ],
        'cashDrawer': <Map<String, dynamic>>[],
        'walletAdjustments': <Map<String, dynamic>>[],
        'shifts': <Map<String, dynamic>>[],
        'debtors': <Map<String, dynamic>>[],
        'debts': <Map<String, dynamic>>[],
        'instaPayAccounts': <Map<String, dynamic>>[],
        'debtPayments': <Map<String, dynamic>>[],
      };

      final tempDir = Directory.systemTemp.createTempSync();
      final legacyFile = File('${tempDir.path}/legacy_ops_backup.json');
      await legacyFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert(legacyData),
      );

      await BackupRestoreService.restore(legacyFile.path);

      final ops = await db.select(db.operationsTable).get();
      expect(ops.length, 1);
      expect(ops.first.id, 50);
      expect(ops.first.networkFee, 0.0);
    },
  );

  test(
    'InstaPay deposit with networkFee updates, reverses, and deletes correctly',
    () async {
      final db = di.sl<AppDatabase>();
      await db.delete(db.operationsTable).go();
      await db.delete(db.instaPayAccountsTable).go();
      await db.delete(db.walletsTable).go();
      await db.delete(db.cashDrawerTable).go();

      // Setup initial state: wallet (id:1), cash drawer (balance: 5000), instapay (balance: 2000)
      await db.into(db.walletsTable).insert(
        WalletsTableCompanion(
          id: const Value(1),
          name: const Value('Main Wallet'),
          balance: const Value(5000.0),
          createdAt: Value(DateTime.now()),
        ),
      );
      await db.into(db.cashDrawerTable).insert(
        CashDrawerTableCompanion(
          id: const Value(1),
          balance: const Value(5000.0),
          initialBalance: const Value(5000.0),
          updatedAt: Value(DateTime.now()),
        ),
      );
      final accId = await db.into(db.instaPayAccountsTable).insert(
        InstaPayAccountsTableCompanion(
          name: const Value('Test InstaPay'),
          balance: const Value(2000.0),
          createdAt: Value(DateTime.now()),
        ),
      );

      // 1. Insert deposit: amount = 500, networkFee = 15, commission = 10
      final opId = await db.addOperationWithBalanceUpdate(
        OperationsTableCompanion(
          walletId: const Value(1),
          instaPayAccountId: Value(accId),
          operationType: const Value('deposit'),
          providerType: const Value('instaPay'),
          amount: const Value(500.0),
          networkFee: const Value(15.0),
          commission: const Value(10.0),
          isDebt: const Value(false),
          createdAt: Value(DateTime.now()),
        ),
      );

      // InstaPay balance should be 2000 - (500 + 15) = 1485
      var account = await (db.select(db.instaPayAccountsTable)..where((a) => a.id.equals(accId))).getSingle();
      expect(account.balance, 1485.0);

      // Cash drawer should be 5000 + 500 + 10 = 5510 (drawer not affected by networkFee)
      var drawer = await (db.select(db.cashDrawerTable)..where((c) => c.id.equals(1))).getSingle();
      expect(drawer.balance, 5510.0);

      // 2. Update deposit: change amount to 600, networkFee to 20
      await db.updateOperationWithBalanceUpdate(
        OperationsTableCompanion(
          id: Value(opId),
          walletId: const Value(1),
          instaPayAccountId: Value(accId),
          operationType: const Value('deposit'),
          providerType: const Value('instaPay'),
          amount: const Value(600.0),
          networkFee: const Value(20.0),
          commission: const Value(10.0),
          createdAt: Value(DateTime.now()),
        ),
      );

      // Reverses old (1485 + 515 = 2000), applies new (2000 - 620 = 1380)
      account = await (db.select(db.instaPayAccountsTable)..where((a) => a.id.equals(accId))).getSingle();
      expect(account.balance, 1380.0);

      // 3. Delete deposit: should refund full 620 back to account balance
      await db.deleteOperationWithBalanceUpdate(opId);
      account = await (db.select(db.instaPayAccountsTable)..where((a) => a.id.equals(accId))).getSingle();
      expect(account.balance, 2000.0);

      // Drawer should be restored to initial 5000
      drawer = await (db.select(db.cashDrawerTable)..where((c) => c.id.equals(1))).getSingle();
      expect(drawer.balance, 5000.0);
    },
  );
}
