
import 'package:drift/drift.dart';
class DebtorsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get phone => text().nullable().withLength(min: 1, max: 20)();
  TextColumn get notes => text().nullable().withLength(min: 1, max: 255)();
DateTimeColumn get createdAt =>
    dateTime().withDefault(currentDateAndTime)();
}