import 'package:drift/drift.dart';
import 'package:smart_expense/core/database/app_database.dart';
import 'package:smart_expense/features/operations/data/datasources/local/shift_local_datasource.dart';
import 'package:smart_expense/features/operations/data/models/operation_model.dart';
import 'package:smart_expense/features/operations/data/models/shift_model.dart';

class ShiftLocalDataSourceImpl implements ShiftLocalDataSource {
  final AppDatabase database;

  ShiftLocalDataSourceImpl(this.database);

  @override
  Future<ShiftModel?> getActiveShift() {
    return database.getActiveShift().then(
      (data) => data != null ? ShiftModel.fromDrift(data) : null,
    );
  }

  @override
  Future<List<ShiftModel>> getShiftHistory() {
    return database.getShiftHistory().then(
      (data) => data.map((e) => ShiftModel.fromDrift(e)).toList(),
    );
  }

  @override
  Future<ShiftModel?> getShiftById(int id) {
    return database.getShiftById(id).then(
      (data) => data != null ? ShiftModel.fromDrift(data) : null,
    );
  }

  @override
  Future<void> insertShift(ShiftModel model) {
    return database.insertShift(
      ShiftsTableCompanion(
        startTime: Value(model.startTime),
        openingCashDrawer: Value(model.openingCashDrawer),
        notes: Value(model.notes),
      ),
    );
  }

  @override
  Future<void> closeShift(int id, double closingBalance) {
    return database.closeShift(id, closingBalance);
  }

  @override
  Future<List<OperationModel>> getOperationsByShiftId(int shiftId) {
    return database.getOperationsByShiftId(shiftId).then(
      (data) => data.map((e) => OperationModel.fromDrift(e)).toList(),
    );
  }

  @override
  Future<void> repairActiveShifts() => database.repairActiveShifts();
}
