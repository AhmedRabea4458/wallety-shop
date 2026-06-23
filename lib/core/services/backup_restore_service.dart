import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smart_expense/core/database/app_database.dart';
import 'package:smart_expense/core/di/injection_container.dart';
import 'package:smart_expense/features/operations/presentation/cubit/cash_drawer_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/debt_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/operation_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/active_shift_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_adjustment_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_cubit.dart';
import 'package:smart_expense/features/profile/presentation/cubit/profile_cubit.dart';

class BackupRestoreService {
  static AppDatabase get _db => sl<AppDatabase>();

  static Future<void> backup() async {
    final db = _db;
    final now = DateTime.now();

    final data = <String, dynamic>{
      'version': 1,
      'schemaVersion': db.schemaVersion,
      'exportedAt': now.toIso8601String(),
      'wallets': (await db.select(db.walletsTable).get()).map(_walletToJson).toList(),
      'operations': (await db.select(db.operationsTable).get()).map(_operationToJson).toList(),
      'cashDrawer': (await db.select(db.cashDrawerTable).get()).map(_cashDrawerToJson).toList(),
      'walletAdjustments': (await db.select(db.walletAdjustmentsTable).get()).map(_adjustmentToJson).toList(),
      'shifts': (await db.select(db.shiftsTable).get()).map(_shiftToJson).toList(),
      'debtors': (await db.select(db.debtorsTable).get()).map(_debtorToJson).toList(),
      'debts': (await db.select(db.debtsTable).get()).map(_debtToJson).toList(),
      'instaPayAccounts': (await db.select(db.instaPayAccountsTable).get()).map(_instaPayAccountToJson).toList(),
    };

    final json = const JsonEncoder.withIndent('  ').convert(data);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/wallety_backup_${_dateStamp(now)}.json');
    await file.writeAsString(json);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Wallety Backup',
    );
  }

  static Future<String?> pickBackupFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.isEmpty) return null;
    return result.files.single.path;
  }

  static Future<void> restore(String filePath) async {
    final file = File(filePath);
    final json = await file.readAsString();
    final data = jsonDecode(json) as Map<String, dynamic>;

    if (data['wallets'] is! List) {
      throw Exception('الملف غير صالح، تأكد من اختيار نسخة احتياطية صحيحة');
    }

    final db = _db;

    await db.transaction(() async {
      await db.delete(db.debtsTable).go();
      await db.delete(db.debtorsTable).go();
      await db.delete(db.operationsTable).go();
      await db.delete(db.walletAdjustmentsTable).go();
      await db.delete(db.shiftsTable).go();
      await db.delete(db.walletsTable).go();
      await db.delete(db.cashDrawerTable).go();

      for (final w in (data['wallets'] as List).cast<Map<String, dynamic>>()) {
        await db.into(db.walletsTable).insert(
          WalletsTableCompanion(
            id: Value(w['id'] as int),
            name: Value(w['name'] as String),
            balance: Value((w['balance'] as num).toDouble()),
            phoneNumber: Value(w['phoneNumber'] as String?),
            color: Value((w['color'] as String?) ?? 'FF6366F1'),
            dailyLimit: Value((w['dailyLimit'] as num?)?.toDouble() ?? 0.0),
            weeklyLimit: Value((w['weeklyLimit'] as num?)?.toDouble() ?? 0.0),
            monthlyLimit: Value((w['monthlyLimit'] as num?)?.toDouble() ?? 0.0),
            createdAt: Value(DateTime.parse(w['createdAt'] as String)),
          ),
        );
      }

      for (final s in (data['shifts'] as List?)?.cast<Map<String, dynamic>>() ?? []) {
        await db.into(db.shiftsTable).insert(
          ShiftsTableCompanion(
            id: Value(s['id'] as int),
            startTime: Value(DateTime.parse(s['startTime'] as String)),
            endTime: Value(s['endTime'] != null ? DateTime.parse(s['endTime'] as String) : null),
            openingCashDrawer: Value((s['openingCashDrawer'] as num).toDouble()),
            closingCashDrawer: Value((s['closingCashDrawer'] as num?)?.toDouble()),
          ),
        );
      }

      for (final a in (data['walletAdjustments'] as List?)?.cast<Map<String, dynamic>>() ?? []) {
        await db.into(db.walletAdjustmentsTable).insert(
          WalletAdjustmentsTableCompanion(
            id: Value(a['id'] as int),
            walletId: Value(a['walletId'] as int),
            periodType: Value(a['periodType'] as String),
            amount: Value((a['amount'] as num).toDouble()),
            reason: Value(a['reason'] as String?),
            createdAt: Value(DateTime.parse(a['createdAt'] as String)),
          ),
        );
      }

      for (final o in (data['operations'] as List).cast<Map<String, dynamic>>()) {
        await db.into(db.operationsTable).insert(
          OperationsTableCompanion(
            id: Value(o['id'] as int),
            walletId: Value(o['walletId'] as int),
            shiftId: Value(o['shiftId'] as int?),
            operationType: Value(o['operationType'] as String),
            providerType: Value(o['providerType'] as String),
            amount: Value((o['amount'] as num).toDouble()),
            commission: Value((o['commission'] as num).toDouble()),
            networkFee: Value((o['networkFee'] as num).toDouble()),
            phoneNumber: Value(o['phoneNumber'] as String?),
            notes: Value(o['notes'] as String?),
            isDebt: Value((o['isDebt'] as bool?) ?? false),
            instaPayAccountId: Value(o['instaPayAccountId'] as int?),
            createdAt: Value(DateTime.parse(o['createdAt'] as String)),
          ),
        );
      }

      for (final d in (data['debtors'] as List?)?.cast<Map<String, dynamic>>() ?? []) {
        await db.into(db.debtorsTable).insert(
          DebtorsTableCompanion(
            id: Value(d['id'] as int),
            name: Value(d['name'] as String),
            phone: Value(d['phone'] as String?),
            notes: Value(d['notes'] as String?),
            createdAt: Value(DateTime.parse(d['createdAt'] as String)),
          ),
        );
      }

      for (final d in (data['debts'] as List?)?.cast<Map<String, dynamic>>() ?? []) {
        await db.into(db.debtsTable).insert(
          DebtsTableCompanion(
            id: Value(d['id'] as int),
            debtorId: Value(d['debtorId'] as int),
            operationId: Value(d['operationId'] as int?),
            operationType: Value(d['operationType'] as String),
            providerType: Value(d['providerType'] as String?),
            amount: Value((d['amount'] as num).toDouble()),
            isPaid: Value((d['isPaid'] as bool?) ?? false),
            isCashLoan: Value((d['isCashLoan'] as bool?) ?? false),
            paidAt: Value(d['paidAt'] != null ? DateTime.parse(d['paidAt'] as String) : null),
            createdAt: Value(DateTime.parse(d['createdAt'] as String)),
          ),
        );
      }

      for (final c in (data['cashDrawer'] as List?)?.cast<Map<String, dynamic>>() ?? []) {
        await db.into(db.cashDrawerTable).insert(
          CashDrawerTableCompanion(
            id: Value(c['id'] as int),
            balance: Value((c['balance'] as num).toDouble()),
            initialBalance: Value((c['initialBalance'] as num?)?.toDouble() ?? 0.0),
            updatedAt: Value(DateTime.parse(c['updatedAt'] as String)),
          ),
        );
      }

      for (final a in (data['instaPayAccounts'] as List?)?.cast<Map<String, dynamic>>() ?? []) {
        await db.into(db.instaPayAccountsTable).insert(
          InstaPayAccountsTableCompanion(
            id: Value(a['id'] as int),
            name: Value(a['name'] as String),
            createdAt: Value(DateTime.parse(a['createdAt'] as String)),
          ),
        );
      }
    });

    _refreshAllCubits();
  }

  static void _refreshAllCubits() {
    sl<WalletCubit>().getWallets();
    sl<OperationCubit>().getOperations();
    sl<CashDrawerCubit>().getCashDrawer();
    sl<WalletAdjustmentCubit>().loadAllAdjustments();
    sl<ActiveShiftCubit>().loadActiveShift();
    sl<DebtCubit>().loadDebtors();
    sl<DebtCubit>().loadOutstandingDebt();
    sl<ProfileCubit>().getProfileStats();
  }

  static Map<String, dynamic> _walletToJson(WalletsTableData w) => {
        'id': w.id,
        'name': w.name,
        'balance': w.balance,
        'phoneNumber': w.phoneNumber,
        'color': w.color,
        'dailyLimit': w.dailyLimit,
        'weeklyLimit': w.weeklyLimit,
        'monthlyLimit': w.monthlyLimit,
        'createdAt': w.createdAt.toIso8601String(),
      };

  static Map<String, dynamic> _operationToJson(OperationsTableData o) => {
        'id': o.id,
        'walletId': o.walletId,
        'shiftId': o.shiftId,
        'operationType': o.operationType,
        'providerType': o.providerType,
        'amount': o.amount,
        'commission': o.commission,
        'networkFee': o.networkFee,
        'phoneNumber': o.phoneNumber,
        'notes': o.notes,
        'isDebt': o.isDebt,
        'instaPayAccountId': o.instaPayAccountId,
        'createdAt': o.createdAt.toIso8601String(),
      };

  static Map<String, dynamic> _cashDrawerToJson(CashDrawerTableData c) => {
        'id': c.id,
        'balance': c.balance,
        'initialBalance': c.initialBalance,
        'updatedAt': c.updatedAt.toIso8601String(),
      };

  static Map<String, dynamic> _adjustmentToJson(WalletAdjustmentsTableData a) => {
        'id': a.id,
        'walletId': a.walletId,
        'periodType': a.periodType,
        'amount': a.amount,
        'reason': a.reason,
        'createdAt': a.createdAt.toIso8601String(),
      };

  static Map<String, dynamic> _shiftToJson(ShiftsTableData s) => {
        'id': s.id,
        'startTime': s.startTime.toIso8601String(),
        'endTime': s.endTime?.toIso8601String(),
        'openingCashDrawer': s.openingCashDrawer,
        'closingCashDrawer': s.closingCashDrawer,
      };

  static Map<String, dynamic> _debtorToJson(DebtorsTableData d) => {
        'id': d.id,
        'name': d.name,
        'phone': d.phone,
        'notes': d.notes,
        'createdAt': d.createdAt.toIso8601String(),
      };

  static Map<String, dynamic> _debtToJson(DebtsTableData d) => {
        'id': d.id,
        'debtorId': d.debtorId,
        'operationId': d.operationId,
        'operationType': d.operationType,
        'providerType': d.providerType,
        'amount': d.amount,
        'isPaid': d.isPaid,
        'isCashLoan': d.isCashLoan,
        'paidAt': d.paidAt?.toIso8601String(),
        'createdAt': d.createdAt.toIso8601String(),
      };

  static Map<String, dynamic> _instaPayAccountToJson(InstaPayAccountsTableData a) => {
        'id': a.id,
        'name': a.name,
        'createdAt': a.createdAt.toIso8601String(),
      };

  static String _dateStamp(DateTime d) {
    return '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}'
        '_${d.hour.toString().padLeft(2, '0')}${d.minute.toString().padLeft(2, '0')}';
  }
}
