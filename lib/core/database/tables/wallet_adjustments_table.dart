import 'package:drift/drift.dart';
import 'wallets_table.dart';

class WalletAdjustmentsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get walletId => integer().references(WalletsTable, #id)();
  TextColumn get periodType => text()(); // 'daily' or 'monthly'
  RealColumn get amount => real()();
  TextColumn get reason => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
