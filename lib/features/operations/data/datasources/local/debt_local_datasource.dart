import 'package:smart_expense/features/operations/data/models/debt_model.dart';
import 'package:smart_expense/features/operations/data/models/debtor_model.dart';

abstract class DebtLocalDataSource {
  Future<List<DebtorModel>> getAllDebtors();
  Future<DebtorModel?> getDebtorById(int id);
  Future<DebtorModel?> getDebtorByPhone(String phone);
  Future<DebtModel?> getDebtByOperationId(int operationId);
  Future<Map<int, DebtModel>> getOperationDebts();
  Future<int> insertDebtor(DebtorModel debtor);
  Future<int> insertDebt(DebtModel debt);
  Future<int> insertCashLoanDebt(DebtModel debt);
  Future<List<DebtModel>> getDebtsByDebtor(int debtorId);
  Future<List<DebtModel>> getUnpaidDebts();
  Future<double> getTotalOutstandingDebt();
  Future<void> settleDebt(int debtId);
  Future<void> updateDebtor(DebtorModel debtor);
  Future<void> updateDebt(DebtModel debt);
  Future<void> updateCashLoanDebtAmount(int debtId, double newAmount);
}
