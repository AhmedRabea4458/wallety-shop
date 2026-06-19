import 'package:drift/drift.dart';
import 'package:smart_expense/core/database/app_database.dart';
import 'package:smart_expense/features/operations/data/datasources/local/debt_local_datasource.dart';
import 'package:smart_expense/features/operations/data/models/debt_model.dart';
import 'package:smart_expense/features/operations/data/models/debtor_model.dart';

class DebtLocalDataSourceImpl implements DebtLocalDataSource {
  final AppDatabase database;

  DebtLocalDataSourceImpl(this.database);

  @override
  Future<List<DebtorModel>> getAllDebtors() {
    return database.getAllDebtors().then(
      (data) => data.map((e) => DebtorModel.fromDrift(e)).toList(),
    );
  }

  @override
  Future<DebtorModel?> getDebtorById(int id) {
    return database.getDebtorById(id).then(
      (data) => data != null ? DebtorModel.fromDrift(data) : null,
    );
  }

  @override
  Future<DebtorModel?> getDebtorByPhone(String phone) {
    return database.getDebtorByPhone(phone).then(
      (data) => data != null ? DebtorModel.fromDrift(data) : null,
    );
  }

  @override
  Future<DebtModel?> getDebtByOperationId(int operationId) {
    return database.getDebtByOperationId(operationId).then(
      (data) => data != null ? DebtModel.fromDrift(data) : null,
    );
  }

  @override
  Future<Map<int, DebtModel>> getOperationDebts() async {
    final data = await database.getOperationDebts();
    return data.map((operationId, debt) => MapEntry(operationId, DebtModel.fromDrift(debt)));
  }

  @override
  Future<int> insertDebtor(DebtorModel debtor) {
    return database.insertDebtor(
      DebtorsTableCompanion(
        name: Value(debtor.name),
        phone: Value(debtor.phone),
        notes: Value(debtor.notes),
      ),
    );
  }

  @override
  Future<int> insertDebt(DebtModel debt) {
    return database.insertDebt(
      DebtsTableCompanion(
        debtorId: Value(debt.debtorId),
        operationId: Value(debt.operationId),
        operationType: Value(debt.operationType),
        providerType: Value(debt.providerType),
        amount: Value(debt.amount),
      ),
    );
  }

  @override
  Future<List<DebtModel>> getDebtsByDebtor(int debtorId) {
    return database.getDebtsByDebtor(debtorId).then(
      (data) => data.map((e) => DebtModel.fromDrift(e)).toList(),
    );
  }

  @override
  Future<List<DebtModel>> getUnpaidDebts() {
    return database.getUnpaidDebts().then(
      (data) => data.map((e) => DebtModel.fromDrift(e)).toList(),
    );
  }

  @override
  Future<double> getTotalOutstandingDebt() {
    return database.getTotalOutstandingDebt();
  }

  @override
  Future<void> settleDebt(int debtId) {
    return database.settleDebt(debtId);
  }
}
