import 'package:drift/drift.dart';

class TransactionsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get note => text()();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get category => text()();
  TextColumn get type => text()();
}