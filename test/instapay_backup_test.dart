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
}
