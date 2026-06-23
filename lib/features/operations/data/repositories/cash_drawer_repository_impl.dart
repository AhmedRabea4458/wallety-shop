import 'package:smart_expense/features/operations/data/datasources/local/cash_drawer_local_datasource.dart';
import 'package:smart_expense/features/operations/domain/entities/cash_drawer_entity.dart';
import 'package:smart_expense/features/operations/domain/repositories/cash_drawer_repository.dart';

class CashDrawerRepositoryImpl implements CashDrawerRepository {
  final CashDrawerLocalDataSource localDataSource;

  CashDrawerRepositoryImpl(this.localDataSource);

  @override
  Future<CashDrawerEntity?> getCashDrawer() async {
    final data = await localDataSource.getCashDrawer();
    return data?.toEntity();
  }

  @override
  Future<void> updateBalance(double newBalance) async {
    await localDataSource.updateBalance(newBalance);
  }
}
