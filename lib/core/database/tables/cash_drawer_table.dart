import 'package:drift/drift.dart';

class CashDrawerTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get balance => real().withDefault(const Constant(0.0))();
  RealColumn get initialBalance => real().withDefault(const Constant(0.0))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
