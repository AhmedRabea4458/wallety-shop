import 'package:smart_expense/features/operations/data/models/operation_model.dart';
import 'package:smart_expense/features/operations/data/models/shift_model.dart';

abstract class ShiftLocalDataSource {
  Future<ShiftModel?> getActiveShift();
  Future<List<ShiftModel>> getShiftHistory();
  Future<ShiftModel?> getShiftById(int id);
  Future<void> insertShift(ShiftModel model);
  Future<void> closeShift(int id, double closingBalance);
  Future<List<OperationModel>> getOperationsByShiftId(int shiftId);
  Future<void> repairActiveShifts();
}
