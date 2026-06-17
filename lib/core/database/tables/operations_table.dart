import 'package:drift/drift.dart';
import 'wallets_table.dart';

class OperationsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get walletId => integer().references(WalletsTable, #id)();
  TextColumn get operationType => text()();
  TextColumn get providerType => text().withDefault(const Constant('vodafoneCash'))();
  RealColumn get amount => real()();
  RealColumn get commission => real().withDefault(const Constant(0.0))();
  RealColumn get networkFee => real().withDefault(const Constant(0.0))();
  TextColumn get phoneNumber => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
