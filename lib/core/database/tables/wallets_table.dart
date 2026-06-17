import 'package:drift/drift.dart';

class WalletsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get phoneNumber => text().nullable()();
  RealColumn get balance => real().withDefault(const Constant(0.0))();
  TextColumn get color => text().withDefault(const Constant('#6366F1'))();
  RealColumn get dailyLimit => real().withDefault(const Constant(60000.0))();
  RealColumn get weeklyLimit => real().withDefault(const Constant(200000.0))();
  RealColumn get monthlyLimit => real().withDefault(const Constant(200000.0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
