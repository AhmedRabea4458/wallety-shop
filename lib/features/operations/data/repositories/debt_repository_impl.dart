import 'package:smart_expense/features/operations/data/datasources/local/debt_local_datasource.dart';
import 'package:smart_expense/features/operations/data/models/debt_model.dart';
import 'package:smart_expense/features/operations/data/models/debtor_model.dart';
import 'package:smart_expense/features/operations/domain/entities/debt_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/debtor_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/debt_payment_entity.dart';
import 'package:smart_expense/features/operations/domain/repositories/debt_repository.dart';

class DebtRepositoryImpl implements DebtRepository {
  final DebtLocalDataSource localDataSource;

  DebtRepositoryImpl(this.localDataSource);

  @override
  Future<List<DebtorEntity>> getAllDebtors() {
    return localDataSource.getAllDebtors().then(
      (data) => data.map((m) => m.toEntity()).toList(),
    );
  }

  @override
  Future<DebtorEntity?> getDebtorById(int id) {
    return localDataSource.getDebtorById(id).then(
      (model) => model?.toEntity(),
    );
  }

  @override
  Future<DebtorEntity?> getDebtorByPhone(String phone) {
    return localDataSource.getDebtorByPhone(phone).then(
      (model) => model?.toEntity(),
    );
  }

  @override
  Future<DebtorEntity?> getDebtorByName(String name) {
    return localDataSource.getDebtorByName(name).then(
      (model) => model?.toEntity(),
    );
  }

  @override
  Future<Map<int, DebtEntity>> getOperationDebts() async {
    final data = await localDataSource.getOperationDebts();
    return data.map((operationId, debt) => MapEntry(operationId, debt.toEntity()));
  }

  @override
  Future<DebtorEntity> insertDebtor(String name, {String? phone, String? notes}) async {
    final model = DebtorModel(
      id: 0,
      name: name,
      phone: phone,
      notes: notes,
      createdAt: DateTime.now(),
    );
    final id = await localDataSource.insertDebtor(model);
    return model.copyWith(id: id).toEntity();
  }

  @override
  Future<DebtEntity> insertDebt(DebtEntity debt) async {
    final model = DebtModel.fromEntity(debt);
    final id = await localDataSource.insertDebt(model);
    return model.copyWith(id: id).toEntity();
  }

  @override
  Future<DebtEntity> insertCashLoanDebt(DebtEntity debt) async {
    final model = DebtModel.fromEntity(debt);
    final id = await localDataSource.insertCashLoanDebt(model);
    return model.copyWith(id: id).toEntity();
  }

  @override
  Future<List<DebtEntity>> getDebtsByDebtor(int debtorId) {
    return localDataSource.getDebtsByDebtor(debtorId).then(
      (data) => data.map((m) => m.toEntity()).toList(),
    );
  }

  @override
  Future<List<DebtEntity>> getUnpaidDebts() {
    return localDataSource.getUnpaidDebts().then(
      (data) => data.map((m) => m.toEntity()).toList(),
    );
  }

  @override
  Future<double> getTotalOutstandingDebt() {
    return localDataSource.getTotalOutstandingDebt();
  }

  @override
  Future<void> markDebtAsPaid(int debtId) {
    return localDataSource.settleDebt(debtId);
  }

  @override
  Future<void> updateDebtor(DebtorEntity debtor) {
    return localDataSource.updateDebtor(DebtorModel.fromEntity(debtor));
  }

  @override
  Future<void> updateDebt(DebtEntity debt) {
    return localDataSource.updateDebt(DebtModel.fromEntity(debt));
  }

  @override
  Future<void> updateCashLoanDebtAmount(int debtId, double newAmount) {
    return localDataSource.updateCashLoanDebtAmount(debtId, newAmount);
  }

  @override
  Future<void> mergeDebtors({required int sourceDebtorId, required int targetDebtorId}) {
    return localDataSource.mergeDebtors(sourceDebtorId: sourceDebtorId, targetDebtorId: targetDebtorId);
  }

  @override
  Future<List<DebtPaymentEntity>> getPaymentsForDebts(List<int> debtIds) {
    return localDataSource.getPaymentsForDebts(debtIds).then(
      (data) => data.map((m) => m.toEntity()).toList(),
    );
  }

  @override
  Future<List<DebtEntity>> getDebtsInTimeframe(DateTime start, DateTime? end) {
    return localDataSource.getDebtsInTimeframe(start, end).then(
      (data) => data.map((m) => m.toEntity()).toList(),
    );
  }

  @override
  Future<List<DebtPaymentEntity>> getDebtPaymentsInTimeframe(DateTime start, DateTime? end) {
    return localDataSource.getDebtPaymentsInTimeframe(start, end).then(
      (data) => data.map((m) => m.toEntity()).toList(),
    );
  }

  @override
  Future<void> payDebt({required int debtId, required double amount, String? notes, String paymentMethod = 'cash'}) {
    return localDataSource.payDebt(debtId: debtId, amount: amount, notes: notes, paymentMethod: paymentMethod);
  }

  @override
  Future<void> bulkPayDebts({required List<int> debtIds, required double totalAmount, String? notes}) {
    return localDataSource.bulkPayDebts(debtIds: debtIds, totalAmount: totalAmount, notes: notes);
  }
}
