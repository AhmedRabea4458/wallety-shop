import 'package:smart_expense/features/operations/domain/entities/operation_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/shift_entity.dart';

abstract class ShiftRepository {
  Future<ShiftEntity?> getActiveShift();
  Future<List<ShiftEntity>> getShiftHistory();
  Future<ShiftEntity?> getShiftById(int id);
  Future<void> openShift(ShiftEntity shift);
  Future<void> closeShift(int id, double closingBalance);
  Future<List<OperationEntity>> getOperationsByShiftId(int shiftId);
  Future<void> repairActiveShifts();
}
