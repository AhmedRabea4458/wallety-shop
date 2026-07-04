import 'package:drift/drift.dart';
import 'package:smart_expense/core/database/tables/debts_table.dart';

class DebtPaymentsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get debtId => integer().references(DebtsTable, #id)();
  RealColumn get amount => real()();
  TextColumn get notes => text().nullable()();
  TextColumn get paymentMethod => text().withDefault(const Constant('cash'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
