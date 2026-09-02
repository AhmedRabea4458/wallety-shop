import 'package:smart_expense/features/operations/domain/entities/instapay_account_entity.dart';

abstract class InstaPayAccountRepository {
  Future<List<InstaPayAccountEntity>> getAll();
  Future<int> insert(String name, {double balance = 0.0});
  Future<void> update(InstaPayAccountEntity account);
  Future<void> delete(int id);
  Future<void> updateBalance(int id, double newBalance);
}
