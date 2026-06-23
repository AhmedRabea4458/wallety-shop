import 'package:drift/drift.dart';
import 'package:smart_expense/core/database/app_database.dart';
import 'package:smart_expense/features/operations/data/datasources/local/instapay_account_local_datasource.dart';
import 'package:smart_expense/features/operations/data/models/instapay_account_model.dart';

class InstaPayAccountLocalDataSourceImpl implements InstaPayAccountLocalDataSource {
  final AppDatabase database;

  InstaPayAccountLocalDataSourceImpl(this.database);

  @override
  Future<List<InstaPayAccountModel>> getAll() {
    return database.getAllInstaPayAccounts().then(
      (data) => data.map((e) => InstaPayAccountModel.fromDrift(e)).toList(),
    );
  }

  @override
  Future<int> insert(InstaPayAccountModel account) {
    return database.into(database.instaPayAccountsTable).insert(
      InstaPayAccountsTableCompanion(name: Value(account.name)),
    );
  }

  @override
  Future<void> update(InstaPayAccountModel account) {
    return (database.update(database.instaPayAccountsTable)
          ..where((t) => t.id.equals(account.id)))
        .write(InstaPayAccountsTableCompanion(name: Value(account.name)));
  }

  @override
  Future<void> delete(int id) {
    return (database.delete(database.instaPayAccountsTable)
          ..where((t) => t.id.equals(id)))
        .go();
  }
}
