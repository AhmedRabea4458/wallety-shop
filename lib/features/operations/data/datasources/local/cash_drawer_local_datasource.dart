import 'package:smart_expense/features/operations/data/models/cash_drawer_model.dart';

abstract class CashDrawerLocalDataSource {
  Future<CashDrawerModel?> getCashDrawer();
  Future<void> updateBalance(double newBalance);
}
