import 'package:smart_expense/features/operations/domain/entities/cash_drawer_entity.dart';

abstract class CashDrawerRepository {
  Future<CashDrawerEntity?> getCashDrawer();
  Future<void> updateBalance(double newBalance);
}
