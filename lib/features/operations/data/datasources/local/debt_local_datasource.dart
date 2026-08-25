import 'package:smart_expense/features/operations/data/models/debt_model.dart';
import 'package:smart_expense/features/operations/data/models/debtor_model.dart';
import 'package:smart_expense/features/operations/data/models/debt_payment_model.dart';

abstract class DebtLocalDataSource {
  Future<List<DebtorModel>> getAllDebtors();
  Future<DebtorModel?> getDebtorById(int id);
  Future<DebtorModel?> getDebtorByPhone(String phone);
  Future<DebtorModel?> getDebtorByName(String name);
  Future<DebtModel?> getDebtByOperationId(int operationId);
  Future<Map<int, DebtModel>> getOperationDebts();
  Future<int> insertDebtor(DebtorModel debtor);
  Future<int> insertDebt(DebtModel debt);
  Future<int> insertCashLoanDebt(DebtModel debt);
  Future<List<DebtModel>> getDebtsByDebtor(int debtorId);
  Future<List<DebtModel>> getUnpaidDebts();
  Future<double> getTotalOutstandingDebt();
  Future<void> settleDebt(int debtId, {String paymentMethod = 'cash'});
  Future<void> updateDebtor(DebtorModel debtor);
  Future<void> updateDebt(DebtModel debt);
  Future<void> updateCashLoanDebtAmount(int debtId, double newAmount);
  Future<void> mergeDebtors({required int sourceDebtorId, required int targetDebtorId});
  
  // Timeframe queries
  Future<List<DebtModel>> getDebtsInTimeframe(DateTime start, DateTime? end);
  Future<List<DebtPaymentModel>> getDebtPaymentsInTimeframe(DateTime start, DateTime? end);

  // Partial Payments
  Future<List<DebtPaymentModel>> getPaymentsForDebts(List<int> debtIds);
  Future<void> payDebt({required int debtId, required double amount, String? notes, String paymentMethod = 'cash'});

  // Bulk Payment
  Future<void> bulkPayDebts({required List<int> debtIds, required double totalAmount, String? notes, String paymentMethod = 'cash'});
}
