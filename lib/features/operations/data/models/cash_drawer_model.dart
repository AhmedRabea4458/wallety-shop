import 'package:smart_expense/core/database/app_database.dart';
import 'package:smart_expense/features/operations/domain/entities/cash_drawer_entity.dart';

class CashDrawerModel {
  final int id;
  final double balance;
  final double initialBalance;
  final DateTime updatedAt;

  CashDrawerModel({
    required this.id,
    required this.balance,
    required this.initialBalance,
    required this.updatedAt,
  });

  CashDrawerEntity toEntity() {
    return CashDrawerEntity(
      id: id,
      balance: balance,
      initialBalance: initialBalance,
      updatedAt: updatedAt,
    );
  }

  factory CashDrawerModel.fromDrift(CashDrawerTableData data) {
    return CashDrawerModel(
      id: data.id,
      balance: data.balance,
      initialBalance: data.initialBalance,
      updatedAt: data.updatedAt,
    );
  }
}
