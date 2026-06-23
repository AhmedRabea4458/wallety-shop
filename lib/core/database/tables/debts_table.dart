import 'package:drift/drift.dart';
import 'package:smart_expense/core/database/tables/debtors_table.dart';
import 'package:smart_expense/core/database/tables/operations_table.dart';
class DebtsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get debtorId => integer().references(DebtorsTable, #id)();
  IntColumn get operationId => integer().nullable().references(OperationsTable, #id)();
  TextColumn get operationType => text().withDefault(const Constant('deposit'))();
      TextColumn get providerType => text().nullable().withDefault(const Constant('vodafoneCash'))();

  RealColumn get amount => real()();
  BoolColumn get isPaid => boolean().withDefault(const Constant(false))();
  BoolColumn get isCashLoan => boolean().withDefault(const Constant(false))();

 DateTimeColumn get paidAt => dateTime().nullable()();
 DateTimeColumn get createdAt =>
     dateTime().withDefault(currentDateAndTime)();}