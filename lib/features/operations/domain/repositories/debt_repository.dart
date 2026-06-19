import 'package:smart_expense/features/operations/domain/entities/debt_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/debtor_entity.dart';

abstract class DebtRepository {
  Future<List<DebtorEntity>> getAllDebtors();
  Future<DebtorEntity?> getDebtorById(int id);
  Future<DebtorEntity?> getDebtorByPhone(String phone);
  Future<Map<int, DebtEntity>> getOperationDebts();
  Future<DebtorEntity> insertDebtor(String name, {String? phone, String? notes});
  Future<DebtEntity> insertDebt(DebtEntity debt);
  Future<List<DebtEntity>> getDebtsByDebtor(int debtorId);
  Future<List<DebtEntity>> getUnpaidDebts();
  Future<double> getTotalOutstandingDebt();
  Future<void> markDebtAsPaid(int debtId);
}
