import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_expense/features/operations/domain/repositories/shift_repository.dart';
import 'package:smart_expense/features/operations/presentation/cubit/shift_history_state.dart';
import 'package:smart_expense/features/operations/presentation/cubit/shift_stats.dart';

class ShiftHistoryCubit extends Cubit<ShiftHistoryState> {
  final ShiftRepository repository;

  ShiftHistoryCubit(this.repository) : super(ShiftHistoryInitial());

  Future<void> loadShiftHistory() async {
    emit(ShiftHistoryLoading());
    try {
      final shifts = await repository.getShiftHistory();
      final Map<int, ShiftStats> statsMap = {};
      for (final shift in shifts) {
        final ops = await repository.getOperationsByShiftId(shift.id);
        statsMap[shift.id] = ShiftStats.fromOperations(ops);
      }
      emit(ShiftHistoryLoaded(shifts: shifts, shiftStats: statsMap));
    } catch (e) {
      debugPrint('loadShiftHistory error: $e');
      emit(ShiftHistoryError(message: 'فشل تحميل سجل الورديات'));
    }
  }
}
