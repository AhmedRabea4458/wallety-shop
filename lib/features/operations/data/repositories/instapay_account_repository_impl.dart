import 'package:smart_expense/features/operations/data/datasources/local/instapay_account_local_datasource.dart';
import 'package:smart_expense/features/operations/data/models/instapay_account_model.dart';
import 'package:smart_expense/features/operations/domain/entities/instapay_account_entity.dart';
import 'package:smart_expense/features/operations/domain/repositories/instapay_account_repository.dart';

class InstaPayAccountRepositoryImpl implements InstaPayAccountRepository {
  final InstaPayAccountLocalDataSource localDataSource;

  InstaPayAccountRepositoryImpl(this.localDataSource);

  @override
  Future<List<InstaPayAccountEntity>> getAll() {
    return localDataSource.getAll().then(
      (data) => data.map((m) => m.toEntity()).toList(),
    );
  }

  @override
  Future<int> insert(String name) async {
    final model = InstaPayAccountModel(id: 0, name: name, createdAt: DateTime.now());
    return localDataSource.insert(model);
  }

  @override
  Future<void> update(InstaPayAccountEntity account) {
    final model = InstaPayAccountModel(
      id: account.id,
      name: account.name,
      createdAt: account.createdAt,
    );
    return localDataSource.update(model);
  }

  @override
  Future<void> delete(int id) {
    return localDataSource.delete(id);
  }
}
