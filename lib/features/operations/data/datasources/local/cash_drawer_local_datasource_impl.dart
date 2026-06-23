import 'package:smart_expense/core/database/app_database.dart';
import 'package:smart_expense/features/operations/data/datasources/local/cash_drawer_local_datasource.dart';
import 'package:smart_expense/features/operations/data/models/cash_drawer_model.dart';

class CashDrawerLocalDataSourceImpl implements CashDrawerLocalDataSource {
  final AppDatabase database;

  CashDrawerLocalDataSourceImpl(this.database);

  @override
  Future<CashDrawerModel?> getCashDrawer() async {
    final data = await database.getCashDrawer();
    if (data == null) return null;
    return CashDrawerModel.fromDrift(data);
  }

  @override
  Future<void> updateBalance(double newBalance) async {
    await database.updateCashDrawerBalance(newBalance);
  }
}
