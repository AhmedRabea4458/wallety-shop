import 'package:smart_expense/core/errors/exceptions.dart';
import 'package:smart_expense/features/operations/data/datasources/local/shift_local_datasource.dart';
import 'package:smart_expense/features/operations/data/models/shift_model.dart';
import 'package:smart_expense/features/operations/domain/entities/operation_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/shift_entity.dart';
import 'package:smart_expense/features/operations/domain/repositories/shift_repository.dart';

class ShiftRepositoryImpl implements ShiftRepository {
  final ShiftLocalDataSource localDataSource;

  ShiftRepositoryImpl(this.localDataSource);

  @override
  Future<ShiftEntity?> getActiveShift() {
    return localDataSource.getActiveShift().then(
      (model) => model?.toEntity(),
    );
  }

  @override
  Future<List<ShiftEntity>> getShiftHistory() {
    return localDataSource.getShiftHistory().then(
      (data) => data.map((m) => m.toEntity()).toList(),
    );
  }

  @override
  Future<ShiftEntity?> getShiftById(int id) {
    return localDataSource.getShiftById(id).then(
      (model) => model?.toEntity(),
    );
  }

  @override
  Future<void> openShift(ShiftEntity shift) async {
    final active = await localDataSource.getActiveShift();
    if (active != null) {
      throw ActiveShiftExistsException();
    }
    final model = ShiftModel(
      id: shift.id,
      startTime: shift.startTime,
      openingCashDrawer: shift.openingCashDrawer,
      createdAt: shift.createdAt,
    );
    return localDataSource.insertShift(model);
  }

  @override
  Future<void> closeShift(int id, double closingBalance) {
    return localDataSource.closeShift(id, closingBalance);
  }

  @override
  Future<List<OperationEntity>> getOperationsByShiftId(int shiftId) {
    return localDataSource.getOperationsByShiftId(shiftId).then(
      (data) => data.map((m) => m.toEntity()).toList(),
    );
  }

  @override
  Future<void> repairActiveShifts() => localDataSource.repairActiveShifts();
}
