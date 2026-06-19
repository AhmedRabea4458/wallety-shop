import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_expense/features/operations/domain/repositories/shift_repository.dart';
import 'package:smart_expense/features/operations/presentation/cubit/shift_detail_state.dart';
import 'package:smart_expense/features/operations/presentation/cubit/shift_stats.dart';

class ShiftDetailCubit extends Cubit<ShiftDetailState> {
  final ShiftRepository repository;

  ShiftDetailCubit(this.repository) : super(ShiftDetailInitial());

  Future<void> loadShiftDetail(int shiftId) async {
    emit(ShiftDetailLoading());
    try {
      final shift = await repository.getShiftById(shiftId);
      if (shift == null) {
        emit(ShiftDetailError(message: 'الوردية غير موجودة'));
        return;
      }
      final ops = await repository.getOperationsByShiftId(shiftId);
      final stats = ShiftStats.fromOperations(ops);
      emit(ShiftDetailLoaded(shift: shift, stats: stats, operations: ops));
    } catch (e) {
      debugPrint('loadShiftDetail error: $e');
      emit(ShiftDetailError(message: 'فشل تحميل تفاصيل الوردية'));
    }
  }
}
