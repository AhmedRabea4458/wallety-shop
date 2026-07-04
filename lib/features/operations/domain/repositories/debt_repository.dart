import 'package:smart_expense/features/operations/domain/entities/debt_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/debtor_entity.dart';

import 'package:smart_expense/features/operations/domain/entities/debt_payment_entity.dart';

abstract class DebtRepository {
  Future<List<DebtorEntity>> getAllDebtors();
  Future<DebtorEntity?> getDebtorById(int id);
  Future<DebtorEntity?> getDebtorByPhone(String phone);
  Future<DebtorEntity?> getDebtorByName(String name);
  Future<Map<int, DebtEntity>> getOperationDebts();
  Future<DebtorEntity> insertDebtor(String name, {String? phone, String? notes});
  Future<DebtEntity> insertDebt(DebtEntity debt);
  Future<DebtEntity> insertCashLoanDebt(DebtEntity debt);
  Future<List<DebtEntity>> getDebtsByDebtor(int debtorId);
  Future<List<DebtEntity>> getUnpaidDebts();
  Future<double> getTotalOutstandingDebt();
  Future<void> markDebtAsPaid(int debtId);
  Future<void> updateDebtor(DebtorEntity debtor);
  Future<void> updateDebt(DebtEntity debt);
  Future<void> updateCashLoanDebtAmount(int debtId, double newAmount);
  Future<void> mergeDebtors({required int sourceDebtorId, required int targetDebtorId});
  
  // Partial Payments
  Future<List<DebtPaymentEntity>> getPaymentsForDebts(List<int> debtIds);
  Future<void> payDebt({required int debtId, required double amount, String? notes, String paymentMethod = 'cash'});
}
