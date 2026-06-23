import 'package:smart_expense/features/operations/data/models/instapay_account_model.dart';

abstract class InstaPayAccountLocalDataSource {
  Future<List<InstaPayAccountModel>> getAll();
  Future<int> insert(InstaPayAccountModel account);
  Future<void> update(InstaPayAccountModel account);
  Future<void> delete(int id);
}
